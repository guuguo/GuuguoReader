import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:get/get.dart';
import 'package:read_info/data/rule/app_helper.dart';
import 'package:read_info/global/constant.dart';
import 'package:read_info/global/custom/component/limit_width_box.dart';
import 'package:read_info/global/custom/my_theme.dart';
import 'package:read_info/page/detailsms/logic.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../bean/book_item_bean.dart';
import '../view/my_appbar.dart';

class DetailBookPage extends StatefulWidget {
  @override
  State<DetailBookPage> createState() => _DetailSmsPageState();
}

class _DetailSmsPageState extends State<DetailBookPage> {
  late BookItemBean itemBean;

  @override
  initState() {
    super.initState();
    itemBean = Get.arguments[ARG_BOOK_ITEM_BEAN];
    Get.find<DetailLogic>().init(itemBean);
  }

  @override
  void dispose() {
    super.dispose();
    Get.delete<DetailLogic>();
  }

  @override
  Widget build(BuildContext context) {
    final logic = Get.find<DetailLogic>();
    return Scaffold(
      appBar: MyAppBar(middle: Text("${itemBean.name}")),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: GetX<DetailLogic>(
          builder: (DetailLogic logic) {
            final bean = logic.detail.value;
            if (logic.refreshing.value) {
              return buildLoadingView();
            } else {
              return buildDetailContent(bean, logic, context);
            }
          },
        ),
      ),
    );
  }

  Widget buildDetailContent(
      BookDetailBean? bean, DetailLogic logic, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal:16),
      child: CustomScrollView(
        physics: BouncingScrollPhysics(),
        slivers: [
          SliverPadding(padding: EdgeInsets.all(6)),
          SliverToBoxAdapter(
            child: LimitWidthBox(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  SizedBox(height: 10),
                  BookCover(bean, logic),
                  SizedBox(height: 14),
                  Text(bean?.name ?? "",
                      style: MyTheme(context).textTheme.titleLarge),
                  SizedBox(height: 4),
                  BookCaptionInfo(bean, context),
                  SizedBox(height: 14),
                  BookIntro(context, logic),
                  SizedBox(height: 20),
                  Divider(thickness: 2),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
          if (logic.detail.value?.chapters?.isNotEmpty==true)
            SliverPadding(
              sliver: SliverGrid.count(
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 3,
                crossAxisCount: 3,
                children:
                    logic.detail.value!.chapters!.map((e) => ChapterItem(e)).toList(),
              ),
              padding: EdgeInsets.symmetric(
                  horizontal: max((MediaQuery.of(context).size.width -
                      MyTheme.contentMaxWidth) /2, 0
                  )),
            ),
          SliverPadding(padding: EdgeInsets.all(20)),
        ],
      ),
    );
  }

  Widget ChapterItem(BookChapterBean e) {
    final logic = Get.find<DetailLogic>();
    return GestureDetector(
      onTap: () {
        logic.toBookContentPage(e);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 4),
        decoration: ShapeDecoration(
          color: Theme.of(context).cardColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Center(child: Text(e.chapterName ?? "", textAlign: TextAlign.center,style:MyTheme(context).textTheme.bodySmall)),
      ),
    );
  }

  Container BookIntro(BuildContext context, DetailLogic logic) {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: ShapeDecoration(
        color: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Html(
        onLinkTap: (url, context, attr, ele) {
          launchUrl(
            Uri.parse(url ?? ""),
            mode: LaunchMode.externalApplication,
          );
        },
        data: logic.detail.value?.intro ?? "",
      ),
    );
  }

  Row BookCaptionInfo(BookDetailBean? bean, BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(bean?.author ?? "", style: MyTheme(context).textTheme.caption),
        if (bean?.kind?.isNotEmpty == true) ...[
          SizedBox(width: 14),
          Text(bean?.kind ?? "", style: MyTheme(context).textTheme.caption)
        ],
      ],
    );
  }

  Container BookCover(BookDetailBean? bean, DetailLogic logic) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
              color: Color(0x33000000), offset: Offset(0, 0), blurRadius: 3)
        ],
        borderRadius: BorderRadius.circular(2),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(2),
        child: Image.network(
            bean?.coverUrl ?? "",
            width: 100),
      ),
    );
  }

  Center buildLoadingView() => Center(child: CupertinoActivityIndicator());
}
