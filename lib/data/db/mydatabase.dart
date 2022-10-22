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
@Database(version: 5, entities: [Source,BookDetailBean,BookChapterBean,ChapterContent])
abstract class MyDataBase extends FloorDatabase{
  SourceDao get sourceDao;
  BookDao get bookDao;
}

// create migration
final migration3to4 = Migration(3, 4, (database) async {
});
// create migration
final migration4to5 = Migration(4, 5, (database) async {
});
final applyMigration=[migration3to4,migration4to5];