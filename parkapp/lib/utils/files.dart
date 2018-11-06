import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

/// Responsible for getting a File object which represents a file in a certain path (existing or not) on the
/// device's filesystem
class Files {
  static Future<File> getFile(String pathInApp) {
    return getApplicationDocumentsDirectory().then((Directory directory){
      if(directory == null) {
        throw new Exception('Application path could not be found.');
      }
      return new File("${directory.path}/$pathInApp");
    });
  }
}