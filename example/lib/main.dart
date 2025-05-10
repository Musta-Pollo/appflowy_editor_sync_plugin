// main.dart
import 'dart:typed_data';

import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor_sync_plugin/appflowy_editor_sync_plugin.dart';
import 'package:appflowy_editor_sync_plugin/types/sync_db_attributes.dart';
import 'package:appflowy_editor_sync_plugin/types/update_types.dart';
import 'package:appflowy_editor_sync_plugin_example/desktop_editor.dart';
import 'package:appflowy_editor_sync_plugin_example/mobile_editor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:universal_platform/universal_platform.dart';

part 'main.g.dart';

// ====================
// Models
// ====================
@Collection()
class Document {
  late int id;
  String? name;
  DateTime? createdAt;
}

@Collection()
class DocumentData {
  late int id;
  List<int>? data;
  int? documentId;
}

// ====================
// Providers
// ====================
@Riverpod(keepAlive: true)
Isar isar(Ref ref) {
  throw UnimplementedError('Isar provider must be overridden');
}

@Riverpod(keepAlive: true)
class Documents extends _$Documents {
  Isar get _isar => ref.read(isarProvider);

  @override
  List<Document> build() => _isar.documents.where().findAll();

  Future<void> addDocument(String name) async {
    final doc =
        Document()
          ..name = name
          ..createdAt = DateTime.now()
          ..id = _isar.documents.autoIncrement();
    _isar.write((isar) async {
      isar.documents.put(doc);
    });
    ref.invalidateSelf();
  }

  Future<void> deleteDocument(int id) async {
    await _isar.write((isar) async {
      isar.documents.delete(id);
      isar.documentDatas.where().documentIdEqualTo(id).deleteAll();
    });
    ref.invalidateSelf();
  }
}

@riverpod
List<DocumentData> docData(Ref ref, {required int docId}) {
  return ref
      .read(isarProvider)
      .documentDatas
      .where()
      .documentIdEqualTo(docId)
      .findAll();
}

@riverpod
Document doc(Ref ref, {required int docId}) {
  return ref.read(isarProvider).documents.get(docId)!;
}

@riverpod
class EditorStateWrapper extends _$EditorStateWrapper {
  Isar get _isar => ref.read(isarProvider);

  @override
  FutureOr<EditorState> build(String docId) {
    final wrapper = EditorStateSyncWrapper(
      updatesBatcherDebounceDuration: Duration(milliseconds: 2000),
      syncAttributes: SyncAttributes(
        getInitialUpdates: () async {
          final data =
              _isar.documentDatas
                  .where()
                  .documentIdEqualTo(int.parse(docId))
                  .findAll();
          return data.map((e) {
            return DbUpdate(
              update: Uint8List.fromList(e.data!),
              id: e.id.toString(),
            );
          }).toList();
        },
        getUpdatesStream: _isar.documentDatas
            .where()
            .documentIdEqualTo(int.parse(docId))
            .watch(fireImmediately: true)
            .asyncMap((data) {
              return data
                  .map(
                    (e) => DbUpdate(
                      update: Uint8List.fromList(e.data!),
                      id: e.id.toString(),
                    ),
                  )
                  .toList();
            }),
        saveUpdate: (Uint8List update) async {
          final docData =
              DocumentData()
                ..data = update
                ..documentId = int.parse(docId)
                ..id = _isar.documentDatas.autoIncrement();
          await _isar.write((isar) async {
            isar.documentDatas.put(docData);
          });
        },
      ),
    );

    ref.onDispose(wrapper.dispose);

    return wrapper.initAndHandleChanges();
  }
}

// ====================
// Main App
// ====================
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final dir = await getApplicationDocumentsDirectory();
  final isar = Isar.open(
    directory: dir.path,
    engine: IsarEngine.isar,
    name: 'appflowy_editor_2',
    schemas: [DocumentSchema, DocumentDataSchema],
  );
  await AppflowyEditorSyncUtilityFunctions.initAppFlowyEditorSync();

  runApp(
    ProviderScope(
      overrides: [isarProvider.overrideWithValue(isar)],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Document Editor',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const DocumentListView(),
    );
  }
}

// ====================
// Views
// ====================
class DocumentListView extends ConsumerWidget {
  const DocumentListView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final documents = ref.watch(documentsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Documents')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateDialog(ref),
        child: const Icon(Icons.add),
      ),
      body: ListView.builder(
        itemCount: documents.length,
        itemBuilder:
            (context, index) => ListTile(
              title: Text(documents[index].name ?? ""),
              onTap:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => DocumentEditorScreen(
                            docId: documents[index].id.toString(),
                          ),
                    ),
                  ),
              trailing: IconButton(
                icon: const Icon(Icons.delete),
                onPressed:
                    () => ref
                        .read(documentsProvider.notifier)
                        .deleteDocument(documents[index].id),
              ),
            ),
      ),
    );
  }

  void _showCreateDialog(WidgetRef ref) {
    final controller = TextEditingController();
    showDialog(
      context: ref.context,
      builder:
          (context) => AlertDialog(
            title: const Text('New Document'),
            content: TextField(controller: controller),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  ref
                      .read(documentsProvider.notifier)
                      .addDocument(controller.text);
                  Navigator.pop(context);
                },
                child: const Text('Create'),
              ),
            ],
          ),
    );
  }
}

class DocumentEditorScreen extends ConsumerWidget {
  final String docId;

  const DocumentEditorScreen({super.key, required this.docId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editing Document $docId'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer(
        builder: (context, ref, child) {
          final editorState = ref.watch(editorStateWrapperProvider(docId));
          return editorState.when(
            data: (editorState) {
              if (UniversalPlatform.isDesktopOrWeb) {
                return DesktopEditor(editorState: editorState);
              }
              return MobileEditor(editorState: editorState);
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(child: Text('Error: $error')),
          );
        },
      ),
    );
  }
}
