import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:get/get.dart';
import 'package:read_info/global/constant.dart';
import 'package:read_info/global/custom/my_theme.dart';
import 'package:read_info/widget/reader/reader_content.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../bean/book_item_bean.dart';
import '../../config/route_config.dart';
import '../../widget/reader/reader_viewmodel.dart';
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
    tocBean = Get.arguments[ARG_BOOK_TOC_BEAN];
    detailBean = Get.arguments[ARG_BOOK_DETAIL_BEAN];
    Get.find<ContentLogic>().init(detailBean, tocBean);
  }

  @override
  Widget build(BuildContext context) {
    final logic = Get.find<ContentLogic>();
    return Scaffold(
      // appBar: CupertinoNavigationBar(middle: Text("${tocBean.chapterName}")),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: GetX<ContentLogic>(
          builder: (ContentLogic logic) {
            final bean = logic.bookContent.value;
            print(bean?.content ?? "");
            return NovelReader(
              chapterProvider: (i) async {
                var chapter = logic.getChapterByIndex(i);
                if(chapter?.content==null)
                  await logic.loadChapterContent(chapter);
                return ReaderChapterData()
                  ..content = chapter?.content?.content
                  ..chapterName = chapter?.chapterName
                  ..chapterIndex = i;
              },
              currentChapterIndex: logic.currentChapterIndex(),
            ); /*SingleChildScrollView(
              child: Center(
                child: Container(
                  constraints: BoxConstraints.loose(Size(800, double.infinity)),
                  padding: const EdgeInsets.all(15.0),
                  child: Column(
                    children: [
                      Html(
                        data: bean?.content ?? "",
                        customRenders: {
                          (RenderContext context) {
                            return context.tree.element?.localName=="br";
                          }: CustomRender.inlineSpan(inlineSpan: (c, inlines) {
                            return TextSpan(text:"\n\n",children: inlines());
                          })
                        },
                        style: {
                          "body": Style(
                            fontSize:FontSize.larger,
                          )
                        },
                      ),
                      Center(child: TextButton(onPressed: ()async{
                        var routeRouteConfig = RouteConfig.bookcontent;
                        return await Get.offAndToNamed(routeRouteConfig,
                            arguments: {ARG_BOOK_TOC_BEAN: logic.getNextToc(), ARG_BOOK_DETAIL_BEAN: logic.bookDetail});
                      },child: Text("下一章"),),)
                    ],
                  ),
                ),
              ),
            );*/
          },
        ),
      ),
    );
  }
}
