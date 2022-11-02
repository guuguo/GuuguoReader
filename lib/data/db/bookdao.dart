import 'package:floor/floor.dart';
import 'package:read_info/bean/db/source_db.dart';

import '../../bean/book_item_bean.dart';

@dao
abstract class BookDao {
  @Query('SELECT * FROM BookDetailBean order by updateAt desc')
  Future<List<BookDetailBean>> findAllBooks();

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<int> insertSource(BookDetailBean bean);

  @delete
  Future<int> deleteSource(BookDetailBean bean);

  @Query('SELECT * FROM BookChapterBean where bookId = :bookId order by chapterIndex asc')
  Future<List<BookChapterBean>> findBookChapters(String bookId);

  @Query('SELECT * FROM ChapterContent where chapter_id = :id')
  Future<ChapterContent?> findChapterContentById(String id);

  @Query('DELETE FROM BookChapterBean where bookId = :bookId ')
  Future<int?> deleteBookChapters(String bookId);

  @Query('DELETE FROM ChapterContent where bookId = :bookId')
  Future<int?> deleteBookContents(String bookId);

  @Query('SELECT * FROM BookDetailBean where name = :bookName')
  Future<List<BookDetailBean>> queryBookDetail(String bookName);

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<int> insertBookChapter(BookChapterBean ban);

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<List<int>> insertBookChapters(List<BookChapterBean> list);

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<int> insertBookDetail(BookDetailBean bean);

  @update
  Future<int> updateChapter(BookChapterBean chapter);

  @Query('DELETE FROM ChapterContent where chapter_id = :chapterId')
  Future<int?> deleteChapterContent(String chapterId);

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<int> insertAndUpdateChapterContent(ChapterContent content);

  @update
  Future<int> updateBook(BookDetailBean bean);
  @delete
  Future<int> deleteBook(BookDetailBean bean);
}