use std::collections::HashMap;
use std::sync::Arc;
use serde_json::{Value, Map as JsonMap, json};
use yrs::{Any as YrsAny, types::Delta, ReadTxn, Map, Array};

use crate::doc::document_types::{BlockDoc, DocumentState};
use crate::doc::constants::{ID, TYPE, PARENT_ID, PREV_ID, TEXT, ATTRIBUTES};
use crate::doc::error::DocError;
use crate::doc::document_types::CustomRustError;
use crate::log_info;

/// Utilities for converting between different data representations
pub struct Conversion;

impl Conversion {
    
    /// Convert a vector of deltas to JSON
    pub fn deltas_to_json<T: ReadTxn>(
        txn: &T,
        deltas: Vec<Delta<yrs::Out>>
    ) -> Result<Value, CustomRustError> {
        log_info!("deltas_to_json: Converting {} deltas", deltas.len());
        
        let json_deltas: Result<Vec<Value>, CustomRustError> = deltas
            .into_iter()
            .map(|delta| Self::delta_to_json(txn, delta))
            .collect();
            
        json_deltas.map(Value::Array)
    }

    /// Convert a Yrs delta to JSON
    pub fn delta_to_json<T: ReadTxn>(
        txn: &T,
        delta: Delta<yrs::Out>
    ) -> Result<Value, CustomRustError> {
        match delta {
            Delta::Inserted(text, attrs) => {
                let mut map = JsonMap::new();
                map.insert("insert".to_string(), Value::String(text.to_string(txn)));
                
                if let Some(attributes) = attrs {
                    let attrs_json: JsonMap<String, Value> = attributes
                        .iter()
                        .map(|(k, v)| (k.to_string(), Self::any_to_json(v)))
                        .collect();
                    
                    map.insert("attributes".to_string(), Value::Object(attrs_json));
                }
                
                Ok(Value::Object(map))
            },
            Delta::Retain(len, attrs) => {
                let mut map = JsonMap::new();
                map.insert("retain".to_string(), Value::Number(len.into()));
                
                if let Some(attributes) = attrs {
                    let attrs_json: JsonMap<String, Value> = attributes
                        .iter()
                        .map(|(k, v)| (k.to_string(), Self::any_to_json(v)))
                        .collect();
                    
                    map.insert("attributes".to_string(), Value::Object(attrs_json));
                }
                
                Ok(Value::Object(map))
            },
            Delta::Deleted(len) => {
                let mut map = JsonMap::new();
                map.insert("delete".to_string(), Value::Number(len.into()));
                Ok(Value::Object(map))
            }
        }
    }
    
    /// Convert a yjs Any value to JSON
    pub fn any_to_json(any: &yrs::Any) -> Value {
        match any {
            yrs::Any::Null => Value::Null,
            yrs::Any::Undefined => Value::Null,
            yrs::Any::Bool(b) => Value::Bool(*b),
            yrs::Any::Number(n) => {
                Value::Number(serde_json::Number::from_f64(*n).unwrap_or(0.into()))
            }
            yrs::Any::String(s) => Value::String(s.to_string()),
            yrs::Any::Array(arr) => Value::Array(arr.iter().map(Self::any_to_json).collect()),
            yrs::Any::Map(map) => Value::Object(
                map.iter()
                    .map(|(k, v)| (k.to_string(), Self::any_to_json(v)))
                    .collect()
            ),
            yrs::Any::BigInt(i) => Value::Number((*i).into()),
            yrs::Any::Buffer(_) => Value::String("<buffer>".to_string()),
        }
    }
    
    /// Convert JSON value to yjs Any
    pub fn json_value_to_yrs_any(val: &Value) -> yrs::Any {
        match val {
            Value::Null => yrs::Any::Null,
            Value::Bool(b) => yrs::Any::Bool(*b),
            Value::Number(n) => {
                if let Some(i) = n.as_i64() {
                    yrs::Any::Number(i as f64)
                } else if let Some(f) = n.as_f64() {
                    yrs::Any::Number(f)
                } else {
                    yrs::Any::Undefined
                }
            }
            Value::String(s) => yrs::Any::String(Arc::from(s.as_str())),
            Value::Array(arr) => yrs::Any::Array(
                Arc::from(arr.iter().map(Self::json_value_to_yrs_any).collect::<Vec<_>>())
            ),
            Value::Object(obj) => yrs::Any::Map(
                Arc::from(
                    obj.iter()
                        .map(|(k, v)| (k.clone(), Self::json_value_to_yrs_any(v)))
                        .collect::<HashMap<_, _>>()
                )
            ),
        }
    }

    

    /// Convert a document tree to JSON
    pub fn document_to_json(doc_state: &DocumentState) -> Result<Value, CustomRustError> {
        let mut blocks_json = JsonMap::new();
        
        for (id, block) in &doc_state.blocks {
            let mut block_json = JsonMap::new();
            
            // Add basic properties
            block_json.insert("id".to_string(), json!(block.id));
            block_json.insert("type".to_string(), json!(block.ty));
            
            // Add optional properties
            if let Some(parent_id) = &block.parent_id {
                block_json.insert("parentId".to_string(), json!(parent_id));
            }
            
            if let Some(prev_id) = &block.prev_id {
                block_json.insert("prevId".to_string(), json!(prev_id));
            }
            
            // Add attributes
            let attrs_json: JsonMap<String, Value> = block.attributes
                .iter()
                .map(|(k, v)| (k.clone(), json!(v)))
                .collect();
            
            block_json.insert("attributes".to_string(), Value::Object(attrs_json));
            
            // Add delta if present
            if let Some(delta) = &block.delta {
                block_json.insert("delta".to_string(), 
                    serde_json::from_str(delta).unwrap_or(Value::Null));
            }
            
            blocks_json.insert(id.clone(), Value::Object(block_json));
        }
        
        // Build children map
        let mut children_json = JsonMap::new();
        for (parent_id, children) in &doc_state.children_map {
            children_json.insert(parent_id.clone(), json!(children));
        }
        
        // Build final document
        let mut doc_json = JsonMap::new();
        doc_json.insert("docId".to_string(), json!(doc_state.doc_id));
        doc_json.insert("blocks".to_string(), Value::Object(blocks_json));
        doc_json.insert("childrenMap".to_string(), Value::Object(children_json));
        
        Ok(Value::Object(doc_json))
    }

}




