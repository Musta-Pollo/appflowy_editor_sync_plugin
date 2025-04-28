import 'dart:convert';
import 'dart:typed_data';

import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor_sync_plugin/convertors/transaction_adapter_helpers.dart';
import 'package:appflowy_editor_sync_plugin/document_service_helpers/diff_deltas.dart';
import 'package:appflowy_editor_sync_plugin/editor_state_helpers/editor_state_wrapper.dart';
import 'package:appflowy_editor_sync_plugin/extensions/node_extensions.dart';
import 'package:appflowy_editor_sync_plugin/src/rust/doc/document_types.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

extension BlockActionAdapter on Operation {
  List<BlockActionDoc> toBlockAction(EditorStateWrapper editorStateWrapper) {
    final op = this;
    if (op is InsertOperation) {
      return op.toBlockAction(editorStateWrapper);
    } else if (op is UpdateOperation) {
      return op.toBlockAction(editorStateWrapper);
    } else if (op is DeleteOperation) {
      return op.toBlockAction(editorStateWrapper);
    }
    throw UnimplementedError();
  }
}

extension on InsertOperation {
  List<BlockActionDoc> toBlockAction(
    EditorStateWrapper editorStateWrapper, {
    Node? previousNode,
    Node? nextNode,
    Node? parentNode,
  }) {
    var insertPath = path;
    var currentPath = path;
    final actions = <BlockActionDoc>[];
    // Track previous node between iterations
    Node? currentPreviousNode = previousNode;

    // For multiple nodes, we need to handle the connections between them
    final nodesList = nodes.toList();

    for (int i = 0; i < nodesList.length; i++) {
      final node = nodesList[i];
      final isLastNodeInBatch = i == nodesList.length - 1;

      final parentId =
          parentNode?.id ??
          TransactionAdapterHelpers.parentFromPath(
            editorStateWrapper.editorState.document,
            currentPath,
          ).id;
      assert(parentId.isNotEmpty);

      var prevId = '';
      // if the node is the first child of the parent, then its prevId should be empty.
      final isFirstChild = currentPath.previous.equals(currentPath);

      if (!isFirstChild) {
        prevId =
            currentPreviousNode?.id ??
            editorStateWrapper.getNodeAtPath(insertPath.previous)?.id ??
            '';
      }

      //THE NEXT ID IS ONLY USED WHN PREVID = NULL
      var nextId = '';

      // If this isn't the last node in our batch, the next ID should be the next node in our batch
      if (!isLastNodeInBatch) {
        nextId = nodesList[i + 1].id;
      } else {
        // For the last node, use the regular nextId logic
        //This will be true only if the path is empty
        final isLastChild = currentPath.next.equals(currentPath);
        if (!isLastChild) {
          // Special case for insertion at position [0]
          if (currentPath.isNotEmpty && currentPath.last == 0) {
            // Directly get the first child of the document
            nextId = editorStateWrapper.getNodeAtPath(insertPath)?.id ?? "";
          } else {
            nextId =
                nextNode?.id ??
                editorStateWrapper.getNodeAtPath(insertPath.next)?.id ??
                '';
          }
        }
      }

      //If I have a parent from insert, don't share nextid
      if (parentNode != null && isLastNodeInBatch) {
        nextId = '';
      }

      // create the external text if the node contains the delta in its data.
      final delta = node.delta;
      String? encodedDelta;
      if (delta != null) {
        encodedDelta = jsonEncode(node.delta!.toJson());
      }

      if (prevId == nextId && currentPath.elementAtOrNull(0) == -1) {
        prevId = '';
        nextId = '';
      }

      final blockAction = BlockActionDoc(
        action: BlockActionTypeDoc.insert,
        block: BlockDoc(
          id: node.id,
          ty: node.type,
          attributes:
              node.attributes.toMap()..addAll({
                'device': editorStateWrapper.syncDeviceId,
                'timestamp': DateTime.now().toIso8601String(),
              }),
          delta: encodedDelta,
          parentId: node.type == 'page' ? null : parentId, //HANDLING EDGE CASE
          prevId: prevId == '' ? null : prevId, // Previous ID
          nextId: nextId == '' ? null : nextId, // Next ID
        ),
        path: Uint32List.fromList(currentPath.toList()),
      );

      actions.add(blockAction);

      if (node.children.isNotEmpty) {
        Node? prevChild;
        for (final child in node.children) {
          actions.addAll(
            InsertOperation(child.path, [child]).toBlockAction(
              editorStateWrapper,
              previousNode: prevChild,
              parentNode: node,
            ),
          );
          prevChild = child;
        }
      }

      // Update the previous node for the next iteration
      currentPreviousNode = node;
      currentPath = currentPath.next;
    }

    return actions;
  }
}

extension on UpdateOperation {
  List<BlockActionDoc> toBlockAction(EditorStateWrapper editorStateWrapper) {
    final actions = <BlockActionDoc>[];

    // if the attributes are both empty, we don't need to update
    //You can also check for changes in a text, because the text is a delta
    // inside attributes
    if (const DeepCollectionEquality().equals(attributes, oldAttributes)) {
      return actions;
    }
    final node = editorStateWrapper.getNodeAtPath(path);
    if (node == null) {
      assert(false, 'node not found at path: $path');
      return actions;
    }
    // final parentId =
    //     node.parent?.id ??
    //     editorStateWrapper.getNodeAtPath(path.parent)?.id ??
    //     '';
    final parentId =
        TransactionAdapterHelpers.parentFromPath(
          editorStateWrapper.editorState.document,
          node.path,
        ).id;
    assert(parentId.isNotEmpty);

    // create the external text if the node contains the delta in its data.
    final prevDelta = oldAttributes[blockComponentDelta];
    final delta = attributes[blockComponentDelta];

    final diff =
        prevDelta != null && delta != null
            ? diffDeltas(
              jsonEncode(Delta.fromJson(prevDelta)),
              jsonEncode(Delta.fromJson(delta)),
            )
            : null;

    final composedAttributes = composeAttributes(oldAttributes, attributes);
    final composedDelta = composedAttributes?[blockComponentDelta];
    composedAttributes?.remove(blockComponentDelta);

    final blockAction = BlockActionDoc(
      action: BlockActionTypeDoc.update,
      block: BlockDoc(
        id: node.id,
        ty: node.type,
        // I am using compose attributes to say that I had changed all attributes at once
        // So that we don't have some wierd combinations of attributes
        attributes: composedAttributes?.toMap() ?? {},
        delta: diff,
        parentId: parentId,
      ),
      path: Uint32List.fromList(path.toList()),
    );

    actions.add(blockAction);

    return actions;
  }
}

extension on DeleteOperation {
  List<BlockActionDoc> toBlockAction(EditorStateWrapper editorStateWrapper) {
    final actions = <BlockActionDoc>[];
    for (final node in nodes) {
      final parentId =
          TransactionAdapterHelpers.parentFromPath(
            editorStateWrapper.editorState.document,
            node.path,
          ).id;
      // final parentId =
      //     node.parent?.id ??
      //     editorStateWrapper.getNodeAtPath(path.parent)?.id ??
      //     '';
      assert(parentId.isNotEmpty);

      final blockAction = BlockActionDoc(
        action: BlockActionTypeDoc.delete,
        block: BlockDoc(
          id: node.id,
          ty: node.type,
          attributes: {},
          parentId: parentId,
        ),
        path: Uint32List.fromList(path.toList()),
      );

      actions.add(blockAction);
    }
    return actions;
  }
}
