import 'dart:ui' as ui;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:read_info/bean/book_item_bean.dart';
import 'package:read_info/utils/ext/list_ext.dart';
import 'package:read_info/utils/utils_screen.dart';
import 'package:read_info/widget/reader/reader_content.dart';
import 'package:read_info/widget/reader/reder_view.dart';

import 'reader_content_config.dart';

typedef ChapterProvider = Future<ReaderChapterData> Function(int);

class ReaderViewModel extends ChangeNotifier {
  ReaderViewModel(
    this.chapterProvider,
    this.readChangeCallback,
    this.currentChapterIndex,
    this.startReadPageIndex,
  );

  final ReadPageChangeCallback readChangeCallback;
  final ChapterProvider chapterProvider;

  ///当前章节页面列表
  int currentChapterIndex;
  ///初始页面index
  final int startReadPageIndex;
  //第一次加载阅读器
   var firstLoad=true;
  ReaderChapterData? currentChapter;

  ReaderChapterData? nextChapter;

  ReaderChapterData? preChapter;

  ReaderConfigEntity? config;
  ReaderContentDrawer readerContentDrawer = ReaderContentDrawer();

  //当前页面是否已经ready
  bool currentPageReady() {
    try {
      return currentChapter
          ?.currentPageData()
          .pagePicture != null;
    }catch (e) {
      return false;
    }
  }
  //绘制背景
  drawBackground(Canvas canvas){
    readerContentDrawer.drawBackground(canvas);
  }
  //绘制当前页面
  drawCurrentPage(Canvas canvas) {
    if (currentChapter?.chapterContentConfigs.isNotEmpty != true) return;
    var currentPage = currentChapter!.currentPageData();
    if (currentPage.pagePicture != null) canvas.drawPicture(currentPage.pagePicture!);
  }

  //是否在跳转页面加载中
  var loading = false;
//跳转到下一页
  Future toNextPage() async {
    if (loading) return;
    loading = true;
    try {
      try {
        await preLoadNextData();
      } catch (e) {}
      if (!currentChapter!.toNextPage()) {
        currentChapterIndex++;
        preChapter = currentChapter;
        currentChapter = nextChapter;
        nextChapter = null;
      }
      readChangeCallback(currentChapter!.currentPageIndex, currentChapterIndex);
      notifyListeners();
    } catch (e) {}
    loading = false;
  }

  //跳转到前一页
  Future toPrePage() async {
    if (loading) return;
    loading = true;
    try {
      try {
        await preLoadPreData();
      }catch (e) {
      }
      if (!currentChapter!.toPrePage()) {
        if (currentChapterIndex <= 0) {
          Get.snackbar("提示", "已经是第一页了", duration: Duration(milliseconds: 1000));
          loading = false;
          return;
        }
        currentChapterIndex--;
        nextChapter = currentChapter;
        currentChapter = preChapter;
        preChapter = null;
      }
      readChangeCallback(currentChapterIndex, currentChapter!.currentPageIndex);
      notifyListeners();
    } catch (e) {}
    loading = false;
  }

  setConfig(ReaderConfigEntity config) {
    final newConfig = config.copyWith();
    if (this.config != newConfig) {
      this.config = newConfig;
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
      preparePagePicture(preChapter!, preChapter!.chapterContentConfigs.length - 1);
    }
  }

  Future ensurePreChapter() async {
    if (preChapter?.content?.isNotEmpty!=true) preChapter = await chapterProvider(currentChapterIndex - 1);
  }

  Future ensureNextChapter() async {
    if (nextChapter?.content?.isNotEmpty!=true) nextChapter = await chapterProvider(currentChapterIndex + 1);
  }

  Future ensureCurrentChapter() async {
    if (currentChapter == null) {
      currentChapter = await chapterProvider(currentChapterIndex);
      if (firstLoad) {
        currentChapter?.currentPageIndex = startReadPageIndex;
        firstLoad = false;
      }
    }
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
    if (chapter?.chapterContentConfigs.isNotEmpty != true) {
      var chapterPageList = ReaderContentDrawer.getChapterPageContentConfigList(
        0,
        chapter!.content!,
        config!.pageSize.height - config!.contentPaddingVertical * 2,
        config!.pageSize.width - config!.contentPaddingHorizontal * 2,
        config!.fontSize,
        config!.lineHeight,
        config!.paragraphSpacing,
      );
      chapter.chapterContentConfigs = chapterPageList;
      if(chapter.currentPageIndex>=chapterPageList.length){
        chapter.currentPageIndex=chapterPageList.length-1;
      }else if(chapter.currentPageIndex<0){
        chapter.currentPageIndex=0;
      }
    }
    preparePagePicture(chapter!, chapter.currentPageIndex);
  }

  void preparePagePicture(ReaderChapterData chapter, int pageIndex) {
    var pageConfig = chapter.pageDate(pageIndex);
    if (pageConfig?.pagePicture == null) {
      var picture = readerContentDrawer.drawContent(chapter, pageIndex);
      pageConfig!.pagePicture = picture;
    }
  }
}
