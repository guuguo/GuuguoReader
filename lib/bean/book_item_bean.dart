import 'dart:collection';
import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:floor/floor.dart';
import 'package:flutter/cupertino.dart';
import 'package:read_info/bean/entity/source_entity.dart';
import 'package:uuid/uuid.dart';

abstract class BookBean {
  @ignore
  String? name;
  @ignore
  String? intro;
  @ignore
  String? author;

  @ignore
  String? coverUrl;
}

class BookItemBean extends BookBean {
  String? name = "";
  String? intro = "";
  String? coverUrl = "";
  String? bookUrl = "";
  String? author = "";
  String? lastChapter = "";
  String? sourceUrl;
  SourceEntity? source;


  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is BookItemBean && runtimeType == other.runtimeType && name == other.name && bookUrl == other.bookUrl && sourceUrl == other.sourceUrl;

  @override
  int get hashCode => name.hashCode ^ bookUrl.hashCode ^ sourceUrl.hashCode;

  BookItemBean({this.name, this.intro, this.coverUrl, this.bookUrl, this.author, this.lastChapter, required this.sourceUrl});

  BookItemBean.FormSource(SourceEntity source){
    this.source = source;
    this.sourceUrl = source.bookSourceUrl;
  }

  Map<String, dynamic> toMap() {
    return {'name': name, 'intro': intro, 'coverUrl': coverUrl, 'bookUrl': bookUrl, 'author': author, 'lastChapter': lastChapter, 'sourceUrl': sourceUrl};
  }


  static BookItemBean? fromMap(dynamic map) {
    if (null == map) return null;
    var temp;
    return BookItemBean(name: map['name']?.toString(),
      intro: map['intro']?.toString(),
      coverUrl: map['coverUrl']?.toString(),
      bookUrl: map['bookUrl']?.toString(),
      author: map['author']?.toString(),
      lastChapter: map['lastChapter']?.toString(),
      sourceUrl: map['sourceUrl']?.toString(),
    );
  }

  @override
  String toString() {
    return 'BookItemBean{name: $name, intro: $intro, coverUrl: $coverUrl, bookUrl: $bookUrl, author: $author, lastChapter: $lastChapter, sourceUrl: $sourceUrl, source: $source}';
  }
}

@Entity(indices: [
  Index(value: ['name'])
])
class BookDetailBean extends BookBean {
  @PrimaryKey()
  String? id;
  String? name = "";
  String? intro = "";
  String? author = "";
  String? coverUrl = "";
  String? kind = "";
  String? lastChapter = "";
  String? tocUrl = "";
  String? sourceUrl = "";
  int? updateAt = 0;
  @ignore

  ///搜索的源结果
  HashSet<BookItemBean> _searchResult = HashSet();

  ///搜索的源结果
  HashSet<BookItemBean> get searchResult {
    if (_searchResult.isNotEmpty != true && sourceSearchResult?.isNotEmpty == true) {
      (json.decode(sourceSearchResult!) as List).forEach((e) {
        final bean = BookItemBean.fromMap(e);
        if (bean != null) _searchResult.add(bean);
      });
    }
    return _searchResult;
  }

  ///搜索的源结果
  set searchResult(HashSet<BookItemBean> searchResult) {
    _searchResult = searchResult;
    sourceSearchResult =json.encode( searchResult.map((e) => e.toMap()).toList());
  }

  ///搜索的源结果存储数据库的内容
  String? sourceSearchResult = "";
  @ignore
  List<BookChapterBean>? _chapters;

  List<BookChapterBean>? get chapters => _chapters;

  set chapters(List<BookChapterBean>? chapters) {
    _chapters = chapters;
    if (chapters?.isNotEmpty == true) {
      totalChapterCount = chapters?.length ?? 0;
    }
  }


  int readChapterIndex;
  int readPageIndex;
  int totalChapterCount;

  BookDetailBean({required this.id,
    this.name,
    this.intro,
    this.author,
    this.coverUrl,
    this.kind,
    this.lastChapter,
    this.tocUrl,
    this.updateAt,
    List<BookChapterBean>? chapters,
    required this.sourceUrl,
    this.readChapterIndex = 0,
    this.readPageIndex = 0,
    this.sourceSearchResult,
    this.totalChapterCount = 0}) {
    this.chapters = chapters;
  }

  BookDetailBean copyWith({
    @PrimaryKey() String? id,
    String? name,
    String? intro,
    String? author,
    String? coverUrl,
    String? kind,
    String? lastChapter,
    String? tocUrl,
    int? updateAt,
    String? sourceUrl,
    @ignore List<BookChapterBean>? chapters,
    int? readChapterIndex,
    String? sourceSearchResult,
    int? readPageIndex,
    int? totalChapterCount,
  }) {
    return BookDetailBean(
      id: id ?? this.id,
      name: name ?? this.name,
      intro: intro ?? this.intro,
      author: author ?? this.author,
      coverUrl: coverUrl ?? this.coverUrl,
      kind: kind ?? this.kind,
      lastChapter: lastChapter ?? this.lastChapter,
      chapters: chapters ?? this.chapters,
      tocUrl: tocUrl ?? this.tocUrl,
      updateAt: updateAt ?? this.updateAt,
      sourceSearchResult: sourceSearchResult ?? this.sourceSearchResult,
      sourceUrl: sourceUrl ?? this.sourceUrl,
      readChapterIndex: readChapterIndex ?? this.readChapterIndex,
      readPageIndex: readPageIndex ?? this.readPageIndex,
      totalChapterCount: totalChapterCount ?? this.totalChapterCount,
    );
  }
}

@Entity(
    foreignKeys: [
      ForeignKey(childColumns: ['bookId'],
          parentColumns: ['id'],
          entity: BookDetailBean,
          onDelete: ForeignKeyAction.cascade,
          onUpdate: ForeignKeyAction.noAction),
    ], indices: [Index(value: ['bookId', 'chapterName'], unique: true, name: 'index_chapter')]
)
class BookChapterBean {
  @PrimaryKey()
  String id = "";
  String? bookId = "";
  String? chapterName = "";
  String? chapterUrl = "";
  int chapterIndex = 0;
  bool? cached = false;
  @ignore
  ChapterContent? content;

  BookChapterBean({required this.id, required this.bookId, this.chapterName, this.chapterUrl, required this.chapterIndex, this.content, this.cached = false});

  bool hasContent() {
    return content?.content.isNotEmpty == true;
  }
}

@Entity(
    indices: [Index(value: ['chapter_id'], unique: true, name: 'index_chapter_content')]
)
class ChapterContent {
  @PrimaryKey()
  String id = "";
  String? bookId = "";
  @ColumnInfo(name: "chapter_id")
  String chapterId = "";
  String content = "";

  ChapterContent(this.id, this.chapterId, this.content);

  ChapterContent.FromChapter(BookChapterBean chapter, String content) {
    id = chapter.id;
    bookId = chapter.bookId;
    this.chapterId = chapter.id;
    this.content = content;
  }
}
