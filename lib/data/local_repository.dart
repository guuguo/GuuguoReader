import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:read_info/global/constant.dart';
import 'package:sqflite_common/sqlite_api.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../bean/entity/source_entity.dart';

class LocalRepository {
  static late Database db;

  static initTable() async {
    db = await _getDb();
    try {
      await db.execute('''
  CREATE TABLE Source (
      url TEXT PRIMARY KEY,
      detail TEXT 
  )
  ''');
    } catch (e) {}
  }

  static Future<Database> _getDb() async {
    var dir = await getApplicationDocumentsDirectory();
    return await databaseFactoryFfi
        .openDatabase(dir.path + Platform.pathSeparator + "local.db");
  }

  ///
  static Future<List<SourceEntity>> getSourceList() async {
    var res = await db.query("Source", columns: ["url", "detail"]);
    return res.map((e) =>
                SourceEntity.fromJson(json.decode(e['detail'].toString())))
            .toList();
  }

  static Future insertOrUpdateSource(SourceEntity entity) async {
    try {
      var result = await db.insert('Source', <String, Object?>{
        'url': entity.bookSourceUrl,
        'detail': json.encode(entity.toJson()),
      }, conflictAlgorithm: ConflictAlgorithm.replace,
      );

    }catch (e)  {
      print(e);
    }
  }

  static Future deleteSource(SourceEntity entity) async {
    try {
      await db.delete('Source', where:  "url = ?",whereArgs: [entity.bookSourceUrl]);
    } catch (e) {
      print(e);
    }
  }
}
