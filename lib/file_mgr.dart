import 'dart:async';
import 'dart:io';

//import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class FileManagerStorage {
  String fileName;

  FileManagerStorage(this.fileName);

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/${fileName}');
  }

  Future<String> readFromFile() async {
    try {
      final file = await _localFile;
      final contents = await file.readAsString();
      return contents;
    } catch (e) {
      return e.toString();
    }
  }

  Future<File> writeToFile(String data) async {
    final file = await _localFile;
    return file.writeAsString(data);
  }
}
