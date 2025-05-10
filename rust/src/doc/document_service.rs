use flutter_rust_bridge::{frb, DartFnFuture};
use log::{error, info};
use yrs::{merge_updates_v2, Doc, Map, ReadTxn, Transact};

use super::error::DocError;
use super::operations::{block_ops::BlockOperations, delta_ops::DeltaOperations, update_ops::UpdateOperations};

use crate::doc::constants::{BLOCKS, DEFAULT_PARENT, ROOT_ID};
use crate::doc::document_types::{BlockActionDoc, BlockActionTypeDoc, CustomRustError, DocumentState, FailedToDecodeUpdates};
use crate::doc::utils::util::MapExt;
use crate::{log_info, log_error};


#[frb]
pub struct DocumentService {
    doc: Doc,
    doc_id: String,
}

impl DocumentService {

    #[frb]
    pub fn new() -> Self {
        log_info!("Creating new document service");
        let doc_id = "xxxx".to_string();
        Self { doc_id, doc: Doc::new() }
    }

    #[no_mangle]
    #[inline(never)]
    #[frb]
    pub fn init_empty_doc(&mut self) -> Result<Vec<u8>, CustomRustError> {
        log_info!("init_empty_doc: Starting for doc_id: {}", self.doc_id);
        
        // Get a reference to the document
        let doc = &self.doc;
        let root = doc.get_or_insert_map(ROOT_ID);
        let mut txn = doc.transact_mut();

        // Initialize the document structure
        log_info!("init_empty_doc: Initializing blocks for doc_id: {}", self.doc_id);
        root.get_or_init_map(&mut txn, BLOCKS);
        
        
        // Create the empty state update
        log_info!("init_empty_doc: Encoding state for doc_id: {}", self.doc_id);
        let empty_state = yrs::StateVector::default();
        let update = txn.encode_state_as_update_v2(&empty_state);
        
        log_info!("init_empty_doc: Finished for doc_id: {}", self.doc_id);
        Ok(update)
    }

    #[no_mangle]
#[inline(never)]
#[frb]
pub fn apply_action(
    &mut self,
    actions: Vec<BlockActionDoc>,
) -> Result<Vec<u8>, CustomRustError> {
    log_info!("apply_action: Starting with {} actions for doc_id: {}", 
             actions.len(), self.doc_id);
    
    // Get document handle and start transaction
    let doc = &self.doc;
    let root = doc.get_or_insert_map(ROOT_ID);
    let mut txn = doc.transact_mut();
    
    // Process each action
    for action in actions {
        let blocks_map = root.get_or_init_map(&mut txn, BLOCKS);
        
        // Delegate to specialized operation handlers
        match action.action {
            BlockActionTypeDoc::Insert => {
                BlockOperations::insert_node(&mut txn, blocks_map, action)?;
            },
            BlockActionTypeDoc::Update => {
                BlockOperations::update_node(&mut txn, blocks_map, action)?;
            },
            BlockActionTypeDoc::Delete => {
                let parent_id = action.block.parent_id
                    .unwrap_or_else(|| DEFAULT_PARENT.to_owned());
                
                BlockOperations::delete_node(&mut txn, blocks_map, &action.block.id, &parent_id)?;
            },
            BlockActionTypeDoc::Move => {
                if let (Some(old_path), Some(parent_id), Some(old_parent_id)) = 
                    (action.old_path.as_ref(), action.block.parent_id.as_ref(), action.block.old_parent_id.as_ref()) {
                    BlockOperations::move_block(
                        &mut txn, blocks_map,
                        old_path, &action.path, parent_id, old_parent_id,
                        &action.block.id, action.block.prev_id, action.block.next_id
                    )?;
                } else {
                    return Err(DocError::InvalidOperation("Missing required fields for move operation".into()).into());
                }
            }
        }
    }
    
    // Generate update from the transaction
    log_info!("apply_action: Encoding state for doc_id: {}", self.doc_id);
    let before_state = txn.before_state();
    let update = txn.encode_diff_v2(before_state);
    
    Ok(update)
}

    #[no_mangle]
    #[inline(never)]
    #[frb]
    pub fn apply_updates(&mut self, updates: Vec<Vec<u8>>) -> Result<(), CustomRustError> {
        log_info!("apply_updates: Starting with {} updates for doc_id: {}", updates.len(), self.doc_id);
        
        // Create a new document to apply updates to
        // let new_doc = Doc::new();
        
        // Apply updates to the new document
        let result = UpdateOperations::apply_updates_inner(self.doc.clone(), &self.doc_id, updates)?;
        
        // Replace the current document with the new one
        // self.doc = new_doc;
        
        log_info!("apply_updates: Successfully applied updates for doc_id: {}", self.doc_id);
        Ok(result)
    }

    #[no_mangle]
    #[inline(never)]
    #[frb]
    pub fn get_document_state(&self) -> Result<DocumentState, CustomRustError> {
        log_info!("get_document_state: Starting for doc_id: {}", self.doc_id);
        
        let doc = &self.doc;
        let root = doc.get_or_insert_map(ROOT_ID);
        let txn = doc.transact();
        
        // Extract document state through specialized function
        let state = UpdateOperations::extract_document_state(&txn, root, &self.doc_id)?;
        
        log_info!("get_document_state: Finished for doc_id: {}", self.doc_id);
        Ok(state)
    }

    #[frb]
    pub fn merge_updates(&self, updates: Vec<Vec<u8>>) -> Result<Vec<u8>, CustomRustError> {
        log_info!("merge_updates: Merging {} updates", updates.len());
        
        match merge_updates_v2(updates) {
            Ok(update) => {
                log_info!("merge_updates: Successfully merged updates");
                Ok(update)
            },
            Err(e) => {
                log_error!("merge_updates: Failed to merge updates: {}", e);
                Err(DocError::EncodingError(format!("Failed to merge updates: {}", e)).into())
            }
        }
    }

    #[no_mangle]
    #[inline(never)]
    #[frb]
    /// Setting a root node id in the root map
    pub fn set_root_node_id(&mut self, id: String) -> Result<Vec<u8>, CustomRustError> {
        log_info!("set_root_node_id: Setting root node id to {}", id);
        
        let doc = &self.doc;
        let root = doc.get_or_insert_map(ROOT_ID);
        let mut txn = doc.transact_mut();
        root.insert(&mut txn, ROOT_ID, id.clone());
        log_info!("set_root_node_id: Successfully set root node id to {}", id);

        // Encode the state as an update
        let before_state = txn.before_state();
        let update = txn.encode_diff_v2(before_state);
        log_info!("set_root_node_id: Finished for doc_id: {}", self.doc_id);
        Ok(update)
    }


}