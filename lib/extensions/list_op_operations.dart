import 'package:appflowy_editor/appflowy_editor.dart';

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
}
