// transaction_adapter_helpers.dart
import 'dart:convert';
import 'dart:typed_data';

import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor_sync_plugin/editor_state_helpers/editor_state_wrapper.dart';
import 'package:appflowy_editor_sync_plugin/extensions/document_extensions.dart';
import 'package:appflowy_editor_sync_plugin/extensions/operation_extensions.dart';
import 'package:appflowy_editor_sync_plugin/src/rust/doc/document_types.dart';
import 'package:appflowy_editor_sync_plugin/types/operation_wrapper.dart';
import 'package:dartx/dartx.dart';
import 'package:fpdart/fpdart.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

class TransactionAdapterHelpers {
  // Check if a Delete and Insert pair represents a Move
  static bool _isMoveOperation(
    DeleteOperation deleteOp,
    InsertOperation insertOp,
  ) {
    if (deleteOp.nodes.length != 1 || insertOp.nodes.length != 1) return false;
    final deleteNode = deleteOp.nodes.first;
    final insertNode = insertOp.nodes.first;
    return deleteNode.id == insertNode.id &&
        deleteNode.type == insertNode.type &&
        _nodesEqual(deleteNode, insertNode);
  }

  // Recursively compare nodes for equality (ID, type, attributes, delta, children)
  static bool _nodesEqual(Node node1, Node node2) {
    if (node1.id != node2.id || node1.type != node2.type) return false;
    if (!const DeepCollectionEquality().equals(
      node1.attributes,
      node2.attributes,
    ))
      return false;
    if (node1.delta?.toJson().toString() != node2.delta?.toJson().toString())
      return false;
    if (node1.children.length != node2.children.length) return false;
    for (var i = 0; i < node1.children.length; i++) {
      if (!_nodesEqual(node1.children[i], node2.children[i])) return false;
    }
    return true;
  }

  /// Convert a list of operations to operation wrappers, detecting moves
  static List<OperationWrapper> convertToOperationWrappers(
    List<Operation> operations,
    EditorStateWrapper editorStateWrapper,
  ) {
    final wrappers = <OperationWrapper>[];

    //Sort operations so that delete comes before insert

    for (var i = 0; i < operations.length; i++) {
      final op = operations[i];

      // Check for move operations (delete followed by insert of same node)
      if (op is DeleteOperation && i + 1 < operations.length) {
        final nextOp = operations[i + 1];
        if (nextOp is InsertOperation && _isMoveOperation(op, nextOp)) {
          wrappers.add(
            OperationWrapper(
              type: OperationWrapperType.Move,
              firstOperation: op,
              optionalSecondOperation: Some(nextOp),
            ),
          );
          i++; // Skip the next operation
          continue;
        }
      }

      /////
      // CURRENTLY IT ASSUMES THAT THERE IS ONLY ONE NODE EACH TIME!!!!!!
      // Handle other operation types
      if (op is InsertOperation) {
        wrappers.add(
          OperationWrapper(
            type: OperationWrapperType.Insert,
            firstOperation: op,
            optionalSecondOperation: const None(),
          ),
        );
      } else if (op is DeleteOperation) {
        wrappers.add(
          OperationWrapper(
            type: OperationWrapperType.Delete,
            firstOperation: op,
            optionalSecondOperation: const None(),
          ),
        );
      } else if (op is UpdateOperation) {
        wrappers.add(
          OperationWrapper(
            type: OperationWrapperType.Update,
            firstOperation: op,
            optionalSecondOperation: const None(),
          ),
        );
      }
    }

    return wrappers;
  }

  static List<BlockActionDoc> operationWrappersToBlockActions(
    List<OperationWrapper> wrapped,
    EditorStateWrapper editorStateWrapper,
  ) {
    return IterableIterableX(
      wrapped.map((e) {
        return operationWrapperToBlockActions(e, editorStateWrapper);
      }),
    ).flatten().toList();
  }

  //Converting OperationWrapper to BlockActionDoc
  static List<BlockActionDoc> operationWrapperToBlockActions(
    OperationWrapper e,
    EditorStateWrapper editorStateWrapper,
  ) {
    if (e.type == OperationWrapperType.Move) {
      final op = e.firstOperation as DeleteOperation;
      final nextOp = e.optionalSecondOperation.toNullable()! as InsertOperation;
      final deleteNode = op.nodes.first;
      final insertNode = nextOp.nodes.first;

      final newPath = nextOp.path;
      final oldPath = op.path;

      //If the path is the same, return an empty list
      if (newPath.equals(oldPath)) {
        return [];
      }

      var prevId = '';

      final documentCopy = DocumentExtensions.fromJsonWithIds(
        jsonDecode(
          jsonEncode(editorStateWrapper.editorState.document.toJsonWithIds()),
        ),
      );
      documentCopy.delete(DeleteOperation.fromJson(op.toJson()).path);

      final oldParent = parentFromPath(documentCopy, deleteNode.path);

      // if the node is the first child of the parent, then its prevId should be empty.
      final isFirstChild = newPath.previous.equals(newPath);

      if (!isFirstChild) {
        prevId = documentCopy.nodeAtPath(newPath.previous)?.id ?? '';
      }

      var nextId = '';

      final insertCopy = InsertOperation.fromJson(nextOp.toJson());
      documentCopy.insert(insertCopy.path, insertCopy.nodes);

      //If the node is the last child of the parent, then its nextId should be empty.
      final isLastChild = newPath.next.equals(newPath);
      if (!isLastChild) {
        nextId = documentCopy.nodeAtPath(newPath.next)?.id ?? '';
      }

      return [
        BlockActionDoc(
          action: BlockActionTypeDoc.move,
          block: BlockDoc(
            id: deleteNode.id,
            ty: deleteNode.type,
            attributes: {},
            parentId: parentFromPath(documentCopy, newPath).id,
            oldParentId: oldParent.id,
            prevId: prevId == '' ? null : prevId, // Previous ID
            nextId: nextId == '' ? null : nextId, // Next ID
          ), // No block data needed; move uses paths
          path: Uint32List.fromList(nextOp.path.toList()), // New path
          oldPath: Uint32List.fromList(op.path.toList()), // Old path
        ),
      ];
    } else if (e.type == OperationWrapperType.Insert) {
      return e.firstOperation.toBlockAction(editorStateWrapper);
    } else if (e.type == OperationWrapperType.Update) {
      return e.firstOperation.toBlockAction(editorStateWrapper);
    } else if (e.type == OperationWrapperType.Delete) {
      return e.firstOperation.toBlockAction(editorStateWrapper);
    }
    throw UnimplementedError();
  }

  static List<BlockActionDoc> operationsToBlockActions(
    List<Operation> operations,
    EditorStateWrapper editorStateWrapper,
  ) {
    final wrapped = convertToOperationWrappers(operations, editorStateWrapper);
    return operationWrappersToBlockActions(wrapped, editorStateWrapper);
  }

  static Node parentFromPath(Document doc, Path path) {
    // Makes from [0, 1] -> [0]
    final withoutLast = path.parent;
    if (withoutLast.isEmpty) {
      return doc.root;
    }

    //Take node based on withoutLast
    return doc.nodeAtPath(withoutLast) ?? doc.root;
  }
}
