import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:read_info/global/constant.dart';
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

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge,overlays: [SystemUiOverlay.bottom]);


    detailBean = Get.arguments[ARG_BOOK_DETAIL_BEAN];
    Get.find<ContentLogic>().init(detailBean);
  }
  // @override
  // void dispose() {
  //   super.dispose();
  //   SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  // }
  @override
  Widget build(BuildContext context) {
    final logic = Get.find<ContentLogic>();
    return GetX<ContentLogic>(

      builder: (ContentLogic logic) {
          final content = logic.bookContent.value;
          return NovelReader(
            pageSize: Size(ScreenUtils.getScreenWidth(),ScreenUtils.getScreenHeight()-MediaQuery.of(context).padding.vertical ),
            chapterProvider: (i) async {
              var chapter = logic.getChapterByIndex(i);
              if (chapter?.hasContent()!=true) await logic.loadChapterContent(chapter);
              return ReaderChapterData()
                ..content = chapter?.content?.content
                ..chapterName = chapter?.chapterName
                ..totalChapterCount = logic.bookDetail.chapters!.length
                ..chapterIndex = i;
            },
            startChapterIndex: logic.currentChapterIndex(),
            startReadPageIndex: logic.bookDetail.readPageIndex,
            readChangeCallback: logic.updateReadPage,
          );
        },
    );
  }
}
