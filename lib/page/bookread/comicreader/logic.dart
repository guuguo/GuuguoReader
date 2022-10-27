import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:read_info/utils/ext/scroll_ext.dart';
import 'package:read_info/widget/reader/reader_page_progress.dart';

class ComicLogic extends GetxController {
  ComicLogic(this.pageProgress,this.controller);
  ScrollController controller;
  ReaderPageProgress pageProgress;
  ///保持两章的存在
  List<Pair<int, List<String>>> comics = [];

  loadCurrentPage()async{
    await pageProgress.ensureCurrentChapter();
    final chapter = pageProgress.currentChapter;
    if (chapter != null) {
      comics.clear();
      comics.add(Pair(chapter.chapterIndex, chapter.comics));
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
      comics.add(Pair(chapter.chapterIndex, chapter.comics));
      update();
    }
    pageProgress.preloadNextData();
    pageProgress.preloadPreData();

    update();
  }

  Future addNextComicChapter(double? firstColumnHeight) async{
    var removeHeight=0.0;
    ///如果当前不止一章，移除第一章
    if(comics.length>1){
      comics.removeAt(0);
      removeHeight=firstColumnHeight??0;
    }
    var chapterPage=pageProgress.currentChapterIndex+1;
    await pageProgress.ensureChapterContent(chapterPage);
    final chapter = pageProgress.nextChapter;
    ///添加下一章
    if (chapter != null) {
      comics.add(Pair(chapter.chapterIndex, chapter.comics));
    }
    update();
    if (removeHeight > 0) {
      await Future.delayed(Duration(milliseconds:20),(){
        controller.jumpTo(controller.offset-removeHeight);
      });
    }
  }
}