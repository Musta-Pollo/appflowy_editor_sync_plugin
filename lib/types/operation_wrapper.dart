// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:fpdart/fpdart.dart';

enum OperationWrapperType { Insert, Delete, Move, Update }

// abstract interface class OptionalWrapperInterface {
//   BlockActionDoc toBlockAction(
//     EditorStateWrapper editorStateWrapper,
//     String documentId,
//   );
// }

class OperationWrapper {
  final OperationWrapperType type;
  OperationWrapper({
    required this.type,
    required this.firstOperation,
    required this.optionalSecondOperation,
  });

  final Operation firstOperation;

  /// It only applies if [type] is [OperationWrapperType.Move]
  final Option<Operation> optionalSecondOperation;
}
