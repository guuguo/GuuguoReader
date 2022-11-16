import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:read_info/utils/developer.dart';
import 'package:read_info/utils/ext/scroll_ext.dart';
import 'package:read_info/widget/reader/reader_page_progress.dart';

final comicImageDefaultHeight = 400.0;

class ComicItem {
  String url = "";
  var index = 0;
  double? height;

  ComicItem({required this.url, required this.index});
}

class ComicLogic extends GetxController {
  ComicLogic(this.pageProgress, this.controller);

  ScrollController controller;
  ReaderPageProgress pageProgress;

  ///保持两章的存在 章节id
  List<ComicItem> comics = [];

  get comicsHeight => comics.fold<double>(0, (pre, e) => pre += (e.height ?? comicImageDefaultHeight));

  loadCurrentPage() async {
    await pageProgress.ensureCurrentChapter();
    final chapter = pageProgress.currentChapter;
    if (chapter != null) {
      comics.clear();
      comics.addAll(chapter.comics.map((e) => ComicItem(url: e, index: chapter.chapterIndex)));
      update();
    }
    pageProgress.preloadNextData();
    pageProgress.preloadPreData();
  }

  void reloadCurrentPageCache() async {
    await pageProgress.reloadCurrentPageCache();
    comics.clear();

    final chapter = pageProgress.currentChapter;
    if (chapter != null) {
      comics.addAll(chapter.comics.map((e) => ComicItem(url: e, index: chapter.chapterIndex)));
      update();
    }
    pageProgress.preloadNextData();
    pageProgress.preloadPreData();

    update();
  }

  Future addNextComicChapter(double? firstColumnHeight) async {
    if (!pageProgress.canToTargetChapter(pageProgress.currentChapterIndex + 1)) {
      return;
    }
    var removeHeight = 0.0;
    comics.removeWhere((element) {
      final remove = element.index == pageProgress.currentChapterIndex - 1;
      if (remove) {
        removeHeight += element.height ?? comicImageDefaultHeight;
      }
      return remove;
    });

    await pageProgress.toNextPage();
    final chapter = pageProgress.currentChapter;
    await loadCurrentPage();
    ///添加下一章
    if (chapter == null) {
      return;
    }
    // final comic=Pair(chapter.chapterIndex, chapter.comics);
    // comics.add(comic);
    comics.addAll(chapter.comics.map((e) => ComicItem(url: e, index: chapter.chapterIndex)));
    debug("添加${chapter.chapterIndex}章 有${chapter.comics.length}张图片");
    if (removeHeight > 0) {
      controller.jumpTo(controller.offset - removeHeight);
      update();
    } else {
      update();
    }
  }
}
