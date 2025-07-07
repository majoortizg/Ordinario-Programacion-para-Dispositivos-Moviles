import 'package:recuerdos_ordinario3/recuerdo.dart';
import 'package:sqflite/sqflite.dart';

import 'dba.dart';
import 'package:recuerdos_ordinario3/recuerdo.dart';
import 'package:sqflite/sqflite.dart';

class RecuerdoDA {
  late DatabaseHelper dbh;
  Database? db;

  RecuerdoDA() {
    dbh = DatabaseHelper();
  }

  Future<void> insert(Recuerdo item) async {
    db ??= await dbh.database;
    item.Id = await dbh.getMaxNumeroOrDefault('recuerdos', 'Id') + 1;

    await db?.insert(
      'recuerdos',
      item.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Recuerdo>> getAllItems() async {
    db ??= await dbh.database;
    List<Recuerdo> ls = [];
    final List<Map<String, Object?>>? itemsMap = await db?.query('recuerdos');

    for (final item in itemsMap!) {
      ls.add(
        Recuerdo(
          Descripcion: item['Descripcion'] as String? ?? '',
          FotoPath: item['FotoPath'] as String? ?? '',
          Id: item['Id'] as int? ?? 0,
          Latitud: item['Latitud'] as double? ?? 0.0,
          Longitud: item['Longitud'] as double? ?? 0.0,
          Nombre: item['Nombre'] as String? ?? '',
          Sincronizado: item['Sincronizado'] as int? ?? 0,
        ),
      );
    }
    return ls;
  }

  Future<void> update(Recuerdo item) async {
    db ??= await dbh.database;
    print("UPDATE -> Id: ${item.Id}, Data: ${item.toJson()}");

    int result = await db!.update(
      'recuerdos',
      item.toJson(),
      where: 'Id = ?',
      whereArgs: [item.Id],
    );
    print("Filas Actualizadas: $result");
  }

  Future<void> deleteDog(int id) async {
    db ??= await dbh.database;

    await db?.delete(
      'recuerdos',
      where: 'Id = ?',
      whereArgs: [id],
    );
  }
}
