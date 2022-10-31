// 必须的包
import 'dart:async';
import 'package:floor/floor.dart';
import 'package:path/path.dart';
import 'package:read_info/bean/book_item_bean.dart';
import 'package:read_info/data/db/bookdao.dart';
import 'package:read_info/data/db/sourcedao.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

import '../../bean/db/source_db.dart';

part 'mydatabase.g.dart';

// 执行命令 flutter pub run build_runner build --delete-conflicting-outputs
@Database(version: 10, entities: [Source, BookDetailBean, BookChapterBean, ChapterContent])
abstract class MyDataBase extends FloorDatabase {
  SourceDao get sourceDao;

  BookDao get bookDao;
}

// create migration
final migration6to7 = Migration(6, 7, (database) async {
  database.execute("alter table ChapterContent add column bookId text");
});
final migration7to8 = Migration(7, 8, (database) async {
  database.execute("alter table BookDetailBean add column updateAt INTEGER");
});
final m8to9 = Migration(8, 9, (database) async {
  database.execute("CREATE UNIQUE INDEX index_chapter on BookChapterBean (bookId,chapterName)");
  database.execute("CREATE UNIQUE INDEX index_chapter_content on ChapterContent (chapter_id)");
});
final m9to10 = Migration(9, 10, (database) async {
  database.execute("alter table BookChapterBean add column cached BOOLEAN");
});
final applyMigration = [
  migration6to7,
  migration7to8,
  m8to9,
  m9to10,
];
