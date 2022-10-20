import 'package:floor/floor.dart';
import 'package:flutter/cupertino.dart';
import 'package:read_info/bean/entity/source_entity.dart';

class BookItemBean {
  String? name = "";
  String? intro = "";
  String? coverUrl = "";
  String? bookUrl = "";
  String? author = "";
  SourceEntity? source;

  BookItemBean({this.name, this.intro, this.coverUrl, this.bookUrl, this.author,required this.source});
}

@entity
class BookDetailBean {
  @PrimaryKey()
  String? id = "";
  String? name = "";
  String? intro = "";
  String? author = "";
  String? coverUrl = "";
  String? kind = "";
  String? lastChapter = "";
  String? tocUrl = "";
  String? sourceUrl = "";
  @ignore
  List<BookChapterBean>? chapters;

  int readChapterIndex;
  int readPageIndex;
  int totalChapterCount;

  BookDetailBean(
      {this.id,
      this.name,
      this.intro,
      this.author,
      this.coverUrl,
      this.kind,
      this.lastChapter,
      this.tocUrl,
      this.sourceUrl,
      this.chapters,
      this.readChapterIndex = 0,
      this.readPageIndex = 0,
      this.totalChapterCount = 0});

  BookDetailBean copyWith({
    @PrimaryKey() String? id,
    String? name,
    String? intro,
    String? author,
    String? coverUrl,
    String? kind,
    String? lastChapter,
    String? tocUrl,
    String? sourceUrl,
    @ignore List<BookChapterBean>? chapters,
    int? readChapterIndex,
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
      tocUrl: tocUrl ?? this.tocUrl,
      sourceUrl: sourceUrl ?? this.sourceUrl,
      chapters: chapters ?? this.chapters,
      readChapterIndex: readChapterIndex ?? this.readChapterIndex,
      readPageIndex: readPageIndex ?? this.readPageIndex,
      totalChapterCount: totalChapterCount ?? this.totalChapterCount,
    );
  }
}

@Entity(
  foreignKeys: [
    ForeignKey(childColumns: ['bookId'], parentColumns: ['id'], entity: BookDetailBean, onDelete: ForeignKeyAction.cascade, onUpdate: ForeignKeyAction.noAction)
  ],
)
class BookChapterBean {
  @PrimaryKey()
  String id = "";
  String? bookId = "";
  String? chapterName = "";
  String? chapterUrl = "";
  int? chapterIndex = 0;
  @ignore
  ChapterContent? content;

  BookChapterBean({this.id="", this.bookId, this.chapterName, this.chapterUrl, this.chapterIndex=0, this.content});

  bool hasContent() {
    return content?.content.isNotEmpty == true;
  }
}

@Entity(foreignKeys: [
  ForeignKey(
    childColumns: ['chapter_id'],
    parentColumns: ['id'],
    entity: BookChapterBean,
    onDelete: ForeignKeyAction.cascade,
    onUpdate: ForeignKeyAction.noAction,
  )
])
class ChapterContent {
  @PrimaryKey()
  String id = "";
  @ColumnInfo(name: "chapter_id")
  String chapterId = "";
  String content = "";

  ChapterContent(this.id, this.chapterId, this.content);

  ChapterContent.FromChapter(BookChapterBean chapter, String content) {
    id = chapter.id;
    this.chapterId = chapter.id;
    this.content = content;
  }
}
