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

/// I want to create a pipiline that will accept list of [Operation] or [Transaction]
/// And will convert that to list of [BlockActionDoc]
///
/// The first step in the pipeline is to convert [Operation] to [OperationWrapper]
/// - This involves combining [InsertOperation] and [DeleteOperation] into [MoveOperation] when they are after each other
/// The second step is to convert the list of [OperationWrapper] into a map of {nodeId: OperationWrapper[]}
/// The third step is to simplify list where would be following conditions:
/// - If there are both [OpertionWrapperType.Insert] and [OpertionWrapperType.Delete] for the same node, all operations for that nodeId should be removed
/// If there is [OperationWrapperType.Delete], then there should be only delete
/// If there are both [OperationWrapperType.Insert] and [OperationWrapperType.Update], they should be combined into one insert, where the attributes shoudl be kept the ones inside the update and the delta the one from the update
/// If there are multiple [OperationWrapperType.Update], the firtOne and the lastOne should be kept so that I can compute the differennce between them
/// If there are multiple [OperationWrapperType.Move], the firstOne and the lastOne should be kept so that I can compute the differennce between them
/// The fourth step is to convert the map of {nodeId: OperationWrapper[]} into list of [BlockActionDoc]
///
/// I would like to some some intermediate structure to store the date before the final stage
