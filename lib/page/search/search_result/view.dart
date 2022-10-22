import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:read_info/bean/book_item_bean.dart';
import 'package:read_info/config/route_config.dart';
import 'package:read_info/data/source_manager.dart';
import 'package:read_info/global/constant.dart';
import 'package:read_info/global/custom/my_theme.dart';
import 'package:read_info/page/explore/view.dart';
import 'package:read_info/page/view/bookcover.dart';
import 'package:read_info/page/view/my_appbar.dart';
import 'package:read_info/utils/developer.dart';
import 'package:read_info/widget/container.dart';
import 'logic.dart';

class SearchResultPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    final logic = Get.put(SearchResultLogic());
    final state = Get
        .find<SearchResultLogic>()
        .state;

    return Scaffold(
        appBar: MyAppBar(
            leading: Row(
              children: [
                MyBackButton(),
                SizedBox(width: 6),
                GetBuilder<SearchResultLogic>(
                  assignId: true,
                  builder: (logic) {
                    return Text("${state.searchKey}" + (state.donnSourceCount > 0 ? "(${state.donnSourceCount})" : ""));
                  },
                ),
              ],
            ),
            trail: [
              SizedBox(
                  width: 15,
                  height: 15,
                  child: GetBuilder<SearchResultLogic>(
                    assignId: true,
                    builder: (logic) {
                      if (state.loading)
                        return CircularProgressIndicator(strokeWidth: 2);
                      else
                        return SizedBox();
                    },
                  )),
              IconButton(
                padding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
                icon: Icon(Icons.stop),
                tooltip: MaterialLocalizations
                    .of(context)
                    .backButtonTooltip,
                onPressed: () {},
              ),
            ]),
        body: GetBuilder<SearchResultLogic>(
          assignId: true,
          builder: (logic) {
            return ListView(
                children: state.books.entries
                    .map((e) => BookSearchItemWidget(
                          list: e.value,
                        ))
                    .toList());
          },
        ));
  }
}
class BookSearchItemWidget extends StatelessWidget {
  const BookSearchItemWidget({Key? key, required this.list}) : super(key: key);

  final List<BookItemBean> list;

  @override
  Widget build(BuildContext context) {
    final bean=list.first;
    return GestureDetector(
      onTap: () async {
        final source=await SourceManager.instance.getSourceFromUrl(bean.sourceUrl);
        debug("跳转到详情页"+bean.toString());
        return await Get.toNamed(RouteConfig.detailbook, arguments: {ARG_BOOK_ITEM_BEAN: bean, ARG_ITEM_SOURCE_BEAN: source});
      },
      child: Center(
        child: Container(
            constraints: BoxConstraints.loose(Size(MyTheme.contentMaxWidth, double.infinity)),
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            decoration: RoundedBoxDecoration(radius: 10, color: Theme.of(context).cardColor),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                  SizedBox(
                      width: 70,
                      height: 100,
                      child: BookCover(bean)),
                SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(bean.name ?? "", style: Theme.of(context).textTheme.bodyLarge),
                      SizedBox(height: 6),
                      Row(
                        children: [
                          Text(bean.author?.trim() ?? "", style: Theme.of(context).textTheme.bodySmall),
                        ],
                      ),
                        SizedBox(height: 2),
                        Text("书源："+list.map((e) => e.source?.bookSourceName??"").join(','), style: Theme.of(context).textTheme.bodySmall, maxLines: 3, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
              ],
            )),
      ),
    );
  }
}
