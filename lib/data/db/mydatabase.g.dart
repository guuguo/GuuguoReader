// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mydatabase.dart';

// **************************************************************************
// FloorGenerator
// **************************************************************************

// ignore: avoid_classes_with_only_static_members
class $FloorMyDataBase {
  /// Creates a database builder for a persistent database.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static _$MyDataBaseBuilder databaseBuilder(String name) =>
      _$MyDataBaseBuilder(name);

  /// Creates a database builder for an in memory database.
  /// Information stored in an in memory database disappears when the process is killed.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static _$MyDataBaseBuilder inMemoryDatabaseBuilder() =>
      _$MyDataBaseBuilder(null);
}

class _$MyDataBaseBuilder {
  _$MyDataBaseBuilder(this.name);

  final String? name;

  final List<Migration> _migrations = [];

  Callback? _callback;

  /// Adds migrations to the builder.
  _$MyDataBaseBuilder addMigrations(List<Migration> migrations) {
    _migrations.addAll(migrations);
    return this;
  }

  /// Adds a database [Callback] to the builder.
  _$MyDataBaseBuilder addCallback(Callback callback) {
    _callback = callback;
    return this;
  }

  /// Creates the database and initializes it.
  Future<MyDataBase> build() async {
    final path = name != null
        ? await sqfliteDatabaseFactory.getDatabasePath(name!)
        : ':memory:';
    final database = _$MyDataBase();
    database.database = await database.open(
      path,
      _migrations,
      _callback,
    );
    return database;
  }
}

class _$MyDataBase extends MyDataBase {
  _$MyDataBase([StreamController<String>? listener]) {
    changeListener = listener ?? StreamController<String>.broadcast();
  }

  SourceDao? _sourceDaoInstance;

  BookDao? _bookDaoInstance;

