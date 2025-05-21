use flutter_rust_bridge::DartFnFuture;
use futures::executor::block_on;
use log::{info, error};
use serde_json::{Value, Map as JsonMap};
use yrs::Text;
use std::collections::HashMap;
use std::sync::Arc;

use yrs::{types::Delta, ReadTxn, TextRef, TransactionMut};

use crate::doc::conversions::conversion::Conversion;
use crate::doc::document_types::CustomRustError;
use crate::doc::error::DocError;
use crate::doc::utils::util::TextExt;
use crate::{log_info, log_error};

// Constants for delta operations
pub const INSERT: &str = "insert";
pub const RETAIN: &str = "retain";
pub const DELETE: &str = "delete";
pub const ATTRIBUTES: &str = "attributes";

pub struct DeltaOperations;

impl DeltaOperations {
    /// Apply a delta to a YText object
    pub fn apply_delta_to_text(
        txn: &mut TransactionMut,
        text: TextRef,
        new_delta: String,
    ) -> Result<(), CustomRustError> {
        // Get current text delta
        let current_delta = text.delta(txn);
        

        // Get delta diff from the Dart side
        // Legacy Code
        let new_delta_diff = new_delta;
        
        // Parse the delta diff
        log_info!("apply_delta_to_text: Parsing delta diff from JSON");
        let parsed_delta: Vec<HashMap<String, Value>> = serde_json::from_str(&new_delta_diff)
            .map_err(|e| DocError::DecodingError(format!("Failed to parse delta diff: {}", e)))?;
        
        if parsed_delta.is_empty() {
            log_info!("apply_delta_to_text: No changes to apply");
            return Ok(());
        }
        
        // Apply the delta diff
        Self::apply_delta_diff_to_text(txn, text, &parsed_delta)
    }

    /// Apply a delta diff to a YText object
    pub fn apply_delta_diff_to_text(
        txn: &mut TransactionMut,
        text: TextRef,
        delta: &[HashMap<String, Value>]
    ) -> Result<(), CustomRustError> {
        log_info!("apply_delta_diff_to_text: Starting with {} operations", delta.len());
        
        let mut current_len = text.len(txn);
        let mut cursor_pos = 0;
        
        // Convert the delta operations to Y.js delta format
        let deltas = delta
            .iter()
            .map(|d| Self::parse_delta_operation(d, &mut cursor_pos, &mut current_len))
            .collect::<Result<Vec<_>, CustomRustError>>()?;
        
        // Apply the deltas to the text
        text.apply_delta(txn, deltas);
        
        Ok(())
    }
    
    /// Parse a single delta operation
    fn parse_delta_operation(
        d: &HashMap<String, Value>, 
        cursor_pos: &mut u32,
        current_len: &mut u32
    ) -> Result<Delta<String>, CustomRustError> {
        if d.contains_key(INSERT) {
            // Handle insert operation
            let insert = d.get(INSERT)
                .and_then(|v| v.as_str())
                .ok_or_else(|| DocError::InvalidOperation("Insert value must be a string".into()))?;
                
            let insert_len = insert.encode_utf16().count() as u32;
            if insert_len == 0 {
                return Ok(Delta::Retain(0, None));
            }
            
            let attributes = Self::parse_attributes(d);
            
            *current_len += insert_len;
            *cursor_pos += insert_len;
            
            Ok(Delta::Inserted(insert.to_string().into(), attributes))
            
        } else if d.contains_key(RETAIN) {
            // Handle retain operation
            let retain = d.get(RETAIN)
                .and_then(|v| v.as_u64())
                .ok_or_else(|| DocError::InvalidOperation("Retain value must be a number".into()))? as u32;
                
            if retain > *current_len - *cursor_pos {
                return Err(DocError::InvalidOperation("Retain exceeds text length".into()).into());
            }
            
            if retain == 0 {
                return Ok(Delta::Retain(0, None));
            }
            
            *cursor_pos += retain;
            
            let attributes = Self::parse_attributes(d);
            Ok(Delta::Retain(retain, attributes))
            
        } else if d.contains_key(DELETE) {
            // Handle delete operation
            let delete = d.get(DELETE)
                .and_then(|v| v.as_u64())
                .ok_or_else(|| DocError::InvalidOperation("Delete value must be a number".into()))? as u32;
                
            if delete > *current_len {
                return Err(DocError::InvalidOperation("Delete exceeds text length".into()).into());
            }
            
            if delete == 0 {
                return Ok(Delta::Deleted(0));
            }
            
            *current_len -= delete;
            *cursor_pos = (*cursor_pos).saturating_sub(delete);
            
            Ok(Delta::Deleted(delete))
        } else {
            Err(DocError::InvalidOperation("Invalid delta operation".into()).into())
        }
    }

    /// Parse attributes
    fn parse_attributes(d: &HashMap<String, Value>) -> Option<Box<HashMap<Arc<str>, yrs::Any>>> {
        d.get(ATTRIBUTES).map(|a| {
            Box::new(
                a.as_object()
                    .unwrap_or(&JsonMap::new())
                    .iter()
                    .map(|(k, v)| (Arc::from(k.as_str()), Conversion::json_value_to_yrs_any(v)))
                    .collect::<HashMap<Arc<str>, yrs::Any>>()
            )
        })
    }

    
}