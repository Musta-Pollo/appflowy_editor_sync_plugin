use flutter_rust_bridge::DartFnFuture;
use log::info;
use std::collections::HashMap;
use std::sync::Arc;
use yrs::{ Array, ArrayRef, Map, MapPrelim, MapRef, ReadTxn, TextRef, TransactionMut };

use crate::doc::constants::{ ATTRIBUTES, DEFAULT_PARENT, ID, PARENT_ID, PREV_ID, TEXT, TYPE };
use crate::doc::document_types::{ BlockActionDoc, CustomRustError };
use crate::doc::error::DocError;
use crate::doc::operations::delta_ops::DeltaOperations;
use crate::doc::utils::util::MapExt;

use crate::{ log_info, log_error };

pub struct BlockOperations;

impl BlockOperations {
    /// Insert a new block node into the document
    pub fn insert_node(
        txn: &mut TransactionMut,
        blocks_map: MapRef,
        action: BlockActionDoc,
    ) -> Result<MapRef, CustomRustError> {
        let block_id = action.block.id.clone();
        log_info!("insert_node: Starting for block_id: {}", block_id);

        let parent_id = action.block.parent_id.unwrap_or_else(|| DEFAULT_PARENT.to_owned());

        // Create the node and set its basic properties
        let node_ref = blocks_map.get_or_init_map(txn, block_id.clone());
        node_ref.insert(txn, Arc::from(ID), block_id.clone());
        node_ref.insert(txn, Arc::from(TYPE), action.block.ty.clone());

        if parent_id != DEFAULT_PARENT {
            node_ref.insert(txn, Arc::from(PARENT_ID), parent_id.clone());
        }

        // Set attributes
        let mut attr_map = MapPrelim::default();
        for (k, v) in action.block.attributes {
            attr_map.insert(k.into(), v.into());
        }
        node_ref.insert(txn, Arc::from(ATTRIBUTES), attr_map);

        // Apply delta if present
        if let Some(delta_json) = action.block.delta {
            let text = node_ref.get_or_init_text(txn, TEXT);
            DeltaOperations::apply_delta_to_text(txn, text, delta_json)?;
        }

        // Handle the prev_id chain
        Self::handle_prev_id_chain(
            txn,
            blocks_map.clone(),
            &block_id,
            action.block.prev_id.clone()
        )?;

        Self::handle_following_connection(
            txn,
            blocks_map.clone(),
            &block_id,
            action.block.next_id.clone(),
            action.block.prev_id.clone()
        );

        // Set the prev_id for this block
        if let Some(prev_id) = action.block.prev_id {
            log_info!("  Setting prev_id of block {} to {}", block_id, prev_id);
            let block = blocks_map.get_or_init_map(txn, block_id.to_string());
            block.insert(txn, Arc::from(PREV_ID), prev_id);
        }

        log_info!("insert_node: Finished for block_id: {}", block_id);
        Ok(node_ref)
    }

    /// Update an existing block node in the document
    pub fn update_node(
        txn: &mut TransactionMut,
        blocks_map: MapRef,
        action: BlockActionDoc,
    ) -> Result<(), CustomRustError> {
        let block_id = action.block.id.clone();
        log_info!("update_node: Updating block_id: {}", block_id);

        let node = blocks_map.get_or_init_map(txn, block_id.clone());

        // Update attributes if any
        if !action.block.attributes.is_empty() {
            let data = node.get_or_init_map(txn, ATTRIBUTES);
            for (k, v) in action.block.attributes {
                data.insert(txn, k, v);
            }
        }

        // Apply delta if present
        if let Some(delta_json) = action.block.delta {
            let text = node.get_or_init_text(txn, TEXT);
            DeltaOperations::apply_delta_to_text(txn, text, delta_json)?;
        }

        log_info!("update_node: Updated block_id: {}", block_id);
        Ok(())
    }
    /// Delete a block node and its descendants from the document
    pub fn delete_node(
        txn: &mut TransactionMut,
        blocks_map: MapRef,
        block_id: &str,
        parent_id: &str
    ) -> Result<(), CustomRustError> {
        log_info!("delete_node: Starting for block_id: {}", block_id);
    
        // Build the parent-child structure
        let blocks_by_parent = Self::build_parent_child_structure(txn, blocks_map.clone());
        
        // Get all descendants
        let descendants = Self::find_descendants(block_id, &blocks_by_parent);
        log_info!("Block {} has {} descendants to delete", block_id, descendants.len());
        
        // Update the prev_id chain for the main block
        Self::remove_block_from_prev_id_chain(txn, blocks_map.clone(), block_id)?;
        
        // Delete all descendants from bottom up (children first, then parents)
        for descendant_id in descendants {
            log_info!("Deleting descendant block: {}", descendant_id);
            
            // Update prev_id chain for each descendant
            Self::remove_block_from_prev_id_chain(txn, blocks_map.clone(), &descendant_id)?;
            
            // Remove the descendant block
            blocks_map.remove(txn, &descendant_id);
        }
        
        // Finally remove the main block
        blocks_map.remove(txn, block_id)
            .ok_or_else(|| DocError::BlockNotFound(format!("Block {} not found in blocks map", block_id)))?;
        
        log_info!("delete_node: Successfully deleted block_id: {} and its descendants", block_id);
        Ok(())
    }

