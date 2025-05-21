import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor_sync_plugin/extensions/document_extensions.dart';

/// Extension to split operations with multiple nodes into operations with single nodes
extension OperationSplitter on List<Operation> {
  /// Splits operations with multiple nodes into multiple operations with one node each
  List<Operation> splitIntoSingleNodeOperations() {
    final result = <Operation>[];

    for (final operation in this) {
      if (operation is DeleteOperation && operation.nodes.length > 1) {
        // Split delete operation
        for (int i = 0; i < operation.nodes.length; i++) {
          final node = operation.nodes.elementAt(i);
          final path = [...operation.path];
          if (i > 0) {
            path.last += i;
          }

          result.add(DeleteOperation(path, [node]));
        }
      } else if (operation is InsertOperation && operation.nodes.length > 1) {
        // Split insert operation
        for (int i = 0; i < operation.nodes.length; i++) {
          final node = operation.nodes.elementAt(i);
          final path = [...operation.path];
          if (i > 0) {
            path.last += i;
          }
          result.add(InsertOperation(path, [node]));
        }
      } else {
        // Keep operations with single node as is
        result.add(operation);
      }
    }

    return result;
  }

  List<Operation> sortOperations() {
    sort((a, b) {
      if (a is UpdateOperation && b is! UpdateOperation) {
        return -1; // Update comes first
      } else if (a is! UpdateOperation && b is UpdateOperation) {
        return 1; // Update comes second (b before a)
      } else if (a is DeleteOperation && b is InsertOperation) {
        return -1; // Delete comes before Insert
      } else if (a is InsertOperation && b is DeleteOperation) {
        return 1; // Delete comes before Insert
      }
      return 0; // Keep original order for other cases
    });

    return this;
  }

  /// Deep copy
  List<Operation> deepCopy() {
    return map((operation) {
      if (operation is InsertOperation) {
        // Clone nodes using toJsonWithIds() and fromJsonWithIds()
        final nodesJson =
            operation.nodes.map((node) => node.toJsonWithIds()).toList();
        final clonedNodes =
            nodesJson
                .map((json) => NodeExtensionsCustom.fromJsonWithIds(json))
                .toList();
        return InsertOperation([...operation.path], clonedNodes);
      } else if (operation is DeleteOperation) {
        // Clone nodes using toJsonWithIds() and fromJsonWithIds()
        final nodesJson =
            operation.nodes.map((node) => node.toJsonWithIds()).toList();
        final clonedNodes =
            nodesJson
                .map((json) => NodeExtensionsCustom.fromJsonWithIds(json))
                .toList();
        return DeleteOperation([...operation.path], clonedNodes);
      } else if (operation is UpdateOperation) {
        // Deep copy the attributes maps
        return UpdateOperation(
          [...operation.path],
          Map<String, dynamic>.from(operation.attributes),
          Map<String, dynamic>.from(operation.oldAttributes),
        );
      } else if (operation is UpdateTextOperation) {
        // Clone delta objects
        return UpdateTextOperation(
          [...operation.path],
          Delta.fromJson(operation.delta.toJson()),
          Delta.fromJson(operation.inverted.toJson()),
        );
      }
      throw Exception('Unknown operation type: ${operation.runtimeType}');
    }).toList();
  }
}
