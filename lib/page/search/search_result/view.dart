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
import 'package:read_info/utils/ext/list_ext.dart';
import 'package:read_info/widget/container.dart';
import 'logic.dart';

class SearchResultPage extends StatefulWidget {
  @override
  State<SearchResultPage> createState() => _SearchResultPageState();
}

class _SearchResultPageState extends State<SearchResultPage> with SingleTickerProviderStateMixin {
  TabController? _tabController;

  @override
  void initState() {
    final logic = Get.put(SearchResultLogic());
    _tabController = TabController(
      initialIndex: 0,
      length: logic.tags.length,
      vsync: this,
    );
    _tabController!.addListener(() {
      if (!_tabController!.indexIsChanging) {
        final logic = Get.find<SearchResultLogic>();
        logic.updateIndex(_tabController!.index);
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _tabController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final logic = Get.find<SearchResultLogic>();
    final novelState = Get.find<SearchResultLogic>().novelState;
    final comicState = Get.find<SearchResultLogic>().comicState;
    return Scaffold(
        appBar: MyAppBar(
            bottom: TabBar(
              controller: _tabController,
              isScrollable: true,
              tabs: logic.tags.map((e) => Tab(text: e, height: 40)).toList(),
            ),
            leading: Row(
              children: [
                MyBackButton(),
                SizedBox(width: 6),
                GetBuilder<SearchResultLogic>(
                  assignId: true,
                  builder: (logic) {
                    final isNovel = logic.currentIndex == 0;
                    final state = isNovel ? novelState : comicState;
                    return Text("${state.searchKey}" + (state.donnSourceCount > 0 ? "(${state.donnSourceCount}/${state.totalSearchCount})" : "") +"  --->${logic.tags[logic.currentIndex]}");
                  },
                ),
              ],
            ),
            trail: [
              GetBuilder<SearchResultLogic>(
                  assignId: true,
                  builder: (logic) {
                    final currentState = logic.currentIndex == 0 ? novelState : comicState;
                    if (currentState.loading)
                      return Row(
                        children: [
                          SizedBox(
                            width: 15,
                            height: 15,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          SizedBox(
                              child: IconButton(
                            padding: EdgeInsets.zero,
                            visualDensity: VisualDensity.compact,
                            icon: Icon(Icons.stop),
                            tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                            onPressed: () {},
                          )),
                        ],
                      );
                    else
                      return SizedBox();
                  })
            ]),
        body: GetBuilder<SearchResultLogic>(
          assignId: true,
          builder: (logic) {
            return TabBarView(
              // physics: NeverScrollableScrollPhysics(),
              controller: _tabController,
              children: logic.tags.mapIndexed((i,e) {
                return ListView(
                    children: logic.getState(i).books.entries
                        .map<Widget>((e) => BookSearchItemWidget(
                              list: e.value,
                            ))
                        .toList());
              }).toList(),
            );
          },
        ));
  }
}

class BookSearchItemWidget extends StatelessWidget {
  const BookSearchItemWidget({Key? key, required this.list}) : super(key: key);

  final List<BookItemBean> list;

  @override
  Widget build(BuildContext context) {
    final bean = list.first;
    return GestureDetector(
      onTap: () async {
        final source = await SourceManager.instance.getSourceFromUrl(bean.sourceUrl);
        debug("跳转到详情页" + bean.toString());
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
                SizedBox(width: 70, height: 100, child: BookCover(bean)),
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
                      Text("书源：" + list.map((e) => e.source?.bookSourceName ?? "").join(','), style: Theme.of(context).textTheme.bodySmall, maxLines: 3, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
              ],
            )),
      ),
    );
  }
}
