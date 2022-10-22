import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:read_info/bean/entity/source_entity.dart';
import 'package:read_info/data/rule/RuleUtil.dart';
import 'package:read_info/data/rule/app_helper.dart';
import 'package:read_info/global/constant.dart';
import 'package:read_info/global/custom/component/limit_width_box.dart';
import 'package:read_info/global/custom/my_theme.dart';
import 'package:read_info/page/view/icon.dart';
import 'package:read_info/page/view/my_appbar.dart';
import 'package:read_info/widget/container.dart';

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
        trail: [
          menuButton(logic)
        ],
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
      itemBuilder: (BuildContext context) => [
        PopupMenuItem(
            child: Row(
              children: [
                Icon(Icons.import_contacts),
                SizedBox(width: 10),
                Text("获取常用源"),
              ],
            ),
            onTap: () async {
              final controller = Get.snackbar("提示", "正在更新源", showProgressIndicator: true, duration: Duration(seconds: 100));
              try {
                await logic.importSource();
                controller.close();
                Get.snackbar("提示", "更新源完成", duration: Duration(milliseconds: 1500));
              } catch (e) {
                controller.close();
              }
            })
      ],
      child: PrimaryIconButton(
        Icons.more_vert,
      ),
    );
  }

  Widget withContextMenu(Widget child, SourceEntity bean) {
    return CupertinoContextMenu(
      actions: [
        CupertinoContextMenuAction(
          onPressed: () {
            Get.snackbar("提示", "暂未实现");
          },
          child: Text("编辑"),
        ),
        CupertinoContextMenuAction(
          onPressed: () {
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
          },
          child: Text("删除"),
        ),
      ],
      child: child,
    );
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
          padding: EdgeInsets.symmetric(horizontal:14,vertical:14),
          decoration: RoundedBoxDecoration(radius: 10, color: Theme.of(context).cardColor),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(getTypeDesc(bean.bookSourceType)),
              SizedBox(width:6),
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
