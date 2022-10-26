import 'dart:convert';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:orientation/orientation.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:read_info/global/constant.dart';
import 'package:read_info/global/custom/my_theme.dart';
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

class _BookContentPageState extends State<BookContentPage> {
  late BookChapterBean tocBean;
  late BookDetailBean detailBean;
  late ReaderPageProgress pageProgress;

  @override
  void dispose() {
    super.dispose();
    OrientationPlugin.setPreferredOrientations([...DeviceOrientation.values]..remove(DeviceOrientation.portraitDown));
    OrientationPlugin.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    Get.delete<ContentLogic>();
  }

  @override
  initState() {
    super.initState();
    OrientationPlugin.forceOrientation(DeviceOrientation.portraitUp);
    OrientationPlugin.setEnabledSystemUIOverlays([SystemUiOverlay.top]);
    // SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge, overlays: [SystemUiOverlay.top]);

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
          final _comics = (array ?? (chapterData.content?.split("\n")))?.where((e) => Uri.tryParse(e) != null).toList() ?? [];
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
              pageSize: Size(ScreenUtils.getScreenWidth(), ScreenUtils.getScreenHeight() ),
              pageProgress: pageProgress,
              showCategory: () {
                Scaffold.of(context).openDrawer();
              },
            );
          else {
            return ComicReader(
              key: comicKey,
              pageProgress: pageProgress,
              pageSize: Size(ScreenUtils.getScreenWidth(), ScreenUtils.getScreenHeight() ),
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
        width: 280,
        padding: EdgeInsets.only(bottom: 20),
        color: Theme.of(context).cardColor,
        child: GetX<ContentLogic>(builder: (ContentLogic logic) {
          final itemHeight = 35.0;
          final currentChapter = logic.bookDetail.chapters![logic.readChapterIndex.value];
          return SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    controller: ScrollController(initialScrollOffset: max(logic.readChapterIndex.value - 8, 0) * itemHeight),
                    itemExtent: itemHeight,
                    children: logic.bookDetail.chapters!
                        .mapIndexed(
                          (i, e) => ChapterItem(context, i, e, i == logic.readChapterIndex.value),
                        )
                        .toList(),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical:8,horizontal:10),
                  child: Row(children: [
                    Text(
                      "${currentChapter.chapterName} (${logic.readChapterIndex.value}/${logic.bookDetail.totalChapterCount})",
                      style: Theme.of(context).textTheme.caption?.copyWith(fontSize: 10),
                    ),
                  ]),
                )
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
                  style: MyTheme(context).textTheme.caption?.copyWith(color: bean.content != null ? MyTheme(context).textTheme.bodyMedium?.color : null), maxLines: 1, overflow: TextOverflow.ellipsis),
            )),
            DashDivider()
          ],
        ),
      );
    });
  }
}
