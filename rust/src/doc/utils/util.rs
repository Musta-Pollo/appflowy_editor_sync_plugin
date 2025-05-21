use std::collections::HashMap;

use std::sync::Arc;

use flutter_rust_bridge::frb;
use yrs::branch::BranchPtr;
use yrs::types::text::YChange;
use yrs::types::{DefaultPrelim, Delta};
use yrs::{
  Any, Array, ArrayPrelim, ArrayRef, Map, MapPrelim, MapRef, Out, ReadTxn, Text, TextPrelim,
  TextRef, TransactionMut,
};




#[frb(ignore)]
pub trait MapExt: Map {
  // Get or insert a [YMap] with the given key
  fn get_or_init_map<S: Into<Arc<str>>>(&self, txn: &mut TransactionMut, key: S) -> MapRef {
    let key = key.into();
    match self.get(txn, &key) {
      Some(Out::YMap(map)) => map,
      _ => self.insert(txn, key, MapPrelim::default()),
    }
  }
  /// Get or insert an [YArray] with the given key
  fn get_or_init_array<S: Into<Arc<str>>>(&self, txn: &mut TransactionMut, key: S) -> ArrayRef {
    let key = key.into();
    match self.get(txn, &key) {
      Some(Out::YArray(array)) => array,
      _ => self.insert(txn, key, ArrayPrelim::default()),
    }
  }
  /// Get or insert a [YText] with the given key
  fn get_or_init_text<S: Into<Arc<str>>>(&self, txn: &mut TransactionMut, key: S) -> TextRef {
    let key = key.into();
    match self.get(txn, &key) {
      Some(Out::YText(text)) => text,
      _ => self.insert(txn, key, TextPrelim::new("")),
    }
  }

  
}

impl MapExt for MapRef {}

#[frb(ignore)]
pub trait TextExt: Text {
  /// Get the text content as a list of [Delta]
  fn delta<T: ReadTxn>(&self, tx: &T) -> Vec<Delta> {
    let changes = self.diff(tx, YChange::identity);
    let mut deltas = vec![];
    for change in changes {
      let delta = Delta::Inserted(change.insert, change.attributes);
      deltas.push(delta);
    }
    deltas

  }
}

impl TextExt for TextRef {}