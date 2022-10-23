import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:read_info/global/constant.dart';
import 'package:read_info/global/custom/my_theme.dart';
import 'package:read_info/page/view/dash_divider.dart';
import 'package:read_info/utils/utils_screen.dart';
import 'package:read_info/widget/reader/reader_content.dart';

import '../../bean/book_item_bean.dart';
import '../../widget/reader/reder_view.dart';
import 'logic.dart';

class BookContentPage extends StatefulWidget {
  @override
  State<BookContentPage> createState() => _BookContentPageState();
}

class _BookContentPageState extends State<BookContentPage> {
  late BookChapterBean tocBean;
  late BookDetailBean detailBean;

  @override
  initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge, overlays: [SystemUiOverlay.bottom]);

    detailBean = Get.arguments[ARG_BOOK_DETAIL_BEAN];
    Get.find<ContentLogic>().init(detailBean);
  }

  GlobalKey<NovelReaderState> readerKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final logic = Get.find<ContentLogic>();
    return Scaffold(
      body: Builder(
        builder: (context) {
          return NovelReader(
            key:readerKey,
            pageSize: Size(ScreenUtils.getScreenWidth(), ScreenUtils.getScreenHeight() - MediaQuery.of(context).padding.bottom),
            chapterProvider: (i) async {
              var chapter = logic.getChapterByIndex(i);
              if (chapter?.hasContent() != true) await logic.loadChapterContent(chapter);
              return ReaderChapterData()
                ..content = chapter?.content?.content
                ..chapterName = chapter?.chapterName
                ..totalChapterCount = logic.bookDetail.chapters!.length
                ..chapterIndex = i;
            },
            startChapterIndex: logic.currentChapterIndex(),
            startReadPageIndex: logic.bookDetail.readPageIndex,
            readChangeCallback: logic.updateReadPage,
            showIndex: () {
              Scaffold.of(context).openDrawer();
            },
          );
        },
      ),
      drawerEnableOpenDragGesture: false,
      drawer: logic.bookDetail.chapters?.isNotEmpty == true ? Drawer(logic) : null,
    );
  }

  Widget Drawer(ContentLogic logic) {
    return Container(
        width: 350,
        color: Theme.of(context).cardColor,
        child: GetX<ContentLogic>(builder: (ContentLogic logic) {
          return ListView(
            prototypeItem: ChapterItem(context,0,"第一章", true),
            children: logic.bookDetail.chapters!
                .mapIndexed(
                  (i, e) => ChapterItem(context,i,e.chapterName ?? "", i == logic.readChapterIndex.value),
                )
                .toList(),
          );
        }));
  }

  Widget ChapterItem(BuildContext context, index,String name, bool selected) {
    final logic = Get.find<ContentLogic>();
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: (){
        try {
          Scaffold.of(context).closeDrawer();
        }catch (e) {}
        if(index==logic.bookDetail.readChapterIndex){
          return;
        }
        readerKey.currentState?.jumpToChapter(index);
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            child: Text(name + (selected ? "    ☜" : ""), style: MyTheme(context).textTheme.bodyMedium),
          ),
          DashDivider()
        ],
      ),
    );
  }
}
