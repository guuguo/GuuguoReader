import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:read_info/bean/entity/source_entity.dart';
import 'package:read_info/data/rule/RuleUtil.dart';
import 'package:read_info/data/rule/app_helper.dart';
import 'package:read_info/global/constant.dart';
import 'package:read_info/global/custom/my_theme.dart';
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
        ),
        trailing: PopupMenuButton(
          itemBuilder: (BuildContext context) {
            return [PopupMenuItem(child: Row(
              children: [
                Icon(Icons.import_contacts),
                SizedBox(width:10),
                      Text("获取常用源"),
                    ],
                  ),
                  onTap: ()async  {
                    final controller=Get.snackbar("提示", "正在更新源",showProgressIndicator: true,duration: Duration(seconds: 100));
                    try {
                      await logic.importSource();
                      controller.close();
                      Get.snackbar("提示", "更新源完成",duration: Duration(milliseconds: 1500));
                    }catch (e){
                      controller.close();
                    }
                  })
            ];
          },
        ),
      ),
      backgroundColor: CupertinoTheme.of(context).scaffoldBackgroundColor,
      body: GetX<SourceLogic>(
        builder: (SourceLogic logic) {
          if (logic.refreshing.value) {
            return Center(child: CupertinoActivityIndicator(radius: 15));
          } else {
            return SingleChildScrollView(
              child: Center(
                child: Container(
                  constraints: BoxConstraints.loose(Size(MyTheme.contentMaxWidth, double.infinity)),
                  child: Wrap(
                      alignment: WrapAlignment.center,
                      children: logic.sources.value
                          .mapIndexed((i,e) => withContextMenu(SourceItemWidget(key:Key(e.bookSourceUrl??"$i"),bean: e), e))
                          .toList()),
                ),
              ),
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
          margin: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
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
