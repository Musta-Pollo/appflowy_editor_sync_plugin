# AppFlowy Editor Sync Plugin

This library enables seamless content sharing for the AppFlowy text editor across devices and users. It leverages the CRDT (Conflict-free Replicated Data Type) structures from the yrs library to merge changes from multiple devices consistently, ensuring identical results regardless of the order or frequency of updates.

**Full offline support**

## Demo 

More details about the demo here with custom synchronization: https://github.com/Musta-Pollo/custom_supabase_drift_doc_sync



https://github.com/user-attachments/assets/96112d49-d693-4887-b17c-4fa0f6e54f05

The demo is slightly longer because it is a live demonstration that requires turning the Wi-Fi on and off. This demo functions well across all other Flutter platforms and Wear OS when properly configured.

## How It Works

Init the plugin inside main:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppflowyEditorSyncUtilityFunctions.initAppFlowyEditorSync();

  runApp(App());
}
```

Override three methods to handle document update storage and retrieval:

```dart
@Riverpod(keepAlive: true)
class EditorStateWrapper extends _$EditorStateWrapper {
...
@override
FutureOr<EditorState> build(String docId) {
    final wrapper = EditorStateSyncWrapper(
      syncAttributes: SyncAttributes(
      /// Provide all editor updates or initialize the editor, save the updates
      /// and return them.
      /// See: [AppflowyEditorSyncUtilityFunctions]
      getInitialUpdates: () async {
      ...
      },
      getUpdatesStream: ...,

      saveUpdate: (Uint8List update) async {
        ...
        },
      ),
    );

    return wrapper.initAndHandleChanges();

}
}
```

Pass the resulting EditorState to the AppFlowy text editor. See the example for details.

## Initialization

When creating a document, initialize it using one of the following methods from `AppflowyEditorSyncUtilityFunctions`:

`initDocument`
`initDocumentFromExistingDocument`
`initDocumentFromExistingMarkdownDocument`

These methods set up the default document structure for future updates.

## Web

To use the plugin on the web you need to do copy the code from the package `web/pkg` into you project `web/pkg` folder. And provide html headers:

- `Cross-Origin-Opener-Policy=same-origin`
- `web-header=Cross-Origin-Embedder-Policy=require-corp`

Usefull resources:

- https://cjycode.com/flutter_rust_bridge/quickstart#3-run-it
- https://cjycode.com/flutter_rust_bridge/manual/integrate/template/setup/web

This is neccessary as the package relies on flutter_rust_bridge.

## Behind the Scenes

The library builds on AppFlowy’s approach to convert transactions into structures compatible with the Rust-based yrs library, maintaining a synchronized copy of the text editor. Changes are reflected in yrs CRDT structures, ensuring consistent state across devices.
However, CRDT alone may produce unexpected results when users’ changes interleave. For example:

### User A (offline):

- 111 - User A
- 222 - User A
- 333 - User A

### User B (offline):

- 111 - User B
- 222 - User B
- 333 - User B

When both devices sync, a naive CRDT merge might yield:

- 111 - User A
- 111 - User B
- 222 - User A
- 333 - User A

This is not user-friendly. To address this, each text node (line) includes additional attributes:

- deviceId
- timestamp

And pointers:

- prevId (for reflection and sorting)
- nextId (for CRDT reflection)

Using these, the plugin sorts nodes to produce a user-expected merge, such as:

- 111 - User A
- 222 - User A
- 333 - User A
- 111 - User B
- 222 - User B
- 333 - User B

Or:

- 111 - User B
- 222 - User B
- 333 - User B
- 111 - User A
- 222 - User A
- 333 - User A

For conflicts (e.g., multiple nodes with the same prevId), the sorting algorithm uses timestamp and deviceId to resolve ordering. This logic is implemented in rust/src/doc/utils/sorting.rs.
