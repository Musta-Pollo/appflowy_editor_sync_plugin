// ignore_for_file: public_member_api_docs, sort_constructors_first
// editor_state_sync_wrapper.dart
import 'dart:async';

import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor_sync_plugin/convertors/transaction_adapter_helpers.dart';
import 'package:appflowy_editor_sync_plugin/core/update_clock.dart';
import 'package:appflowy_editor_sync_plugin/document_initializer.dart';
import 'package:appflowy_editor_sync_plugin/document_service_helpers/document_rules.dart';
import 'package:appflowy_editor_sync_plugin/document_service_helpers/document_service_wrapper.dart';
import 'package:appflowy_editor_sync_plugin/document_sync_db.dart';
import 'package:appflowy_editor_sync_plugin/editor_state_helpers/editor_state_wrapper.dart';
import 'package:appflowy_editor_sync_plugin/extensions/list_of_updates_extensions.dart';
import 'package:appflowy_editor_sync_plugin/extensions/list_op_operations.dart';
import 'package:appflowy_editor_sync_plugin/types/sync_db_attributes.dart';
import 'package:appflowy_editor_sync_plugin/types/update_types.dart';
import 'package:appflowy_editor_sync_plugin/utils/debug_print_custom.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uuid/uuid.dart';

/// Wrapper around [EditorState] that handles document synchronization.
/// [SyncAttributes] defines how to get, and save document updates
/// Inside it is listening on DB updates and editor updates
/// a. Editor Updates are reflected in CRDT structure on the Rust side and updates are saved to the DB
/// b. DB updates are combined into a CRDT structure and then the editor is updated to reflect changes that it misses

class EditorStateSyncWrapper {
  EditorStateSyncWrapper({
    required this.syncAttributes,
    this.syncDebounceDelay = const Duration(milliseconds: 1500),
    this.updatesBatcherDebounceDuration = const Duration(milliseconds: 500),
  });

  /// Definition of DB operations that the editor works with.
  final SyncAttributes syncAttributes;

  /// Determines how frequently remote changes are applied to the editor.
  /// This duration controls the delay between detecting remote updates and
  /// merging them with the local document. After merging, the current editor state
  /// is compared to the updated document, and only the necessary changes are applied.
  final Duration syncDebounceDelay;

  /// Controls how frequently local changes are committed to the database.
  /// Local updates are collected in batches to optimize storage and reduce
  /// database operations. This duration defines how long updates accumulate
  /// before they are consolidated and saved as a single database transaction.
  final Duration updatesBatcherDebounceDuration;

  late final DocumentServiceWrapper docService;
  late final DocumentSyncDB syncDB;
  late final DocumentInitializer initializer;
  late final EditorStateWrapper editorStateWrapper;
  late final DocumentRules documentRules;
  final mapEquality = const DeepCollectionEquality();
  bool isSyncing = false;

  final String _syncProcessingTag = 'sync_processing_${Uuid().v4()}';

  (List<LocalUpdate>, List<DbUpdate>)? pendingSyncUpdates;

  UpdateClock updateClock = UpdateClock();

  Future<EditorState> initAndHandleChanges() async {
    docService = await DocumentServiceWrapper.newInstance();
    initializer = DocumentInitializer(documentService: docService);
    syncDB = DocumentSyncDB(
      docService: docService,
      syncAttributes: syncAttributes,
      updatesBatcherDebounceDuration: updatesBatcherDebounceDuration,
    );

    editorStateWrapper = await _init();

    // Logic to synchronize document with database
    _listenOnDBUpdates();
    _listenOnEditorUpdates();

    documentRules = DocumentRules(editorState: editorStateWrapper.editorState);

    return editorStateWrapper.editorState;
  }

  Future<void> dispose() async {
    EasyDebounce.cancel(_syncProcessingTag);
    await syncDB.dispose();
  }

  Future<EditorStateWrapper> _init() async {
    final documentUpdates = await syncDB.getInitialUpdates();
    if (documentUpdates.isEmpty) {
      final (editorStateWrapper, updates) =
          await initializer.initEmptyDocument();

      final newClock = updateClock.incrementClock();
      syncDB.addUpdates(
        updates.map((e) => LocalUpdate(update: e, id: newClock)).toList(),
      );
      return editorStateWrapper;
    } else {
      final editorStateWrapper = await initializer.initDocumentWithUpdates(
        documentUpdates,
      );
      return editorStateWrapper;
    }
  }

