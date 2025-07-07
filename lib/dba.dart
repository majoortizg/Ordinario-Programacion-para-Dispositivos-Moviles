import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  Database? _database;

  Future<Database> get database async {
    if (_database == null) {
      await initDatabase();
    }
    return _database!;
  }

  Future<void> initDatabase() async {
    _database = await openDatabase(
      join(await getDatabasesPath(), 'recuerdos_database.db'), // ✅ nombre actualizado
      onCreate: (db, version) {
        db.execute(
          'CREATE TABLE recuerdos (Id INTEGER PRIMARY KEY, Nombre TEXT, '
              'Descripcion TEXT, FotoPath TEXT, Latitud REAL, '
              'Longitud REAL, Sincronizado INTEGER)',
        );
      },
      version: 1,
    );
  }

  Future<int> getMaxNumeroOrDefault(String tableName, String columnName) async {
    final String query =
        'SELECT COALESCE(MAX($columnName), 0) AS max_numero FROM $tableName';

    final db = await database; // ✅ se asegura que DB esté inicializada
    final List<Map<String, Object?>> result = await db.rawQuery(query);

    if (result.isNotEmpty) {
      final maxValue = result.first['max_numero'];
      if (maxValue is int) return maxValue;
      if (maxValue is double) return maxValue.toInt();
    }
    return 0;
  }
}
