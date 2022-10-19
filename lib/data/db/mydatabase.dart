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
@Database(version: 3, entities: [Source,BookDetailBean,BookChapterBean,ChapterContent])
abstract class MyDataBase extends FloorDatabase{
  SourceDao get sourceDao;
  BookDao get bookDao;
}

// create migration
final migration1to2 = Migration(2, 3, (database) async {
  // await database.execute('PRAGMA writable_schema = 1');
  // await database.execute("delete from sqlite_master where type in ('table', 'index', 'trigger')");
  // await database.execute('PRAGMA writable_schema = 0');
});
