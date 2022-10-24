import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:read_info/widget/reader/reader_content.dart';
import 'package:read_info/widget/reader/reader_page_progress.dart';
import 'anim/page_anim_manager.dart';
import 'reader_content_config.dart';

typedef ChapterProvider = Future<ReaderChapterData> Function(int);

class ReaderViewModel extends ChangeNotifier implements IReaderPageDrawer {
  ReaderViewModel(
    this.pageProgress,
    this.config,
    GlobalKey canvasKey,
  ) {
    readerContentDrawer = ReaderContentDrawer(this);
    animManager=PageAnimManager(canvasKey,this,config.pageSize);
    pageProgress.chapterPrepare=(chapter){
      applyConfig(chapter);
    };
    init();
  }

  init() async {
    reApplyConfig();
    pageProgress.preloadData();
    prepareNextAndPrePage();
  }

  late PageAnimManager animManager;
  final ReaderPageProgress pageProgress;

  //第一次加载阅读器
  var firstLoad = true;

  ReaderConfigEntity config;
  late ReaderContentDrawer readerContentDrawer;

  //当前页面是否已经ready
  bool currentPageReady() {
    try {
      return pageProgress.currentChapter?.currentPageData()?.pagePicture != null;
    } catch (e) {
      return false;
    }
  }

  //绘制背景
  drawBackground(Canvas canvas) {
    canvas.drawPicture(readerContentDrawer.drawBackground());
  }

  //绘制当前页面
  drawCurrentPage(Canvas canvas) {
    var currentPage = pageProgress.currentChapter!.currentPageData();
    if (currentPage?.pagePicture != null) canvas.drawPicture(currentPage!.pagePicture!);
  }

  //是否在跳转页面加载中
  var loading = false;

//跳转到下一页
  Future toNextPage() async {
    await pageProgress.toNextPage();
    notifyListeners();
    if (!pageProgress.currentChapterReady()) {
      await pageProgress.ensureCurrentChapter();
      prepareCurrentPage();
      notifyListeners();
    }else{
      prepareCurrentPage();
    }
    pageProgress.preloadData();
  }
  //跳转到前一页
  Future toPrePage() async {
    await  pageProgress.toPrePage();
    notifyListeners();
    if (!pageProgress.currentChapterReady()) {
      await  pageProgress.ensureCurrentChapter();
      prepareCurrentPage();
      notifyListeners();
    }else{
      prepareCurrentPage();
    }
    prepareCurrentPage();
    pageProgress.preloadData();
  }

  //跳转到某一页
  Future toChapter(int chapterIndex) async {
    await pageProgress.toTargetChapter(chapterIndex);
    notifyListeners();
    if (!pageProgress.currentChapterReady()) {
      await pageProgress.ensureCurrentChapter();
      prepareCurrentPage();
      notifyListeners();
    }else{
      prepareCurrentPage();
    }
    pageProgress.preloadData();
  }
  prepareCurrentPage() {
    preparePagePicture(pageProgress.currentChapter!, pageProgress.currentChapter!.currentPageIndex);
  }

  prepareNextAndPrePage() async {
    if (pageProgress.currentChapter?.canToPrePage() == true) {
      preparePagePicture(pageProgress.currentChapter!, pageProgress.currentPageIndex - 1);
    } else if (pageProgress.preChapter != null) {
      preparePagePicture(pageProgress.preChapter!, pageProgress.preChapter!.chapterContentConfigs.length-1);
    }
    if (pageProgress.currentChapter?.canToNextPage() == true) {
      preparePagePicture(pageProgress.currentChapter!, pageProgress.currentPageIndex + 1);
    } else if (pageProgress.nextChapter != null) {
      preparePagePicture(pageProgress.nextChapter!, 0);
    }
  }



  setConfig(ReaderConfigEntity config) {
    final newConfig = config.copyWith();
    if (this.config != newConfig) {
      this.config = newConfig;
      reApplyConfig();
    }
  }

  void reApplyConfig() async {
    pageProgress.currentChapter?.clearCalculateResult();
    pageProgress.nextChapter?.clearCalculateResult();
    pageProgress.preChapter?.clearCalculateResult();

    await pageProgress.ensureCurrentChapter();
    applyConfig(pageProgress.currentChapter);
    applyConfig(pageProgress.preChapter);
    applyConfig(pageProgress.nextChapter);
    notifyListeners();
  }

  void applyConfig(ReaderChapterData? chapter) {
    if (config == null) return;
    if (chapter?.content == null) return;
    if (chapter?.chapterContentConfigs.isNotEmpty != true) {
      var chapterPageList = ReaderContentDrawer.getChapterPageContentConfigList(
        0,
        chapter!.content!,
        config.pageSize.height - config.contentPaddingVertical * 2,
        config.pageSize.width - config.contentPaddingHorizontal * 2,
        config.fontSize,
        config.lineHeight,
        config.paragraphSpacing,
      );
      chapter.chapterContentConfigs = chapterPageList;
      if (chapter.currentPageIndex >= chapterPageList.length) {
        chapter.currentPageIndex = chapterPageList.length - 1;
      } else if (chapter.currentPageIndex < 0) {
        chapter.currentPageIndex = 0;
      }
    }
    preparePagePicture(chapter!, chapter.currentPageIndex);
  }

  void preparePagePicture(ReaderChapterData chapter, int pageIndex) {
    var pageConfig = chapter.pageDate(pageIndex);
    if (pageConfig?.pagePicture == null) {
      var picture = readerContentDrawer.drawContent(chapter, pageIndex,pageProgress);
      pageConfig?.pagePicture = picture;
    }
  }

  @override
  ui.Picture getNextPagePicture() {
    // preparePagePicture(chapter, pageIndex)
    return pageProgress.currentChapter?.currentPageData()?.pagePicture??readerContentDrawer.drawBackground();
  }

  @override
  ui.Picture getPrePagePicture() {
    return pageProgress.currentChapter?.currentPageData()?.pagePicture??readerContentDrawer.drawBackground();
  }

  @override
  ui.Picture getCurrentPagePicture() {
    // TODO: implement getCurrentPagePicture
    throw UnimplementedError();
  }
}