    /// Move a block node to a new parent in the document
    pub fn move_block(
        txn: &mut TransactionMut,
        blocks_map: MapRef,
        old_path: &[u32],
        new_path: &[u32],
        parent_id: &str,
        old_parent_id: &str,
        block_id: &str,
        prev_id: Option<String>,
        next_id: Option<String>
    ) -> Result<(), CustomRustError> {
        log_info!(
            "move_block: Moving block_id: {} from parent: {} to parent: {}",
            block_id,
            old_parent_id,
            parent_id
        );
    
        // Update the prev_id chain
        Self::remove_block_from_prev_id_chain(txn, blocks_map.clone(), block_id)?;
    
        Self::handle_following_connection(
            txn,
            blocks_map.clone(),
            &block_id,
            next_id,
            prev_id.clone()
        );
    
        // Set the new prev_id or remove it
        let node = blocks_map.get_or_init_map(txn, block_id);
        if let Some(prev_id) = prev_id {
            // If another block has this prev_id, update its prev_id to point to this block
            node.insert(txn, Arc::from(PREV_ID), prev_id);
        } else {
            node.remove(txn, &Arc::from(PREV_ID));
        }
    
        //Save new parent id
        if parent_id != old_parent_id {
            if parent_id != DEFAULT_PARENT {
                node.insert(txn, Arc::from(PARENT_ID), parent_id.to_string());
            } else {
                node.remove(txn, &Arc::from(PARENT_ID));
            }
        }
    
        log_info!("move_block: Moved block between parents");
        Ok(())
    }

    /// Find all blocks that reference a given prev_id
    fn find_block_referencing_prev_id(
        txn: &mut TransactionMut,
        blocks_map: MapRef,
        prev_id_value: &str
    ) -> Vec<String> {
        log_info!("find_block_referencing_prev_id: Searching for blocks with prev_id = {}", prev_id_value);

        // Collect all block IDs first
        let block_ids: Vec<String> = blocks_map
            .iter(txn)
            .map(|(id, _)| id.to_string())
            .collect();

        log_info!("  Found {} total blocks to check", block_ids.len());

        // Then check each block individually
        let results: Vec<String> = block_ids
            .iter()
            .filter(|id| {
                let block_map = blocks_map.get_or_init_map(txn, Arc::from(id.as_str()));
                log_info!("  Checking block: {}", id);

                if let Some(prev_id_out) = block_map.get(txn, PREV_ID) {
                    if let yrs::Out::Any(yrs::Any::String(s)) = prev_id_out {
                        let matches = s.to_string() == prev_id_value;
                        log_info!("    Block has prev_id: {}, matches target: {}", s, matches);
                        matches
                    } else {
                        log_info!("    Block has prev_id but not a string type");
                        false
                    }
                } else {
                    log_info!("    Block does not have prev_id");
                    false
                }
            })
            .cloned()
            .collect();

        log_info!(
            "find_block_referencing_prev_id: Found {} blocks with prev_id = {}: {:?}",
            results.len(),
            prev_id_value,
            results
        );

        results
    }

