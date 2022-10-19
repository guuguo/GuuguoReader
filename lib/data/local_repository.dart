import 'dart:convert';

import 'package:floor/floor.dart';
import 'package:read_info/data/db/mydatabase.dart';
import 'package:uuid/uuid.dart';

import '../bean/book_item_bean.dart';
import '../bean/db/source_db.dart';
import '../bean/entity/source_entity.dart';


class LocalRepository {
  static Future<MyDataBase> database() async {
    final database = await $FloorMyDataBase.databaseBuilder('app_database.db').addMigrations([migration1to2]).build();

    return database;
  }

  ///
  static Future<List<SourceEntity>> getSourceList() async {
    var myDataBase = await database();
    var res = await myDataBase.sourceDao.findAllSources();
    return res.map((e) => SourceEntity.fromJson(json.decode(e.detail.toString()))).toList();
  }

  static Future insertOrUpdateSource(SourceEntity entity) async {
    var myDataBase = await database();
    await myDataBase.sourceDao.insertSource(Source(bookSourceUrl: entity.bookSourceUrl!, detail: json.encode(entity.toJson())));
  }

  static Future deleteSource(SourceEntity entity) async {
    var myDataBase = await database();
    await myDataBase.sourceDao.deleteSource(Source(bookSourceUrl: entity.bookSourceUrl!));
  }

  static Future<SourceEntity?> findSource(String? url) async {
    if (url == null) return null;
    var myDataBase = await database();
    var source = await myDataBase.sourceDao.findSource(url);
    return SourceEntity.fromJson(json.decode(source?.detail?.toString() ?? ""));
  }

  static Future<ChapterContent?> queryBookContent(String id) async {
    var myDataBase = await database();
    return await myDataBase.bookDao.findChapterContentById(id);
  }

  static Future updateChapterContent(BookChapterBean bean) async {
    var myDataBase = await database();
    if (bean.content != null) {
      await myDataBase.bookDao.insertAndUpdateChapterContent(bean.content!);
    }
  }

  static Future<List<BookChapterBean>> findBookChapters(BookDetailBean bean) async {
    var myDataBase = await database();
    return await myDataBase.bookDao.findBookChapters(bean.id ?? "");
  }

  static Future saveBookIfNone(BookDetailBean bean) async {
    var uuid=Uuid();
    var myDataBase = await database();
    if (bean.id == null) {
      bean.id = uuid.v1();
    }
    final insertCode = await myDataBase.bookDao.insertBookDetail(bean);
    if (insertCode == 0) return;
    bean.chapters?.forEach((e) {
      e.bookId = bean.id;
      e.id = uuid.v1();
    });
    await myDataBase.bookDao.insertBookChapters(bean.chapters ?? []);
  }

  static Future updateBook(BookDetailBean bean) async {
    var myDataBase = await database();
    await myDataBase.bookDao.updateBook(bean);
  }
}
