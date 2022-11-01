import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:read_info/bean/entity/source_entity.dart';
import 'package:read_info/data/rule/RuleUtil.dart';
import 'package:read_info/data/rule/app_helper.dart';
import 'package:read_info/global/constant.dart';
import 'package:read_info/global/custom/component/limit_width_box.dart';
import 'package:read_info/global/custom/my_theme.dart';
import 'package:read_info/page/common/widget_common.dart';
import 'package:read_info/page/view/context_menu.dart';
import 'package:read_info/page/view/icon.dart';
import 'package:read_info/page/view/my_appbar.dart';
import 'package:read_info/widget/container.dart';
import 'package:read_info/widget/reader/reader_page_progress.dart';

import 'logic.dart';

class SourcePage extends StatefulWidget {
  @override
  State<SourcePage> createState() => _SourcePageState();
}

class _SourcePageState extends State<SourcePage> with AutomaticKeepAliveClientMixin {
  @override
  void initState() {
    Get.lazyPut(() => SourceLogic());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final logic = Get.find<SourceLogic>();
    return Scaffold(
      appBar: MyAppBar(
        middle: Text("源列表"),
        trail: [menuButton(logic)],
      ),
      backgroundColor: CupertinoTheme.of(context).scaffoldBackgroundColor,
      body: GetX<SourceLogic>(
        builder: (SourceLogic logic) {
          if (logic.refreshing.value) {
            return Center(child: CupertinoActivityIndicator(radius: 15));
          } else {
            return LimitWidthBox(
              child: GridView.count(
                padding: EdgeInsets.all(10),
                crossAxisCount: 2,
                childAspectRatio: 3.5,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                children: logic.sources.value.mapIndexed((i, e) => withContextMenu(SourceItemWidget(key: Key(e.bookSourceUrl ?? "$i"), bean: e), e)).toList(),
              ),
            );
          }
        },
      ),
    );
  }

  Widget menuButton(SourceLogic logic) {
    return PopupMenuButton(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 4,
      padding: EdgeInsets.zero,
      itemBuilder: (BuildContext context) => [
        popItem(
            icon: Icons.import_contacts,
            text: "获取常用小说源",
            onTap: () async {
              await uploadSource();
            }),
        popItem(
            icon: Icons.import_contacts,
            text: "获取常用漫画源",
            onTap: () async {
              await uploadSource("https://gist.githubusercontent.com/guuguo/4ed5b1c5f9630414680ecb31c23c96ef/raw");
            }),
        popItem(
            icon: Icons.import_contacts,
            text: "导入剪贴板书源",
            onTap: () async {
              ClipboardData? data = await Clipboard.getData(Clipboard.kTextPlain);
              final list = await logic.importSourceFromText(data?.text);
              if (list.isEmpty) {
                "未在剪贴板找到书源信息".showMessage();
              }
            }),
      ],
      child: PrimaryIconButton(
        Icons.more_vert,
      ),
    );
  }

  Future<void> uploadSource([String? url]) async {
    final logic = Get.find<SourceLogic>();
    final cancel = "正在更新源".showLoading();
    try {
      final list = await logic.importSource(url:url?? defaultSourceUrl);
      cancel();
      "更新源完成,获取到${list.length}个书源".showMessage();
    } catch (e) {
      cancel();
    }
  }

  PopupMenuEntry popItem({IconData? icon, String? text, VoidCallback? onTap}) {
    return PopupMenuItem(
        child: Row(
          children: [
            Icon(icon),
            if (text != null) ...[SizedBox(width: 10), Text(text)]
          ],
        ),
        onTap: onTap);
  }
  Widget withContextMenu(Widget child, SourceEntity bean) {
    return ContextMenu(child: child, list: [
      Pair("编辑", () {
        Get.back();
        Get.snackbar("提示", "暂未实现");
      }),
      Pair("导出到剪贴板", () {
        Get.back();
        Clipboard.setData(ClipboardData(text: json.encode(bean.toJson())));
      }),
      Pair("删除", () {
        Get.defaultDialog(
            title: "提示",
            middleText: "确定删除该源？",
            textConfirm: "确定",
            textCancel: "取消",
            onConfirm: () async {
              await Get.find<SourceLogic>().deleteSource(bean);
              Get.back();
              Get.back();
            },
            onCancel: () {
              Get.back();
            });
      }),
    ]);
  }

  @override
  bool get wantKeepAlive => true;
}

class SourceItemWidget extends StatelessWidget {
  const SourceItemWidget({
    Key? key,
    required this.bean,
  }) : super(key: key);

  final SourceEntity bean;

  @override
  Widget build(BuildContext context) {
    final logic = Get.find<SourceLogic>();
    return GestureDetector(
      onTap: () {
        logic.toSourcePage(bean);
      },
      child: Container(
          padding: EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: RoundedBoxDecoration(radius: 10, color: Theme.of(context).cardColor),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(getTypeDesc(bean.bookSourceType)),
              SizedBox(width: 6),
              SizedBox(child: Text(bean.bookSourceName ?? "", style: Theme.of(context).textTheme.titleMedium?.copyWith(height: 1.3))),
            ],
          )),
    );
  }

  IconData getTypeDesc(int? type) {
    if (type == source_type_sms) {
      return Icons.newspaper_rounded;
    }
    if (type == source_type_comic) {
      return Icons.collections_rounded;
    }
    if (type == source_type_novel) {
      return Icons.book_rounded;
    }
    return Icons.book_rounded;
  }
}
