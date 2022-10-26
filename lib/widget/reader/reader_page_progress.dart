import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:read_info/widget/reader/reader_content.dart';
import 'package:read_info/widget/reader/reader_viewmodel.dart';
import 'package:read_info/widget/reader/reder_view.dart';

class ReaderPageProgress {
  int currentChapterIndex;
  int totalChapterCount;
  int currentPageIndex;
  ReaderChapterData? currentChapter;
  ReaderChapterData? preChapter;
  ReaderChapterData? nextChapter;

  final ChapterProvider chapterProvider;
  final ChapterCacheDeleter chapterCacheDeleter;
  final ReadPageChangeCallback readChangeCallback;
  ///准备chapter页面 计算当前章节段落和页数,小说使用
  ValueChanged<ReaderChapterData?>? chapterPrepare;

  bool canToTargetChapter(int chapter) {
    return chapter >= 0 && chapter < totalChapterCount;
  }

  ReaderPageProgress(
    this.currentChapterIndex,
    this.currentPageIndex,
    this.totalChapterCount, {
    required this.chapterProvider,
    required this.chapterCacheDeleter,
    required this.readChangeCallback,
  });

  Future reloadCurrentPageCache() async {
    currentChapter?.content = "";
    await chapterCacheDeleter.call(currentChapterIndex);
    await ensureCurrentChapter();
  }

  Future toTargetChapter(int chapterIndex, [int targetPageIndex = 0]) async {
    if (!canToTargetChapter(chapterIndex)) {
      Get.snackbar("提示", "没有数据了", duration: Duration(milliseconds: 2000));
      return;
    }
    try {
      final currentChapter = getChapterFromIndex(chapterIndex);
      final preChapter = getChapterFromIndex(chapterIndex - 1);
      final nextChapter = getChapterFromIndex(chapterIndex + 1);
      this.currentChapter = currentChapter;
      this.preChapter = preChapter;
      this.nextChapter = nextChapter;

      currentChapterIndex = chapterIndex;
      currentChapter?.currentPageIndex = targetPageIndex;
      currentPageIndex = targetPageIndex;
      readChangeCallback(currentPageIndex, currentChapterIndex);
    }catch (e) {}
    return true;
  }

  Pair<int, int> prePage() {
    if (currentChapter!.canToPrePage()) {
      return Pair(currentChapterIndex, currentPageIndex - 1);
    }
    return Pair(currentChapterIndex - 1, (preChapter?.chapterContentConfigs.length ?? 1) - 1);
  }
  Pair<int, int> nextPage() {
    if (currentChapter!.canToNextPage()) {
      return Pair(currentChapterIndex, currentPageIndex + 1);
    }
    return Pair(currentChapterIndex + 1,0);
  }
  //跳转到下一页
  Future toNextPage() async {
    await ensureChapterContent(currentChapterIndex);
    if (currentChapter!.toNextPage()) {
      currentPageIndex=currentChapter!.currentPageIndex;
      readChangeCallback(currentChapter!.currentPageIndex, currentChapterIndex);
    } else {
      toTargetChapter(currentChapterIndex + 1);
    }
  }

//跳转到上一页
  Future toPrePage() async {
    await ensureChapterContent(currentChapterIndex);
    try {
      if (currentChapter!.toPrePage()) {
        currentPageIndex=currentChapter!.currentPageIndex;
        readChangeCallback(currentChapter!.currentPageIndex, currentChapterIndex);
      } else {
        final chapter=await ensureChapterContent(currentChapterIndex-1);
        toTargetChapter(currentChapterIndex-1,chapter!.chapterContentConfigs.length-1);
      }
    } catch (e) {}
  }

  Future preloadData() async {
    await preloadNextData();
    await preloadPreData();
  }
  Future preloadPreData() async {
    await ensureChapterContent(currentChapterIndex - 1);
  }
  Future preloadNextData() async {
    await ensureChapterContent(currentChapterIndex + 1);
  }
  bool chapterContentReady(int chapter) {
    if (chapter == currentChapter?.chapterIndex) return currentChapter?.content?.isNotEmpty == true;
    if (chapter == preChapter?.chapterIndex) return preChapter?.content?.isNotEmpty == true;
    if (chapter == nextChapter?.chapterIndex) return nextChapter?.content?.isNotEmpty == true;
    return false;
  }

  Future? ensureChapterFuture;
  bool currentChapterReady()  {
    return currentChapter?.content?.isNotEmpty==true;
  }
  Future<ReaderChapterData?> ensureCurrentChapter() async {
    final chapter= await ensureChapterContent(currentChapterIndex);
    currentChapter?.currentPageIndex=currentPageIndex;
    return chapter;
  }

  ///正在加载章节内容中
  Future<ReaderChapterData?> ensureChapterContent(int chapterIndex) async {
    if (ensureChapterFuture != null) {
      return await ensureChapterFuture;
    } else {
      ensureChapterFuture = _ensureChapterContentPrivate(chapterIndex).whenComplete(() {
        ensureChapterFuture = null;
      });
      return await ensureChapterFuture;
    }
  }

  ReaderChapterData? getChapterFromIndex(int chapter) {
    if (chapter == currentChapter?.chapterIndex) {
      return currentChapter;
    }
    if (chapter == preChapter?.chapterIndex) {
      return preChapter;
    }
    if (chapter == nextChapter?.chapterIndex) {
      return nextChapter;
    }
    return null;
  }

  ///正在加载章节内容中,只被[ensureChapterContent]方法调用。管理同时预加载的网页只有一个
  Future<ReaderChapterData?> _ensureChapterContentPrivate(int chapterIndex) async {
    ReaderChapterData? chapter;
    if (!chapterContentReady(chapterIndex)) {
      chapter = await chapterProvider(chapterIndex);
      chapterPrepare?.call(chapter);
    }else{
      return getChapterFromIndex(chapterIndex);
    }
    if (chapter != null) {
      if (chapterIndex == currentChapterIndex - 1) {
        preChapter = chapter;
      } else if (chapterIndex == currentChapterIndex) {
        currentChapter = chapter;
      } else if (chapterIndex == currentChapterIndex + 1) {
        nextChapter = chapter;
      }
    }
    return chapter;
  }
}

class Pair<T, K> {
  const Pair(this.first, K this.seconed);

  final T first;
  final K seconed;
}