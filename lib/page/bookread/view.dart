import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:orientation/orientation.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:read_info/global/constant.dart';
import 'package:read_info/global/custom/my_theme.dart';
import 'package:read_info/page/common/widget_common.dart';
import 'package:read_info/page/view/dash_divider.dart';
import 'package:read_info/utils/developer.dart';
import 'package:read_info/utils/utils_screen.dart';
import 'package:read_info/widget/reader/reader_content.dart';
import 'package:read_info/widget/reader/reader_page_progress.dart';

import '../../bean/book_item_bean.dart';
import '../../widget/reader/reder_view.dart';
import 'comicreader/reder_view.dart';
import 'logic.dart';

class BookContentPage extends StatefulWidget {
  @override
  State<BookContentPage> createState() => _BookContentPageState();
}

class _BookContentPageState extends State<BookContentPage> with WidgetsBindingObserver {
  late BookChapterBean tocBean;
  late BookDetailBean detailBean;
  late ReaderPageProgress pageProgress;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      initStatus();
    }
  }

  initStatus() {
    if (!Platform.isAndroid && !Platform.isIOS) return;
    OrientationPlugin.forceOrientation(DeviceOrientation.portraitUp);
    OrientationPlugin.setEnabledSystemUIOverlays([SystemUiOverlay.top]);
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
    Get.delete<ContentLogic>();
    if (!Platform.isIOS && !Platform.isAndroid) return;
    OrientationPlugin.setPreferredOrientations([...DeviceOrientation.values]..remove(DeviceOrientation.portraitDown));
    OrientationPlugin.setEnabledSystemUIOverlays(SystemUiOverlay.values);
  }

  @override
  initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    initStatus();
    detailBean = Get.arguments[ARG_BOOK_DETAIL_BEAN];
    final logic = Get.find<ContentLogic>();
    logic.init(detailBean);
    pageProgress = ReaderPageProgress(
      logic.currentChapterIndex(),
      logic.bookDetail.readPageIndex,
      logic.bookDetail.totalChapterCount,
      readChangeCallback: logic.updateReadPage,
      chapterCacheDeleter: logic.deleteChapter,
      chapterProvider: (i) async {
        var chapter = logic.getChapterByIndex(i);
        if (chapter?.hasContent() != true) await logic.loadChapterContent(chapter);

        final chapterData = ReaderChapterData.FromIndex(chapterIndex: i)
          ..content = chapter?.content?.content
          ..chapterName = chapter?.chapterName;

        if (logic.source.bookSourceType == source_type_comic) {
          List<String>? array;
          try {
            List<dynamic> list = json.decode(chapterData.content ?? "");
            array = list.map((e) => e.toString()).toList();
          } catch (e) {
            debug(e);
          }
          final _comics = (array ?? (chapterData.content?.split("\n")))?.where((e) => e.isNotEmpty && (Uri.tryParse(e) != null)).toList() ?? [];
          chapterData.comics = _comics;
          print(chapterData.comics.join("   "));
        }

        return chapterData;
      },
    );
  }

  GlobalKey<NovelReaderState> readerKey = GlobalKey();
  GlobalKey<ComicReaderState> comicKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final logic = Get.find<ContentLogic>();
    return Scaffold(
      body: Builder(
        builder: (context) {
          if (logic.source.bookSourceType == source_type_novel)
            return NovelReader(
              key: readerKey,
              pageSize: Size(ScreenUtils.getScreenWidth(), ScreenUtils.getScreenHeight()),
              pageProgress: pageProgress,
              showCategory: () {
                Scaffold.of(context).openDrawer();
              },
            );
          else {
            return ComicReader(
              key: comicKey,
              pageProgress: pageProgress,
              pageSize: Size(ScreenUtils.getScreenWidth(), ScreenUtils.getScreenHeight()),
              showCategory: () {
                Scaffold.of(context).openDrawer();
              },
            );
          }
        },
      ),
      drawerEnableOpenDragGesture: false,
      drawer: logic.bookDetail.chapters?.isNotEmpty == true ? Drawer(logic) : null,
    );
  }

  Widget Drawer(ContentLogic logic) {
    return Container(
        width: 290,
        padding: EdgeInsets.only(bottom: 20),
        color: Theme.of(context).cardColor,
        child: GetBuilder<ContentLogic>(builder: (ContentLogic logic) {
          final itemHeight = 35.0;
          final currentChapter = logic.bookDetail.chapters![logic.readChapterIndex];
          final controller = ScrollController(initialScrollOffset: max(logic.readChapterIndex - 8, 0) * itemHeight);
          return SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: Scrollbar(
                    interactive: true,
                    thickness: 8,
                    thumbVisibility: true,
                    controller: controller,
                    child: ScrollConfiguration(
                        behavior: MyBehavior(),
                        child: ListView(
                          controller: controller,
                          itemExtent: itemHeight,
                          children: logic.bookDetail.chapters!
                              .mapIndexed(
                                (i, e) => ChapterItem(context, i, e, i == logic.readChapterIndex),
                              )
                              .toList(),
                        )),
                  ),
                ),
                Row(children: [
                  SizedBox(width: 10),
                  Text("${currentChapter.chapterName} (${logic.readChapterIndex}/${logic.bookDetail.totalChapterCount})", style: Theme.of(context).textTheme.caption?.copyWith(fontSize: 10)),
                  Expanded(child: SizedBox()),
                  GestureDetector(
                    onTap: () async {
                      final cancel = "正在更新章节列表".showLoading();
                      await logic.loadChapters();
                      cancel();
                      pageProgress.totalChapterCount=logic.bookDetail.totalChapterCount;
                    },
                    child: Padding(padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10), child: Text("更新", style: Theme.of(context).textTheme.caption?.copyWith(fontSize: 10))),
                  ),
                ]),
              ],
            ),
          );
        }));
  }

  Widget ChapterItem(BuildContext context, index, BookChapterBean bean, bool selected) {
    final logic = Get.find<ContentLogic>();
    return Builder(builder: (context) {
      return GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          Scaffold.of(context).closeDrawer();
          if (index == logic.bookDetail.readChapterIndex) {
            return;
          }
          readerKey.currentState?.jumpToChapter(index);
          comicKey.currentState?.jumpToChapter(index);
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
                child: Container(
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.only(left: 16),
              child: Text((bean.chapterName ?? "") + (selected ? "  ✔" : ""),
                  style: MyTheme(context).textTheme.caption?.copyWith(color: bean.cached==true||bean.content != null ? MyTheme(context).textTheme.bodyMedium?.color : null), maxLines: 1, overflow: TextOverflow.ellipsis),
            )),
            DashDivider()
          ],
        ),
      );
    });
  }
}

class MyBehavior extends ScrollBehavior {
  @override
  Widget buildViewportChrome(BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}