  void _listenOnDBUpdates() {
    syncDB.getAllUpdatesStream().listen((data) async {
      if (isSyncing) {
        pendingSyncUpdates = data;
        return;
      }

      await _startSyncOperation(data);
    });
  }

  Future<void> _startSyncOperation(
    (List<LocalUpdate>, List<DbUpdate>) updates,
  ) async {
    isSyncing = true;

    try {
      await _processSyncOperation(updates);
    } finally {
      isSyncing = false;

      // Check if new updates arrived during processing
      final pending = pendingSyncUpdates;
      if (pending != null) {
        pendingSyncUpdates = null;
        await _startSyncOperation(pending);
      }
    }
  }

  // Modify _processSyncOperation to use EasyDebounce
  Future<void> _processSyncOperation(
    (List<LocalUpdate>, List<DbUpdate>) updates,
  ) async {
    // Create a completer to make this method awaitable
    final completer = Completer<void>();

    // Use EasyDebounce to delay the actual processing
    EasyDebounce.debounce(_syncProcessingTag, syncDebounceDelay, () async {
      // Perform the actual processing
      try {
        await _actualProcessSync(updates);
        completer.complete();
      } catch (e) {
        completer.completeError(e);
      }
    });

    // Wait for the debounced operation to complete
    return completer.future;
  }

  // What I need to guraentee:
  // If the sync is executed, I have all local updates + db updates available, including updates
  // for the latest state of the document.

  Future<void> _actualProcessSync(
    (List<LocalUpdate>, List<DbUpdate>) updates,
  ) async {
    //Check if I have latest update // Or if it is not in
    if (!updates.$1.syncCanBeDone(updateClock)) {
      return;
    }

    try {
      await docService.applyUpdates(
        update:
            updates.$1.map((e) => e.update).toList() +
            updates.$2.map((e) => e.update).toList(),
      );
    } catch (e) {
      print(e);
    }
    //Check if I have latest update // Or if it is not in
    if (!updates.$1.syncCanBeDone(updateClock)) {
      return;
    }

    final result = await docService.getDocumentJson();

    //Check if I have latest update
    if (!updates.$1.syncCanBeDone(updateClock)) {
      return;
    }

    // Create a new state from the current document and apply operations
    // that were not yet recorded in that CRDT Document
    final newEditorStateWrapper = EditorStateWrapper.factoryFromDocumentState(
      result,
    );

    final diffOperations = editorStateWrapper.diffEditorStateWrappers(
      newEditorStateWrapper,
    );
    if (diffOperations.isEmpty) {
      return;
    }

    if (diffOperations.isNotEmpty) {
      // Apply the operations to the editor state
      editorStateWrapper.applyRemoteChanges(diffOperations);
      // _prettyfyAndPrintInChunksDocumentState(result);

      debugPrintCustom(
        "Applied ${diffOperations.length} operations to the editor state",
      );
    }
  }

  // void _prettyfyAndPrintInChunksDocumentState(DocumentState docState) {
  //   final json = docState.toJson();
  //   final prettyJson = JsonEncoder.withIndent('  ').convert(json);
  //   final lines = prettyJson.split('\n');
  //   for (var line in lines) {
  //     debugPrintCustom(line);
  //   }
  // }

  void _listenOnEditorUpdates() {
    editorStateWrapper.listenEditorChanges().listen((data) async {
      final (transactionTime, transaction, options) = data;

      if (TransactionTime.before != transactionTime) {
        return;
      }

      if (transaction.operations.isEmpty) {
        return;
      }
      // Convert editor changes into special actions that have neccessary data
      // to be applied on the Rust side
      final currentDocumentCopy = editorStateWrapper.currentDocumentCopy();
      final operationsCopy = transaction.operations.deepCopy();
      final actions = TransactionAdapterHelpers.operationsToBlockActions(
        operationsCopy,
        currentDocumentCopy,
      );

      // Increase update clock - used to make sure that all local changes are present
      // when applying remote changes
      final newClock = updateClock.incrementClock();

      // Apply the changes to the CRDT document
      final update = await docService.applyAction(actions: actions);
      await update.match(() async {}, (update) async {
        // Validates the document state and applies fixes if needed
        unawaited(documentRules.applyRules(value: data));
        syncDB.addUpdates([LocalUpdate(update: update, id: newClock)]);
      });

      // Check for document rules
    });
  }
}
