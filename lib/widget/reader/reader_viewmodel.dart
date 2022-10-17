import 'dart:ui' as ui;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:read_info/bean/book_item_bean.dart';
import 'package:read_info/utils/utils_screen.dart';
import 'package:read_info/widget/reader/reader_content.dart';

import 'reader_content_config.dart';

typedef ChapterProvider= Future<ReaderChapterData> Function(int);
class ReaderViewModel extends ChangeNotifier {
  ReaderViewModel(this.chapterProvider, this.currentChapterIndex);
  ChapterProvider  chapterProvider;
  ///当前章节页面列表
  int currentChapterIndex;
  ReaderChapterData? currentChapter ;
  ReaderChapterData? nextChapter ;
  ReaderContentDrawer readerContentDrawer=ReaderContentDrawer();
  ReaderConfigEntity? config;

  drawCurrentPage(Canvas canvas) {
    if(currentChapter?.chapterContentConfigs.isNotEmpty!=true) return;
    var currentPage=currentChapter!.currentPageData();
    if(currentPage.pagePicture!=null)
    canvas.drawPicture(currentPage.pagePicture!);
  }
  toNextPage()async{
    await preLoadNextData();
    if(!currentChapter!.toNextPage()){
      currentChapterIndex++;
      currentChapter=nextChapter;
    }
    notifyListeners();
  }
  setConfig(ReaderConfigEntity config) {
    this.config = config;
    reApplyConfig();
  }

  Future preLoadNextData() async {
    ensureCurrentChapter();
    if (currentChapter!.canToNextPage()) {
      preparePagePicture(currentChapter!, currentChapter!.currentPageIndex + 1);
    } else {
      ensureNextChapter();
      preparePagePicture(nextChapter!, 0);
    }
  }

  Future ensureNextChapter() async {
    if (nextChapter == null)
      nextChapter = await chapterProvider(currentChapterIndex+1);
  }
  Future ensureCurrentChapter() async {
    if (currentChapter == null)
      currentChapter = await chapterProvider(currentChapterIndex);
  }

  void reApplyConfig() async {
    await ensureCurrentChapter();
    applyConfig(currentChapter);
    applyConfig(nextChapter);
    notifyListeners();
    preLoadNextData();
  }
  void applyConfig(ReaderChapterData? chapter) async {
    if (config == null) return;
    if (chapter?.content == null) return;
    var chapterPageList =
    ReaderContentDrawer.getChapterPageContentConfigList(
      0,
      chapter!.content!,
      config!.pageSize.height,
      config!.pageSize.width,
      config!.fontSize,
      config!.lineHeight,
      config!.paragraphSpacing,
    );
    chapter.chapterContentConfigs = chapterPageList;
    preparePagePicture(chapter,chapter.currentPageIndex);
  }

  void preparePagePicture(ReaderChapterData chapter,int pageIndex) {
    var pageConfig = chapter.pageDate(pageIndex);
    if(pageConfig.pagePicture==null) {
      var picture = readerContentDrawer.drawContent(
          chapter, pageIndex);
      // ui.Image image = await picture.toImage(ScreenUtils.getScreenWidth().toInt(),
      //     ScreenUtils.getScreenHeight().toInt());
      // pageConfig.pageImage = image;
      pageConfig.pagePicture = picture;
    }
  }
}