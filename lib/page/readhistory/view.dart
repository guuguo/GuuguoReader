import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:read_info/global/custom/my_theme.dart';
import 'package:read_info/global/logic.dart';
import 'package:read_info/page/view/bookcover.dart';
import 'package:read_info/page/view/icon.dart';
import 'package:read_info/page/view/my_appbar.dart';
import 'package:read_info/widget/container.dart';

import '../../bean/book_item_bean.dart';
import 'logic.dart';

class ReadHistoryPage extends StatefulWidget {
  @override
  State<ReadHistoryPage> createState() => _ReadHistoryPageState();
}

class _ReadHistoryPageState extends State<ReadHistoryPage> {
  @override
  Widget build(BuildContext context) {
    Get.put(ReadHistoryLogic());
    final globalLogic=Get.find<GlobalLogic>();
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: MyAppBar(leading: SearchItem(), trail: [
        PrimaryIconButton(
          MyTheme(context).isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
          onPressed: () {
            globalLogic.changeThemeMode(context);
          },
        ),
        PrimaryIconButton(Icons.more_vert),
      ]),
      body: GetBuilder<ReadHistoryLogic>(
        assignId: true,
        builder: (logic) {
          final state = logic.state;
          if (state.books.isEmpty) {
            return Center(child: Text("当前还没有阅读历史"));
          }
          return ListView(children: state.books.map((e) => BookReadItemWidget(bean: e)).toList());
        },
      ),
    );
  }
}

class SearchItem extends StatelessWidget {
  const SearchItem({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.find<ReadHistoryLogic>().toSearchPage();
      },
      child: Container(
          alignment: Alignment.center,
          child: Container(
            height: 33,
            decoration: RoundedBoxDecoration(radius: 20, color: MyTheme(context).searchBarColor),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              textBaseline: TextBaseline.ideographic,
              children: [
                SizedBox(width: 10),
                Icon(
                  Icons.search,
                  color: MyTheme(context).primaryColor,
                  size: 18,
                ),
                SizedBox(width: 4),
                Text("信息阅读", style: MyTheme(context).textTheme.caption?.copyWith(height: 1))
              ],
            ),
          )),
    );
  }
}

class BookReadItemWidget extends StatelessWidget {
  const BookReadItemWidget({
    Key? key,
    required this.bean,
  }) : super(key: key);

  final BookDetailBean bean;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashFactory: InkSplash.splashFactory,
      onTap: () {
        Get.find<ReadHistoryLogic>().toReadPage(bean);
      },
      child: Ink(
          // constraints: BoxConstraints.loose(Size(MyTheme.contentMaxWidth, double.infinity)),
          padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (bean.coverUrl?.isNotEmpty == true)
                Container(
                    width: 40,
                    height: 60,
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(2), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 3,offset: Offset(0,0),blurStyle: BlurStyle.outer)]),
                    child: BookCover(bean,radius: 2)),
              SizedBox(width: 20),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Flexible(flex: 1, child: Text(bean.name ?? "", style: Theme.of(context).textTheme.bodyLarge, overflow: TextOverflow.ellipsis)),
                        SizedBox(width: 4),
                        Text("(未读${bean.totalChapterCount - bean.readChapterIndex - 1}章)", style: Theme.of(context).textTheme.caption),
                      ],
                    ),
                    SizedBox(height: 2),
                    Text("${bean.readChapterIndex + 1}/${bean.totalChapterCount}", style: Theme.of(context).textTheme.bodySmall, maxLines: 3, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
            ],
          )),
    );
  }
}
