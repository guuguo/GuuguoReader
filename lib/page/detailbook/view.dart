import 'dart:collection';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:get/get.dart';
import 'package:read_info/bean/entity/source_entity.dart';
import 'package:read_info/data/rule/app_helper.dart';
import 'package:read_info/data/source_manager.dart';
import 'package:read_info/global/constant.dart';
import 'package:read_info/global/custom/component/limit_width_box.dart';
import 'package:read_info/global/custom/my_theme.dart';
import 'package:read_info/page/bookread/view.dart';
import 'package:read_info/page/detailsms/logic.dart';
import 'package:read_info/page/view/bookcover.dart';
import 'package:read_info/page/view/icon.dart';
import 'package:read_info/page/view/popmenuubutton.dart';
import 'package:read_info/widget/reader/reader_menu.dart';
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
    dynamic bean = Get.arguments[ARG_BOOK_ITEM_BEAN];
    if (bean is List<BookItemBean>) {
      itemBean = bean.first;
      Get.find<DetailLogic>().init(bean);
    } else {
      itemBean = bean;
      Get.find<DetailLogic>().init([bean]);
    }
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
      appBar: MyAppBar(
        middle: Text("${itemBean.name}"),
        trail: [
          PopupMenuButton(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: EdgeInsets.zero,
              child: PrimaryIconButton(
                Icons.more_vert,
              ),
              itemBuilder: (BuildContext context) => [
                    popItem(
                        icon: Icons.repeat_on_sharp,
                        text: "书源规则编辑",
                        onTap: () {
                          final logic = Get.find<DetailLogic>();
                          final bookRule = logic.source.ruleBookInfo?.copyWith();
                          Future.delayed(Duration(milliseconds: 10), () {
                            Get.dialog(
                              BookRuleEditDialog(
                                onRuleConfirm: (rule) {
                                  logic.onRuleConfirm(rule);
                                },
                                ruleBookInfo: bookRule,
                              ),
                            );
                          });
                        })
                  ])
        ],
      ),
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

  Future<HashSet<BookItemBean>?> loadSources(DetailLogic logic) async {
    final items = logic.detail.value?.searchResult;
    if (items?.isNotEmpty == true) {
      for (var i in items!) {
        i.source = await SourceManager.instance.getSourceFromUrl(i.sourceUrl);
      }
    }
    return items;
  }

  var controller = ScrollController();

  Widget buildDetailContent(BookDetailBean? bean, DetailLogic logic, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Scrollbar(
        controller: controller,
        thickness: 10,
        interactive: true,
        radius: Radius.circular(6),
        thumbVisibility: true,
        child: CustomScrollView(
          controller: controller,
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
                    SizedBox(width: 75, height: 100, child: BookCover(bean)),
                    SizedBox(height: 14),
                    Text(bean?.name ?? "", style: MyTheme(context).textTheme.titleLarge),
                    SizedBox(height: 4),
                    BookCaptionInfo(bean, context),
                    SourceChoose(logic),
                    SizedBox(height: 8),
                    BookIntro(context, logic),
                    SizedBox(height: 20),
                    Divider(thickness: 2),
                    SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            if (logic.refreshTocs.value == true)
              SliverPadding(
                sliver: SliverGrid.count(
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childAspectRatio: 3,
                  crossAxisCount: 3,
                  children: logic.detail.value!.chapters!.map((e) => ChapterItem(e)).toList(),
                ),
                padding: EdgeInsets.symmetric(horizontal: max((MediaQuery.of(context).size.width - MyTheme.contentMaxWidth) / 2, 0)),
              )
            else
              SliverToBoxAdapter(child: SizedBox(height:50,child: CircularProgressIndicator())),
            SliverPadding(padding: EdgeInsets.all(20)),
          ],
        ),
      ),
    );
  }

  Widget SourceChoose(DetailLogic logic) {
    return FutureBuilder<HashSet<BookItemBean>?>(
        future: loadSources(logic),
        builder: (context, snap) {
          print(snap.data);
          return snap.data?.isNotEmpty != true
              ? SizedBox()
              : DropdownButton(
                  borderRadius: BorderRadius.circular(10),
                  alignment: Alignment.center,
                  enableFeedback: false,
                  focusColor: Colors.transparent,
                  underline: Container(
                      height: 0.5,
                      margin: EdgeInsets.symmetric(horizontal: 8),
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Color(0xFFBDBDBD),
                            width: 0.0,
                          ),
                        ),
                      )),
                  value: logic.item,
                  items: snap.data
                      ?.map((e) => DropdownMenuItem<BookItemBean>(
                            child: Text(e.source?.bookSourceName ?? ""),
                            value: e,
                          ))
                      .toList(),
                  onChanged: (BookItemBean? value) {
                    logic.changeSource(value);
                  },
                );
        });
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
        child: Center(child: Text(e.chapterName ?? "", textAlign: TextAlign.center, style: MyTheme(context).textTheme.bodySmall)),
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
        if (bean?.kind?.isNotEmpty == true) ...[SizedBox(width: 14), Text(bean?.kind ?? "", style: MyTheme(context).textTheme.caption)],
      ],
    );
  }

  Center buildLoadingView() => Center(child: CupertinoActivityIndicator());
}

class BookRuleEditDialog extends StatelessWidget {
  BookRuleEditDialog({
    required this.ruleBookInfo,
    this.onRuleConfirm,
    Key? key,
  }) : super(key: key);
  ValueChanged<SourceRuleBookInfo?>? onRuleConfirm;
  SourceRuleBookInfo? ruleBookInfo;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 30, horizontal: 30),
          width: 350,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: TextEditingController(text: ruleBookInfo?.coverUrl),
                decoration: InputDecoration(labelText: "封面Url规则"),
                onChanged: (value) {
                  ruleBookInfo?.coverUrl = value;
                },
              ),
              TextField(
                controller: TextEditingController(text: ruleBookInfo?.name),
                decoration: InputDecoration(labelText: "书名规则"),
                onChanged: (value) {
                  ruleBookInfo?.name = value;
                },
              ),
              TextField(
                controller: TextEditingController(text: ruleBookInfo?.author),
                decoration: InputDecoration(labelText: "作者规则"),
                onChanged: (value) {
                  ruleBookInfo?.author = value;
                },
              ),
              TextField(
                controller: TextEditingController(text: ruleBookInfo?.intro),
                decoration: InputDecoration(labelText: "简介规则"),
                onChanged: (value) {
                  ruleBookInfo?.intro = value;
                },
              ),
              TextField(
                controller: TextEditingController(text: ruleBookInfo?.kind),
                decoration: InputDecoration(labelText: "分类规则"),
                onChanged: (value) {
                  ruleBookInfo?.kind = value;
                },
              ),
              TextField(
                controller: TextEditingController(text: ruleBookInfo?.lastChapter),
                decoration: InputDecoration(labelText: "最新更新章节规则"),
                onChanged: (value) {
                  ruleBookInfo?.lastChapter = value;
                },
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Expanded(child: SizedBox()),
                  TextButton(
                      child: Text("取消"),
                      onPressed: () {
                        Get.back();
                      }),
                  TextButton(
                      child: Text("确定"),
                      onPressed: () {
                        Get.back();
                        onRuleConfirm?.call(ruleBookInfo);
                      })
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
