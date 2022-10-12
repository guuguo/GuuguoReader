import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:read_info/bean/entity/source_entity.dart';
import 'package:read_info/data/rule/RuleUtil.dart';
import 'package:read_info/global/constant.dart';
import 'package:read_info/widget/container.dart';

import 'logic.dart';

class SourcePage extends StatefulWidget {
  @override
  State<SourcePage> createState() => _SourcePageState();
}

class _SourcePageState extends State<SourcePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final logic = Get.find<SourceLogic>();
    return Scaffold(
      appBar: CupertinoNavigationBar(
          middle: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Text("源列表"),
      )),
      backgroundColor: CupertinoTheme.of(context).scaffoldBackgroundColor,
      body: GetX<SourceLogic>(
        builder: (SourceLogic logic) {
          if (logic.refreshing.value) {
            return Center(child: CupertinoActivityIndicator(radius: 15));
          } else {
            return SingleChildScrollView(
              child: Wrap(
                  children: logic.sources.value
                      .map((e) => withContextMenu(SourceItemWidget(bean: e), e))
                      .toList()),
            );
          }
        },
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
          width: 120,
          height: 160,
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: EdgeInsets.all(15),
          decoration: RoundedBoxDecoration(
              radius: 10, color: Theme.of(context).cardColor),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (bean.bookSourceCoverUrl?.isNotEmpty == true)
                Image.network(urlFix(bean.bookSourceCoverUrl!,bean.bookSourceUrl!)),
              Text(bean.bookSourceName ?? "",
                  style: Theme.of(context).textTheme.bodyLarge),
              SizedBox(height: 6),
              Text("${getTypeDesc(bean.bookSourceType)}",
                  style: Theme.of(context).textTheme.bodySmall),
              SizedBox(height: 8),
            ],
          )),
    );
  }


  String getTypeDesc(int? type) {
    if (type == source_type_sms) {
      return "信息流";
    }
    if (type == source_type_comic) {
      return "漫画站";
    }
    if (type == source_type_novel) {
      return "小说站";
    }
    return "";
  }
}
