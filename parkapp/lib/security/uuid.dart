// External imports.
import 'dart:async';
import 'dart:io';
import 'package:uuid/uuid.dart' as DartUUID;

// External imports.
import '../utils/files.dart';

class Uuid {
  static Uuid _instance = new Uuid._internal();
  Uuid._internal();
  factory Uuid() => _instance;

  static const String _UUID_FILE_NAME = "uuid.txt";

  String id;

  void generate() {
    this.id = new DartUUID.Uuid().v4();
  }

  Future<void> save([bool rewrite = false]) {
    return Files.getFile(_UUID_FILE_NAME).then((File uuidFile) {
      if(!uuidFile.existsSync() || rewrite) {
        uuidFile.writeAsStringSync(this.id);
      }
    });
  }

  Future<void> load() {
    return Files.getFile(_UUID_FILE_NAME).then((File uuidFile) {
      return uuidFile.readAsString().then((id) {
        this.id = id;
      });
    });
  }

  Future<bool> exists() {
    return Files.getFile(_UUID_FILE_NAME).then((File uuidFile) {
      return uuidFile.existsSync();
    });
  }
}