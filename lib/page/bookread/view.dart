import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:read_info/global/constant.dart';
import 'package:read_info/global/custom/my_theme.dart';
import 'package:read_info/page/view/dash_divider.dart';
import 'package:read_info/utils/developer.dart';
import 'package:read_info/utils/utils_screen.dart';
import 'package:read_info/widget/reader/reader_content.dart';
import 'package:read_info/widget/reader/reader_page_progress.dart';
import 'package:read_info/widget/reader/reader_viewmodel.dart';

import '../../bean/book_item_bean.dart';
import '../../data/rule/app_helper.dart';
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
  initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge, overlays: [SystemUiOverlay.bottom]);

    detailBean = Get.arguments[ARG_BOOK_DETAIL_BEAN];
    final logic=Get.find<ContentLogic>();
    logic.init(detailBean);
    pageProgress=ReaderPageProgress(
      logic.currentChapterIndex(),
      logic.bookDetail.readPageIndex,
      logic.bookDetail.totalChapterCount,
      readChangeCallback: logic.updateReadPage,
      chapterCacheDeleter: logic.deleteChapter,
      chapterProvider: (i) async {
        var chapter = logic.getChapterByIndex(i);
        if (chapter?.hasContent() != true) await logic.loadChapterContent(chapter);

        final chapterData= ReaderChapterData.FromIndex(chapterIndex: i)
          ..content = chapter?.content?.content
          ..chapterName = chapter?.chapterName;

        if(logic.source.bookSourceType==source_type_comic){
          List<String>? array;
          try {
            List<dynamic> list = json.decode(chapterData.content??"");
            array = list.map((e) => e.toString()).toList();
          } catch (e) {
            debug(e);
          }
          final _comics = (array ?? (chapterData.content?.split("\n")))?.where((e) => Uri.tryParse(e) != null).toList() ?? [];
          chapterData.comics= _comics;
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
              pageSize: Size(ScreenUtils.getScreenWidth(), ScreenUtils.getScreenHeight() - MediaQuery
                  .of(context)
                  .padding
                  .bottom),
              pageProgress: pageProgress,
              showCategory: () {
                Scaffold.of(context).openDrawer();
              },
            );
          else {
            return ComicReader(
              key: comicKey,
              pageProgress:pageProgress,
              pageSize: Size(ScreenUtils.getScreenWidth(), ScreenUtils.getScreenHeight() - MediaQuery.of(context).padding.bottom),
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
        color: Theme
            .of(context)
            .cardColor,
        child: GetX<ContentLogic>(builder: (ContentLogic logic) {
          return ListView(
            prototypeItem: ChapterItem(context, 0, "第一章", true),
            children: logic.bookDetail.chapters!
                .mapIndexed(
                  (i, e) => ChapterItem(context, i, e.chapterName ?? "", i == logic.readChapterIndex.value),
            )
                .toList(),
          );
        }));
  }

  Widget ChapterItem(BuildContext context, index, String name, bool selected) {
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
            Container(
              padding: EdgeInsets.only(top: 10, bottom: 10, left: 16),
              child: Text(name + (selected ? "    ☜" : ""), style: MyTheme(context).textTheme.bodyMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
            DashDivider()
          ],
        ),
      );
    });
  }
}