    /// Handle the prev_id chain for a block
    fn handle_prev_id_chain(
        txn: &mut TransactionMut,
        blocks_map: MapRef,
        block_id: &str,
        prev_id: Option<String>
    ) -> Result<(), CustomRustError> {
        log_info!("handle_prev_id_chain: block_id={}, prev_id={:?}", block_id, prev_id);

        if let Some(prev_id) = prev_id {
            log_info!("  Finding blocks that reference prev_id: {}", prev_id);
            // Find all blocks that have this prev_id
            let blocks_with_same_prev_id = Self::find_block_referencing_prev_id(
                txn,
                blocks_map.clone(),
                &prev_id
            );

            log_info!(
                "  Found {} blocks with prev_id {}: {:?}",
                blocks_with_same_prev_id.len(),
                prev_id,
                blocks_with_same_prev_id
            );

            // Update each block that references this prev_id to now point to this block
            for other_block_id in blocks_with_same_prev_id {
                log_info!(
                    "  Updating block {} to point to {} (was pointing to {})",
                    other_block_id,
                    block_id,
                    prev_id
                );
                let other_block = blocks_map.get_or_init_map(txn, other_block_id);
                other_block.insert(txn, Arc::from(PREV_ID), block_id.to_string());
            }
        } else {
            log_info!("  No prev_id provided, nothing to handle");
        }

        log_info!("handle_prev_id_chain: Completed");
        Ok(())
    }

    /// Remove a block from the prev_id chain
    fn remove_block_from_prev_id_chain(
        txn: &mut TransactionMut,
        blocks_map: MapRef,
        block_id: &str
    ) -> Result<(), CustomRustError> {
        log_info!("remove_block_from_prev_id_chain: Removing block {} from chain", block_id);

        // Get the block's prev_id if it exists
        let block_data = blocks_map.get_or_init_map(txn, block_id);
        let prev_id = block_data.get(txn, PREV_ID).and_then(|out| {
            if let yrs::Out::Any(yrs::Any::String(s)) = out {
                log_info!("  Block {} has prev_id: {}", block_id, s);
                Some(s.to_string())
            } else {
                log_info!("  Block {} has no prev_id or it's not a string", block_id);
                None
            }
        });

        // Find all blocks that reference this block as their prev_id
        log_info!("  Finding blocks that reference {} as their prev_id", block_id);
        let next_blocks = Self::find_block_referencing_prev_id(txn, blocks_map.clone(), block_id);

        log_info!("  Found {} next blocks: {:?}", next_blocks.len(), next_blocks);

        // Update each next block to point to this block's prev_id
        for next_id in next_blocks {
            let next_block = blocks_map.get_or_init_map(txn, next_id.clone());

            // Update the next block to point to this block's prev_id
            if let Some(prev_id) = &prev_id {
                log_info!(
                    "  Updating next block {} to point to {} (was pointing to {})",
                    next_id,
                    prev_id,
                    block_id
                );
                next_block.insert(txn, Arc::from(PREV_ID), prev_id.clone());
            } else {
                log_info!(
                    "  Removing prev_id from next block {} (was pointing to {})",
                    next_id,
                    block_id
                );
                next_block.remove(txn, &Arc::from(PREV_ID));
                //Give this node its deviceId and timestamp
                let attributes = next_block.get_or_init_map(txn, ATTRIBUTES);
                if let Some(device_out) = block_data.get(txn, "device") {
                    if let yrs::Out::Any(device_any) = device_out {
                        attributes.insert(txn, Arc::from("device"), device_any);
                    }
                }
                if let Some(timestamp_out) = block_data.get(txn, "timestamp") {
                    if let yrs::Out::Any(timestamp_any) = timestamp_out {
                        attributes.insert(txn, Arc::from("timestamp"), timestamp_any);
                    }
                }
            }
        }

        log_info!("remove_block_from_prev_id_chain: Completed");
        Ok(())
    }

