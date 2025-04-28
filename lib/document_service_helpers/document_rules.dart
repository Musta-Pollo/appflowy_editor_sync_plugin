import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor_sync_plugin/convertors/custom_diff.dart';

/// Apply rules to the document
///
/// 1. ensure there is at least one paragraph in the document, otherwise the user will be blocked from typing
/// 2. ensure that nodes with attribute of type: heading* dont have children. The children should be moved after the heading node in the document structure.
class DocumentRules {
  DocumentRules({required this.editorState});

  final EditorState editorState;

  Future<void> applyRules({required EditorTransactionValue value}) async {
    await Future.wait([
      _ensureAtLeastOneParagraphExists(value: value),
      _ensureNoChildrenForHeadingNodes(value: value),
    ]);
  }

  Future<void> _ensureAtLeastOneParagraphExists({
    required EditorTransactionValue value,
  }) async {
    final document = editorState.document;
    if (document.root.children.isEmpty) {
      final transaction = editorState.transaction;
      transaction
        ..insertNode([0], paragraphNode())
        ..afterSelection = Selection.collapsed(Position(path: [0]));
      await editorState.apply(transaction);
    }
  }

  /// Ensure that nodes with attribute of type: heading* dont have children.
  /// The children should be moved after the heading node in the document structure.
  Future<void> _ensureNoChildrenForHeadingNodes({
    required EditorTransactionValue value,
  }) async {
    final document = editorState.document;
    final transaction = editorState.transaction;

    // Find all heading nodes with children
    final headingNodes = <Node>[];
    void findHeadingNodesWithChildren(Node node) {
      if (node.type.startsWith('heading') && node.children.isNotEmpty) {
        headingNodes.add(node);
      } else {
        for (final child in node.children) {
          findHeadingNodesWithChildren(child);
        }
      }
    }

    findHeadingNodesWithChildren(document.root);

    final operations = <Operation>[];

    // Process each heading node - move its children after it
    for (final headingNode in headingNodes) {
      final headingPath = headingNode.path;
      final parentPath = headingPath.parent;
      final insertPosition = headingPath.last + 1;

      final childrenCopy = List<Node>.from(
        headingNode.children.map((e) => Node.fromJson(e.toJson())),
      );

      // Create a delete operation for all children at once
      if (headingNode.children.isNotEmpty) {
        final deleteOperation = DeleteOperation(
          [...headingPath, 0], // Start at the first child
          List.from(headingNode.children), // Use original nodes for deletion
        );
        operations.add(deleteOperation);
      }

      final targetPath = [...parentPath, insertPosition];

      operations.add(InsertOperation(targetPath, childrenCopy));
    }

    // Add all operations to the transaction
    for (final operation in operations) {
      transaction.add(operation);
    }

    if (transaction.operations.isEmpty) {
      return;
    }

    final prevOperations = transaction.operations;

    final adjustedOperations = adjustOperations(transaction.operations);
    transaction.operations.clear();
    transaction.operations.addAll(adjustedOperations);

    await editorState.apply(transaction);
  }
}
