class BookItemBean {
  String? name = "";
  String? intro = "";
  String? coverUrl = "";
  String? bookUrl = "";
  String? author = "";
}
class BookDetailBean {
  String? name = "";
  String? intro = "";
  String? author = "";
  String? coverUrl = "";
  String? kind = "";
  String? lastChapter = "";
  String? tocUrl = "";
  List<BookChapterBean>? tocs;

  BookDetailBean({
    this.name,
    this.intro,
    this.author,
    this.coverUrl,
    this.kind,
    this.lastChapter,
    this.tocUrl,
    this.tocs,
  });

  BookDetailBean copyWith({
    String? name,
    String? intro,
    String? author,
    String? coverUrl,
    String? kind,
    String? lastChapter,
    String? tocUrl,
    List<BookChapterBean>? tocs,
  }) {
    return BookDetailBean(
      name: name ?? this.name,
      intro: intro ?? this.intro,
      author: author ?? this.author,
      coverUrl: coverUrl ?? this.coverUrl,
      kind: kind ?? this.kind,
      lastChapter: lastChapter ?? this.lastChapter,
      tocUrl: tocUrl ?? this.tocUrl,
      tocs: tocs ?? this.tocs,
    );
  }
}
class BookChapterBean {
  String? chapterName = "";
  String? chapterUrl = "";
  BookContentBean? content;
}
class BookContentBean {
  String? content = "";
}