    /// Handle the connection between blocks when inserting a new block or moving an existing one
    fn handle_following_connection(
        txn: &mut TransactionMut,
        blocks_map: MapRef,
        block_id: &str,
        next_id: Option<String>,
        prev_id: Option<String>
    ) -> Result<(), CustomRustError> {
        log_info!(
            "handle_following_connection: block_id={}, next_id={:?}, prev_id={:?}",
            block_id,
            next_id,
            prev_id
        );

        // If there is prev_id, use prev_id due to the fact
        // that the previous node can be referenced by multiple nodes
        if let Some(prev_id) = &prev_id {
            log_info!("  Using prev_id strategy (prev_id={})", prev_id);
            let next_nodes = Self::find_block_referencing_prev_id(txn, blocks_map.clone(), prev_id);

            log_info!(
                "  Found {} nodes that reference prev_id {}: {:?}",
                next_nodes.len(),
                prev_id,
                next_nodes
            );

            for next_id in next_nodes {
                log_info!("  Updating block {} to point to {}", next_id, block_id);
                let next_block = blocks_map.get_or_init_map(txn, next_id);
                next_block.insert(txn, Arc::from(PREV_ID), block_id.to_string());
            }

            log_info!("  Finished prev_id strategy");
        }

        // If there is next_id, use it as well. It will be usefull in cases when there is multiple nodes
        // insertted at the same time
        if let Some(next_id) = &next_id {
            log_info!("  Using next_id strategy (next_id={})", next_id);
            let next_block: MapRef = blocks_map.get_or_init_map(txn, Arc::from(next_id.as_str()));

            log_info!("  Setting prev_id of next block {} to {}", next_id, block_id);
            next_block.insert(txn, Arc::from(PREV_ID), block_id.to_string());

            log_info!(
                "  Attempting to copy device and timestamp from next block {} to {}",
                next_id,
                block_id
            );

            // Copy device_id and timestamp attributes
            let block = blocks_map.get_or_init_map(txn, block_id);
            let attributes = block.get_or_init_map(txn, ATTRIBUTES);

            // Handle device attribute
            match next_block.get(txn, "device") {
                Some(device_out) => {
                    log_info!("  Found device attribute in next block");
                    if let yrs::Out::Any(device_any) = device_out {
                        log_info!("  Copying device attribute to current block");
                        attributes.insert(txn, Arc::from("device"), device_any);
                    } else {
                        log_info!("  ERROR: Device attribute is not in the expected format");
                    }
                }
                None => log_info!("  WARNING: Next block has no device attribute"),
            }

            // Handle timestamp attribute
            match next_block.get(txn, "timestamp") {
                Some(timestamp_out) => {
                    log_info!("  Found timestamp attribute in next block");
                    if let yrs::Out::Any(timestamp_any) = timestamp_out {
                        log_info!("  Copying timestamp attribute to current block");
                        attributes.insert(txn, Arc::from("timestamp"), timestamp_any);
                    } else {
                        log_info!("  ERROR: Timestamp attribute is not in the expected format");
                    }
                }
                None => log_info!("  WARNING: Next block has no timestamp attribute"),
            }

            log_info!("  Finished next_id strategy");
        } else {
            log_info!("  No prev_id or next_id provided, nothing to handle");
        }

        log_info!("handle_following_connection: Completed");
        Ok(())
    }

    /// Build a mapping of parents to their children by analyzing all blocks in the map
    pub fn build_parent_child_structure(
        txn: &mut TransactionMut, // Changed from 'mut txn: &TransactionMut'
        blocks_map: MapRef
    ) -> HashMap<String, Vec<String>> {
        log_info!("Building parent-child structure");

        let mut blocks_by_parent: HashMap<String, Vec<String>> = HashMap::new();

        // Collect all block IDs
        let block_ids: Vec<String> = blocks_map
            .iter(txn)
            .map(|(id, _)| id.to_string())
            .collect();

        log_info!("Found {} total blocks", block_ids.len());

        // Assign each block to its parent
        for block_id in &block_ids {
            let block_data = blocks_map.get_or_init_map(txn, Arc::from(block_id.as_str()));

            // Get parent ID if available, otherwise use "root"
            let parent_id = if let Some(parent_out) = block_data.get(txn, PARENT_ID) {
                if let yrs::Out::Any(yrs::Any::String(s)) = parent_out {
                    s.to_string()
                } else {
                    "root".to_string()
                }
            } else {
                "root".to_string()
            };

            blocks_by_parent.entry(parent_id.clone()).or_default().push(block_id.clone());
            log_info!("Block {} assigned to parent {}", block_id, parent_id);
        }

        log_info!("Built parent-child structure with {} parent entries", blocks_by_parent.len());
        blocks_by_parent
    }

    /// Find all descendants of a block (recursive)
    pub fn find_descendants(
        block_id: &str,
        blocks_by_parent: &HashMap<String, Vec<String>>
    ) -> Vec<String> {
        let mut descendants = Vec::new();

        // Get direct children
        if let Some(children) = blocks_by_parent.get(block_id) {
            for child_id in children {
                descendants.push(child_id.clone());

                // Recursively get children of children
                let child_descendants = Self::find_descendants(child_id, blocks_by_parent);
                descendants.extend(child_descendants);
            }
        }

        descendants
    }
}
