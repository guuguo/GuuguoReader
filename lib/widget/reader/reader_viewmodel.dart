import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:read_info/utils/developer.dart';
import 'package:read_info/widget/reader/reader_content.dart';
import 'package:read_info/widget/reader/reader_page_progress.dart';
import 'anim/page_anim_manager.dart';
import 'reader_content_config.dart';

typedef ChapterProvider = Future<ReaderChapterData> Function(int);
typedef ChapterCacheDeleter = Future Function(int);

class ReaderViewModel extends ChangeNotifier implements IReaderPageVm {
  ReaderViewModel(
    this.pageProgress,
    this.config,
    GlobalKey canvasKey,
  ) {
    readerContentDrawer = ReaderContentDrawer(this);
    pageProgress.chapterPrepare = (chapter) {
      applyConfig(chapter);
    };
  }

  init() async {
    await config.initBGImage();
    reApplyConfig();
    pageProgress.preloadData();
    prepareNextAndPrePage();
  }

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

  //是否在跳转页面加载中
  var loading = false;

  //跳转到下一页
  Future toNextPage() async {
    await pageProgress.toNextPage();
    prepareCurrentPage();
    notifyListeners();
    if (!pageProgress.currentChapterReady()) {
      await pageProgress.ensureCurrentChapter();
      prepareCurrentPage();
      notifyListeners();
    }
    pageProgress.preloadNextData();
  }

  //跳转到前一页
  Future toPrePage() async {
    await pageProgress.toPrePage();
    prepareCurrentPage();
    notifyListeners();
    if (!pageProgress.currentChapterReady()) {
      debug("当前章节 ${pageProgress.currentChapterIndex} 内容未加载，开始加载");
      await pageProgress.ensureCurrentChapter();
      prepareCurrentPage();
      notifyListeners();
    }
    pageProgress.preloadPreData();
  }

  //跳转到某一页
  Future toChapter(int chapterIndex) async {
    await pageProgress.toTargetChapter(chapterIndex);
    prepareCurrentPage();
    notifyListeners();
    if (!pageProgress.currentChapterReady()) {
      await pageProgress.ensureCurrentChapter();
      prepareCurrentPage();
      notifyListeners();
    }
    pageProgress.preloadData();
  }

  prepareCurrentPage() {
    if(pageProgress.currentChapter==null) {
      debug("当前章节 ${pageProgress.currentPageIndex} 为空");
      return;
    }
    preparePagePicture(pageProgress.currentChapter!, pageProgress.currentChapter!.currentPageIndex);
  }

  prepareNextAndPrePage() async {
    if (pageProgress.currentChapter?.canToPrePage() == true) {
      preparePagePicture(pageProgress.currentChapter!, pageProgress.currentPageIndex - 1);
    } else if (pageProgress.preChapter != null) {
      preparePagePicture(pageProgress.preChapter!, pageProgress.preChapter!.chapterContentConfigs.length - 1);
    }
    if (pageProgress.currentChapter?.canToNextPage() == true) {
      preparePagePicture(pageProgress.currentChapter!, pageProgress.currentPageIndex + 1);
    } else if (pageProgress.nextChapter != null) {
      preparePagePicture(pageProgress.nextChapter!, 0);
    }
  }

  setConfig(ReaderConfigEntity config)async {
    final configChange=this.config != config;
    this.config = config;
    if (configChange) {
      await this.config.initBGImage();
      reApplyConfig();
    }
  }

  Future reApplyConfig() async {
    readerContentDrawer.drawBackground(true);
    notifyListeners();
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
        config.pageSize.height - config.contentPaddingVertical * 2-config.lineHeight,
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
      var picture = readerContentDrawer.drawContent(chapter, pageIndex, pageProgress);
      pageConfig?.pagePicture = picture;
    }
  }

  // prepareImage(ReaderContentPageData? pageConfig) async {
  //   pageConfig?.pageImage = await pageConfig.pagePicture?.toImage(config.pageSize.width.toInt(), config.pageSize.height.toInt());
  // }

  @override
  ui.Picture getNextPagePicture() {
    final res = pageProgress.nextPage();
    final chapter = pageProgress.getChapterFromIndex(res.first);
    if (chapter != null) preparePagePicture(chapter, res.seconed);
    return chapter?.pageDate(res.seconed)?.pagePicture ?? readerContentDrawer.drawBackground();
  }

  @override
  ui.Picture getPrePagePicture() {
    final res = pageProgress.prePage();
    final chapter = pageProgress.getChapterFromIndex(res.first);
    if (chapter != null) preparePagePicture(chapter, res.seconed);
    return chapter?.pageDate(res.seconed)?.pagePicture ?? readerContentDrawer.drawBackground();
  }

  @override
  ui.Picture getCurrentPagePicture() {
    return pageProgress.currentChapter?.currentPageData()?.pagePicture ?? readerContentDrawer.drawBackground();
  }
}
