import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:read_info/bean/book_item_bean.dart';
import 'package:read_info/config/route_config.dart';
import 'package:read_info/data/rule/RuleUtil.dart';
import 'package:read_info/data/rule/app_helper.dart';
import 'package:read_info/data/source_manager.dart';
import 'package:read_info/global/constant.dart';
import 'package:read_info/global/custom/my_theme.dart';
import 'package:read_info/page/explore/state.dart';
import 'package:read_info/page/view/bookcover.dart';
import 'package:read_info/utils/ext/list_ext.dart';
import 'package:read_info/widget/container.dart';

import '../../bean/entity/source_entity.dart';
import '../view/my_appbar.dart';
import 'logic.dart';

class ExplorePage extends StatefulWidget {
  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> with SingleTickerProviderStateMixin {
  TabController? _tabController;

  @override
  void initState() {
    _tabController = TabController(
      initialIndex: 0,
      length: 12,
      vsync: this,
    );
    final logic = Get.find<ExploreLogic>();
    _tabController!.addListener(() {
      logic.updateIndex(_tabController!.index);
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
    final logic = Get.find<ExploreLogic>();
    return Scaffold(
        appBar: MyAppBar(
          middle: Text(logic.source.bookSourceName ?? ""),
          bottom: logic.exploreTabs.length > 1
              ? TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  tabs: [
                    for (final tab in logic.exploreTabs) Tab(text: tab.title, height: 40),
                  ],
                )
              : null,
        ),
        backgroundColor: CupertinoTheme.of(context).scaffoldBackgroundColor,
        body: TabBarView(
            // physics: NeverScrollableScrollPhysics(),
            controller: _tabController,
            children: logic.exploreTabs
                .mapIndexed((i, e) => GetBuilder<ExploreLogic>(
                      builder: (logic) {
                        final state = logic.states[i]!;
                        if (state.refreshing) {
                          return buildRefreshView();
                        } else if (state.error.isNotEmpty) {
                          return buildErrorView(logic, state, i);
                        } else {
                          return buildContentList(logic, state, i);
                        }
                      },
                    ))
                .toList()));
  }

  ListView buildContentList(ExploreLogic logic, ExploreState state, int index) {
    final logic = Get.find<ExploreLogic>();
    var itemCount = state.books.length + 1;
    return ListView.builder(
      padding: EdgeInsets.symmetric(vertical: 8),
      itemBuilder: (c, i) {
        if (i == itemCount - 1) {
          if (!state.loadEnd) {
            logic.loadMore(index);
          }
          return Container(
            alignment: Alignment.center,
            padding: EdgeInsets.symmetric(vertical: 4),
            child: state.error.isNotEmpty
                ? TextButton(
                    onPressed: () {
                      state.page--;
                      state.error = "";
                      logic.loadMore(index);
                    },
                    child: Text("点击重试"))
                : (state.loadEnd ? Text("已经到底了") : CupertinoActivityIndicator()),
          );
        }
        var bean = state.books[i];
        if (logic.source.bookSourceType == source_type_sms)
          return SMSItemWidget(bean: bean);
        else
          return BookItemWidget(bean: bean);
      },
      itemCount: itemCount,
    );
  }

  Widget buildRefreshView() => Center(child: CupertinoActivityIndicator(radius: 15));

  Widget buildErrorView(ExploreLogic logic, ExploreState state, int index) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Center(
          child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(state.error, textAlign: TextAlign.center),
          SizedBox(height: 16),
          ElevatedButton(
              onPressed: () {
                logic.refreshList(index);
              },
              child: Text("点击重试"))
        ],
      )),
    );
  }
}

class BookItemWidget extends StatelessWidget {
  const BookItemWidget({Key? key, required this.bean}) : super(key: key);

  final BookItemBean bean;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final source = await SourceManager.instance.getSourceFromUrl(bean.sourceUrl);
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
                SizedBox(width: 70, height: 100, child: BookCover(bean, radius: 6)),
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
                      if (bean.intro?.isNotEmpty == true) ...[
                        SizedBox(height: 2),
                        Text(bean.intro!, style: Theme.of(context).textTheme.bodySmall, maxLines: 3, overflow: TextOverflow.ellipsis),
                      ]
                    ],
                  ),
                ),
              ],
            )),
      ),
    );
  }
}

class SMSItemWidget extends StatelessWidget {
  const SMSItemWidget({
    Key? key,
    required this.bean,
  }) : super(key: key);

  final BookItemBean bean;

  @override
  Widget build(BuildContext context) {
    final logic = Get.find<ExploreLogic>();
    return GestureDetector(
      onTap: () {
        logic.toDetailPage(bean);
      },
      child: Center(
        child: Container(
            constraints: BoxConstraints.loose(Size(MyTheme.contentMaxWidth, double.infinity)),
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: EdgeInsets.all(15),
            decoration: RoundedBoxDecoration(radius: 10, color: Theme.of(context).cardColor),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (bean.name?.isNotEmpty == true) ...[
                  Text(bean.name ?? "", style: Theme.of(context).textTheme.bodyLarge),
                  SizedBox(height: 6),
                ],
                if (bean.author?.isNotEmpty == true) ...[
                  Text(bean.author!, style: Theme.of(context).textTheme.caption),
                  SizedBox(height: 4),
                ],
                Text(bean.intro ?? "", style: Theme.of(context).textTheme.bodySmall),
                SizedBox(height: 8),
                if (bean.coverUrl?.isNotEmpty == true)
                  AspectRatio(
                      aspectRatio: 2.5,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          bean.coverUrl!,
                          fit: BoxFit.cover,
                        ),
                      ))
              ],
            )),
      ),
    );
  }
}
