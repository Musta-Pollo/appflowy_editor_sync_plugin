import 'dart:typed_data';

class LocalUpdate {
  final Uint8List update;
  final String id;
  LocalUpdate({required this.update, required this.id});
}

class DbUpdate {
  final Uint8List update;
  final String id;
  DbUpdate({required this.update, required this.id});
}
