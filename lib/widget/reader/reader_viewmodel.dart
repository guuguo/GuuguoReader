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
    this.config,
  ){
    readerContentDrawer=ReaderContentDrawer(this);
    reApplyConfig();
  }

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

  ReaderConfigEntity config;
  late ReaderContentDrawer readerContentDrawer;

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
  drawBackground(Canvas canvas) {
    canvas.drawPicture(readerContentDrawer.drawBackground());
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
        currentChapter!.currentPageIndex=currentChapter!.chapterContentConfigs.length-1;
        preChapter = null;
      }
      readChangeCallback(currentChapterIndex, currentChapter!.currentPageIndex);
      notifyListeners();
    } catch (e) {}
    loading = false;
  }

  //跳转到某一页
  Future toChapter(int chapterIndex) async {
    if (loading) return;
    loading = true;
    if(chapterIndex==currentChapter?.chapterIndex){
      return;
    }
    if(!currentChapter!.canToTargetChapter(chapterIndex)){
      return;
    }
    try {
      ReaderChapterData? targetChapter;
      try {
        targetChapter= await preLoadData(chapterIndex);
      }catch (e) {}
      currentChapterIndex=chapterIndex;
      nextChapter = null;
      currentChapter = targetChapter;
      preChapter = null;

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
    await ensureChapter(currentChapterIndex);
    if (currentChapter!.canToNextPage()) {
      preparePagePicture(currentChapter!, currentChapter!.currentPageIndex + 1);
    } else {
      await ensureChapter(currentChapterIndex+1);
      applyConfig(nextChapter);
      preparePagePicture(nextChapter!, 0);
    }
  }

  ///预加载前一页
  Future preLoadPreData() async {
    await ensureChapter(currentChapterIndex);
    if (currentChapter!.canToPrePage()) {
      preparePagePicture(currentChapter!, currentChapter!.currentPageIndex - 1);
    } else {
      await ensureChapter(currentChapterIndex-1);
      applyConfig(preChapter);
      preparePagePicture(preChapter!, preChapter!.chapterContentConfigs.length - 1);
    }
  }

  ///预加载某一页
  Future<ReaderChapterData?> preLoadData(int chapter) async {

    await ensureChapter(currentChapterIndex);
    if (currentChapter!.canToTargetChapter(chapter)) {
      final chapterBean=  await ensureChapter(chapter);
      applyConfig(chapterBean);
      preparePagePicture(chapterBean!, chapterBean.currentPageIndex);
      return chapterBean;
    }
    return null;
  }
  Future<ReaderChapterData?> ensureChapter(int chapterIndex) async {
    if (chapterIndex == currentChapterIndex - 1) {
      if (preChapter?.content?.isNotEmpty != true) preChapter = await chapterProvider(chapterIndex);
      return preChapter;
    } else if (chapterIndex == currentChapterIndex) {
      if (currentChapter?.content?.isNotEmpty != true) {
        currentChapter = await chapterProvider(chapterIndex);
        if (firstLoad) {
          currentChapter?.currentPageIndex = startReadPageIndex;
          firstLoad = false;
        }
      }
      return currentChapter;
    } else if (chapterIndex == currentChapterIndex + 1) {
      if (nextChapter?.content?.isNotEmpty != true) nextChapter = await chapterProvider(chapterIndex);
      return nextChapter;
    } else {
      return await chapterProvider(chapterIndex);
    }
  }
  void gesturePanChange(Offset delta,Offset startPosition){

  }
  void reApplyConfig() async {
    await ensureChapter(currentChapterIndex);
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
