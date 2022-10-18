import 'dart:ui' as ui;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
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
  ReaderChapterData? preChapter ;
  ReaderConfigEntity? config;
  ReaderContentDrawer readerContentDrawer=ReaderContentDrawer();

  bool currentPageReady() {
    return currentChapter?.currentPageData().pagePicture != null;
  }

  drawCurrentPage(Canvas canvas) {
    if(currentChapter?.chapterContentConfigs.isNotEmpty!=true) return;
    var currentPage=currentChapter!.currentPageData();
    if(currentPage.pagePicture!=null)
    canvas.drawPicture(currentPage.pagePicture!);
  }

  toNextPage() async {
    await preLoadNextData();
    if (!currentChapter!.toNextPage()) {
      currentChapterIndex++;
      preChapter=currentChapter;
      currentChapter = nextChapter;
      nextChapter=null;
    }
    notifyListeners();
  }
  toPrePage() async {
    await preLoadNextData();
    if (!currentChapter!.toPrePage()) {
      if (currentChapterIndex <= 0) {
        Get.snackbar("提示", "已经是第一页了",duration:Duration(milliseconds: 1000));
        return;
      }
      currentChapterIndex--;
      nextChapter =currentChapter;
      currentChapter = preChapter;
      preChapter=null;
    }
    notifyListeners();
  }
  setConfig(ReaderConfigEntity config) {
    final newConfig=config.copyWith();
    if(this.config!=newConfig) {
      this.config=newConfig;
      reApplyConfig();
    }
  }
///预加载下一页
  Future preLoadNextData() async {
    await ensureCurrentChapter();
    if (currentChapter!.canToNextPage()) {
      preparePagePicture(currentChapter!, currentChapter!.currentPageIndex + 1);
    } else {
      await ensureNextChapter();
      applyConfig(nextChapter);
      preparePagePicture(nextChapter!, 0);
    }
  }
  ///预加载前一页
  Future preLoadPreData() async {
    await ensureCurrentChapter();
    if (currentChapter!.canToPrePage()) {
      preparePagePicture(currentChapter!, currentChapter!.currentPageIndex - 1);
    } else {
      await ensurePreChapter();
      applyConfig(preChapter);
      preparePagePicture(nextChapter!, 0);
    }
  }
  Future ensurePreChapter() async {
    if (preChapter == null)
      preChapter = await chapterProvider(currentChapterIndex-1);
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
    currentChapter?.clearCalculateResult();
    nextChapter?.clearCalculateResult();
    preChapter?.clearCalculateResult();

    applyConfig(currentChapter);
    applyConfig(nextChapter);
    applyConfig(preChapter);
    notifyListeners();
    preLoadNextData();
  }
  void applyConfig(ReaderChapterData? chapter) async {
    if (config == null) return;
    if (chapter?.content == null) return;
    if(chapter?.chapterContentConfigs.isNotEmpty!=true) {
      var chapterPageList =
      ReaderContentDrawer.getChapterPageContentConfigList(
        0,
        chapter!.content!,
        config!.pageSize.height - config!.bottomTipHeight - config!.contentPadding * 2,
        config!.pageSize.width - config!.contentPadding * 2,
        config!.fontSize,
        config!.lineHeight,
        config!.paragraphSpacing,
      );
      chapter.chapterContentConfigs = chapterPageList;
    }
    preparePagePicture(chapter!,chapter.currentPageIndex);
  }

  void preparePagePicture(ReaderChapterData chapter,int pageIndex) {
    var pageConfig = chapter.pageDate(pageIndex);
    if(pageConfig?.pagePicture==null) {
      var picture = readerContentDrawer.drawContent(
          chapter, pageIndex);
      // ui.Image image = await picture.toImage(ScreenUtils.getScreenWidth().toInt(),
      //     ScreenUtils.getScreenHeight().toInt());
      // pageConfig.pageImage = image;
      pageConfig!.pagePicture = picture;
    }
  }
}