  Future<sqflite.Database> open(
    String path,
    List<Migration> migrations, [
    Callback? callback,
  ]) async {
    final databaseOptions = sqflite.OpenDatabaseOptions(
      version: 6,
      onConfigure: (database) async {
        await database.execute('PRAGMA foreign_keys = ON');
        await callback?.onConfigure?.call(database);
      },
      onOpen: (database) async {
        await callback?.onOpen?.call(database);
      },
      onUpgrade: (database, startVersion, endVersion) async {
        await MigrationAdapter.runMigrations(
            database, startVersion, endVersion, migrations);

        await callback?.onUpgrade?.call(database, startVersion, endVersion);
      },
      onCreate: (database, version) async {
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `Source` (`bookSourceUrl` TEXT, `detail` TEXT, PRIMARY KEY (`bookSourceUrl`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `BookDetailBean` (`id` TEXT NOT NULL, `name` TEXT, `intro` TEXT, `author` TEXT, `coverUrl` TEXT, `kind` TEXT, `lastChapter` TEXT, `tocUrl` TEXT, `sourceUrl` TEXT, `sourceSearchResult` TEXT, `readChapterIndex` INTEGER NOT NULL, `readPageIndex` INTEGER NOT NULL, `totalChapterCount` INTEGER NOT NULL, PRIMARY KEY (`id`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `BookChapterBean` (`id` TEXT NOT NULL, `bookId` TEXT, `chapterName` TEXT, `chapterUrl` TEXT, `chapterIndex` INTEGER NOT NULL, FOREIGN KEY (`bookId`) REFERENCES `BookDetailBean` (`id`) ON UPDATE NO ACTION ON DELETE CASCADE, PRIMARY KEY (`id`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `ChapterContent` (`id` TEXT NOT NULL, `chapter_id` TEXT NOT NULL, `content` TEXT NOT NULL, PRIMARY KEY (`id`))');
        await database.execute(
            'CREATE INDEX `index_BookDetailBean_name` ON `BookDetailBean` (`name`)');

        await callback?.onCreate?.call(database, version);
      },
    );
    return sqfliteDatabaseFactory.openDatabase(path, options: databaseOptions);
  }

  @override
  SourceDao get sourceDao {
    return _sourceDaoInstance ??= _$SourceDao(database, changeListener);
  }

  @override
  BookDao get bookDao {
    return _bookDaoInstance ??= _$BookDao(database, changeListener);
  }
}

class _$SourceDao extends SourceDao {
  _$SourceDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _sourceInsertionAdapter = InsertionAdapter(
            database,
            'Source',
            (Source item) => <String, Object?>{
                  'bookSourceUrl': item.bookSourceUrl,
                  'detail': item.detail
                }),
        _sourceDeletionAdapter = DeletionAdapter(
            database,
            'Source',
            ['bookSourceUrl'],
            (Source item) => <String, Object?>{
                  'bookSourceUrl': item.bookSourceUrl,
                  'detail': item.detail
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<Source> _sourceInsertionAdapter;

  final DeletionAdapter<Source> _sourceDeletionAdapter;

  @override
  Future<List<Source>> findAllSources() async {
    return _queryAdapter.queryList('SELECT * FROM Source',
        mapper: (Map<String, Object?> row) => Source(
            bookSourceUrl: row['bookSourceUrl'] as String?,
            detail: row['detail'] as String?));
  }

  @override
  Future<Source?> findSource(String url) async {
    return _queryAdapter.query('SELECT * FROM Source where bookSourceUrl = ?1',
        mapper: (Map<String, Object?> row) => Source(
            bookSourceUrl: row['bookSourceUrl'] as String?,
            detail: row['detail'] as String?),
        arguments: [url]);
  }

  @override
  Future<int> insertSource(Source bean) {
    return _sourceInsertionAdapter.insertAndReturnId(
        bean, OnConflictStrategy.replace);
  }

  @override
  Future<List<int>> insertSources(List<Source> bean) {
    return _sourceInsertionAdapter.insertListAndReturnIds(
        bean, OnConflictStrategy.replace);
  }

  @override
  Future<int> deleteSource(Source bean) {
    return _sourceDeletionAdapter.deleteAndReturnChangedRows(bean);
  }
}

class _$BookDao extends BookDao {
  _$BookDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _bookDetailBeanInsertionAdapter = InsertionAdapter(
            database,
            'BookDetailBean',
            (BookDetailBean item) => <String, Object?>{
                  'id': item.id,
                  'name': item.name,
                  'intro': item.intro,
                  'author': item.author,
                  'coverUrl': item.coverUrl,
                  'kind': item.kind,
                  'lastChapter': item.lastChapter,
                  'tocUrl': item.tocUrl,
                  'sourceUrl': item.sourceUrl,
                  'sourceSearchResult': item.sourceSearchResult,
                  'readChapterIndex': item.readChapterIndex,
                  'readPageIndex': item.readPageIndex,
                  'totalChapterCount': item.totalChapterCount
                }),
        _bookChapterBeanInsertionAdapter = InsertionAdapter(
            database,
            'BookChapterBean',
            (BookChapterBean item) => <String, Object?>{
                  'id': item.id,
                  'bookId': item.bookId,
                  'chapterName': item.chapterName,
                  'chapterUrl': item.chapterUrl,
                  'chapterIndex': item.chapterIndex
                }),
        _chapterContentInsertionAdapter = InsertionAdapter(
            database,
            'ChapterContent',
            (ChapterContent item) => <String, Object?>{
                  'id': item.id,
                  'chapter_id': item.chapterId,
                  'content': item.content
                }),
        _bookChapterBeanUpdateAdapter = UpdateAdapter(
            database,
            'BookChapterBean',
            ['id'],
            (BookChapterBean item) => <String, Object?>{
                  'id': item.id,
                  'bookId': item.bookId,
                  'chapterName': item.chapterName,
                  'chapterUrl': item.chapterUrl,
                  'chapterIndex': item.chapterIndex
                }),
        _bookDetailBeanUpdateAdapter = UpdateAdapter(
            database,
            'BookDetailBean',
            ['id'],
            (BookDetailBean item) => <String, Object?>{
                  'id': item.id,
                  'name': item.name,
                  'intro': item.intro,
                  'author': item.author,
                  'coverUrl': item.coverUrl,
                  'kind': item.kind,
                  'lastChapter': item.lastChapter,
                  'tocUrl': item.tocUrl,
                  'sourceUrl': item.sourceUrl,
                  'sourceSearchResult': item.sourceSearchResult,
                  'readChapterIndex': item.readChapterIndex,
                  'readPageIndex': item.readPageIndex,
                  'totalChapterCount': item.totalChapterCount
                }),
        _bookDetailBeanDeletionAdapter = DeletionAdapter(
            database,
            'BookDetailBean',
            ['id'],
            (BookDetailBean item) => <String, Object?>{
                  'id': item.id,
                  'name': item.name,
                  'intro': item.intro,
                  'author': item.author,
                  'coverUrl': item.coverUrl,
                  'kind': item.kind,
                  'lastChapter': item.lastChapter,
                  'tocUrl': item.tocUrl,
                  'sourceUrl': item.sourceUrl,
                  'sourceSearchResult': item.sourceSearchResult,
                  'readChapterIndex': item.readChapterIndex,
                  'readPageIndex': item.readPageIndex,
                  'totalChapterCount': item.totalChapterCount
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<BookDetailBean> _bookDetailBeanInsertionAdapter;

  final InsertionAdapter<BookChapterBean> _bookChapterBeanInsertionAdapter;

  final InsertionAdapter<ChapterContent> _chapterContentInsertionAdapter;

  final UpdateAdapter<BookChapterBean> _bookChapterBeanUpdateAdapter;

  final UpdateAdapter<BookDetailBean> _bookDetailBeanUpdateAdapter;

  final DeletionAdapter<BookDetailBean> _bookDetailBeanDeletionAdapter;

  @override
  Future<List<BookDetailBean>> findAllBooks() async {
    return _queryAdapter.queryList('SELECT * FROM BookDetailBean',
        mapper: (Map<String, Object?> row) => BookDetailBean(
            id: row['id'] as String,
            name: row['name'] as String?,
            intro: row['intro'] as String?,
            author: row['author'] as String?,
            coverUrl: row['coverUrl'] as String?,
            kind: row['kind'] as String?,
            lastChapter: row['lastChapter'] as String?,
            tocUrl: row['tocUrl'] as String?,
            sourceUrl: row['sourceUrl'] as String?,
            readChapterIndex: row['readChapterIndex'] as int,
            readPageIndex: row['readPageIndex'] as int,
            totalChapterCount: row['totalChapterCount'] as int));
  }

  @override
  Future<List<BookChapterBean>> findBookChapters(String bookId) async {
    return _queryAdapter.queryList(
        'SELECT * FROM BookChapterBean where bookId = ?1',
        mapper: (Map<String, Object?> row) => BookChapterBean(
            id: row['id'] as String,
            bookId: row['bookId'] as String?,
            chapterName: row['chapterName'] as String?,
            chapterUrl: row['chapterUrl'] as String?,
            chapterIndex: row['chapterIndex'] as int),
        arguments: [bookId]);
  }

  @override
  Future<ChapterContent?> findChapterContentById(String id) async {
    return _queryAdapter.query(
        'SELECT * FROM ChapterContent where chapter_id = ?1',
        mapper: (Map<String, Object?> row) => ChapterContent(
            row['id'] as String,
            row['chapter_id'] as String,
            row['content'] as String),
        arguments: [id]);
  }

  @override
  Future<List<BookChapterBean>> deleteBookChapters(String bookId) async {
    return _queryAdapter.queryList(
        'DELETE FROM BookChapterBean where bookId = ?1',
        mapper: (Map<String, Object?> row) => BookChapterBean(
            id: row['id'] as String,
            bookId: row['bookId'] as String?,
            chapterName: row['chapterName'] as String?,
            chapterUrl: row['chapterUrl'] as String?,
            chapterIndex: row['chapterIndex'] as int),
        arguments: [bookId]);
  }

  @override
  Future<List<BookDetailBean>> queryBookDetail(String bookName) async {
    return _queryAdapter.queryList(
        'SELECT * FROM BookDetailBean where name = ?1',
        mapper: (Map<String, Object?> row) => BookDetailBean(
            id: row['id'] as String,
            name: row['name'] as String?,
            intro: row['intro'] as String?,
            author: row['author'] as String?,
            coverUrl: row['coverUrl'] as String?,
            kind: row['kind'] as String?,
            lastChapter: row['lastChapter'] as String?,
            tocUrl: row['tocUrl'] as String?,
            sourceUrl: row['sourceUrl'] as String?,
            readChapterIndex: row['readChapterIndex'] as int,
            readPageIndex: row['readPageIndex'] as int,
            totalChapterCount: row['totalChapterCount'] as int),
        arguments: [bookName]);
  }

  @override
  Future<int> insertSource(BookDetailBean bean) {
    return _bookDetailBeanInsertionAdapter.insertAndReturnId(
        bean, OnConflictStrategy.replace);
  }

  @override
  Future<int> insertBookChapter(BookChapterBean ban) {
    return _bookChapterBeanInsertionAdapter.insertAndReturnId(
        ban, OnConflictStrategy.replace);
  }

  @override
  Future<List<int>> insertBookChapters(List<BookChapterBean> list) {
    return _bookChapterBeanInsertionAdapter.insertListAndReturnIds(
        list, OnConflictStrategy.ignore);
  }

  @override
  Future<int> insertBookDetail(BookDetailBean bean) {
    return _bookDetailBeanInsertionAdapter.insertAndReturnId(
        bean, OnConflictStrategy.ignore);
  }

  @override
  Future<int> insertAndUpdateChapterContent(ChapterContent content) {
    return _chapterContentInsertionAdapter.insertAndReturnId(
        content, OnConflictStrategy.replace);
  }

  @override
  Future<int> updateChapter(BookChapterBean chapter) {
    return _bookChapterBeanUpdateAdapter.updateAndReturnChangedRows(
        chapter, OnConflictStrategy.abort);
  }

  @override
  Future<int> updateBook(BookDetailBean bean) {
    return _bookDetailBeanUpdateAdapter.updateAndReturnChangedRows(
        bean, OnConflictStrategy.abort);
  }

  @override
  Future<int> deleteSource(BookDetailBean bean) {
    return _bookDetailBeanDeletionAdapter.deleteAndReturnChangedRows(bean);
  }
}
