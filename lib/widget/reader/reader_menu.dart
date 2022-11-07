import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:read_info/global/custom/my_theme.dart';
import 'package:read_info/page/bookread/comicreader/reader_menu.dart';
import 'package:read_info/page/bookread/logic.dart';
import 'package:read_info/page/common/widget_common.dart';
import 'package:read_info/page/view/icon.dart';
import 'package:read_info/page/view/my_appbar.dart';
import 'package:read_info/page/view/popmenuubutton.dart';
import 'package:read_info/utils/ext/list_ext.dart';
import 'package:read_info/widget/reader/reader_content_config.dart';
import 'package:read_info/widget/reader/reder_view.dart';

var bgColor = Color(0xbb000000);

class ReaderMenu extends StatefulWidget {
  const ReaderMenu({Key? key, this.chapterName, required this.config, this.sourceBuilder}) : super(key: key);
  final String? chapterName;
  final ReaderConfigEntity config;
  final WidgetBuilder? sourceBuilder;

  @override
  State<ReaderMenu> createState() => _ReaderMenuState();
}

class _ReaderMenuState extends State<ReaderMenu> {
  var showFontConfigPanel = false;
  var fontSize;

  @override
  void initState() {
    super.initState();
    fontSize = widget.config.fontSize;
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
        child: DefaultTextStyle(
      style: TextStyle(inherit: false, color: Colors.white),
      child: IconTheme(
          data: IconTheme.of(context).copyWith(color: Colors.white),
          child: Column(
            children: [
              MenuHeader(context, widget.chapterName, widget.sourceBuilder),
              Expanded(child: SizedBox()),
              showFontConfigPanel ? NovelFontConfigPanel(context) : NovelMenuBottom(context),
            ],
          )),
    ));
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget NovelMenuBottom(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
      width: double.infinity,
      color: bgColor,
      child: Container(
        height: 80,
        constraints: BoxConstraints.loose(Size(600, double.infinity)),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            IconMenu(Icons.format_list_bulleted, onPressed: () {
              NovelReader.of(context)?.onMenuChange?.call(false);
              NovelReader.of(context)?.showChapterIndex?.call();
            }),
            IconMenu(Icons.format_size, onPressed: () {
              setState(() {
                showFontConfigPanel = true;
              });
            }),
            IconMenu(Icons.light_mode, onPressed: () {
              brightnessChange(context);
            }),
            IconMenu(Icons.screen_rotation, onPressed: () {
              rotationChange(context);
            }),
          ],
        ),
      ),
    );
  }

  Widget NovelFontConfigPanel(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      width: double.infinity,
      color: bgColor,
      child: SafeArea(
        top: false,
        child: Container(
          constraints: BoxConstraints.loose(Size(600, double.infinity)),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  CircleButton(Text("A-"), onPressed: () {
                    final newFontSize = fontSize - 2;
                    NovelReader.of(context)?.onConfigChange?.call(widget.config.copyWith(fontSize: newFontSize));
                    setState(() {
                      fontSize = newFontSize;
                    });
                  }),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: Text("${fontSize}"),
                  ),
                  CircleButton(Text("A+"), onPressed: () {
                    final newFontSize = fontSize + 2;
                    NovelReader.of(context)?.onConfigChange?.call(widget.config.copyWith(fontSize: newFontSize));
                    setState(() {
                      fontSize = newFontSize;
                    });
                  }),
                ],
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

Widget CircleButton(Widget child, {GestureTapCallback? onPressed}) {
  return GestureDetector(
    onTap: onPressed,
    child: Container(
      padding: EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      child: child,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.white, width: 0.5),
      ),
    ),
  );
}

Widget IconMenu(IconData icon, {VoidCallback? onPressed}) {
  return Expanded(child: GestureDetector(behavior: HitTestBehavior.translucent, onTap: onPressed, child: Center(child: Icon(icon))));
}

Widget MenuHeader(BuildContext context, String? chapterName, WidgetBuilder? sourceBuilder) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Container(
        width: double.infinity,
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
        color: bgColor,
        child: Container(
          height: kToolbarHeight,
          child: Row(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: MyBackButton(),
              ),
              Expanded(child: Text(chapterName ?? "", style: TextStyle(fontSize: 18), overflow: TextOverflow.ellipsis)),
              menuButton(context),
            ],
          ),
        ),
      ),
      if (sourceBuilder != null) sourceBuilder.call(context)
    ],
  );
}

Widget menuButton(BuildContext context) {
  return IconTheme(
      data: IconThemeData(color: MyTheme.of(context).textColor),
      child: PopupMenuButton(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: EdgeInsets.zero,
        itemBuilder: (BuildContext context) => [
          popItem(
              icon: Icons.import_contacts,
              text: "重新下载本章",
              onTap: () {
                NovelReader.of(context)?.loadChapter?.call(null);
              }),
          popItem(
              icon: Icons.repeat_on_sharp,
              text: "文本替换正则",
              onTap: () {
                final logic = Get.find<ContentLogic>();
                final split = logic.source.ruleContent?.replaceRegex?.split("##");
                Future.delayed(Duration(milliseconds: 10), () {
                  Get.dialog(
                    ReplaceDialog(
                        regex: split?.getOrNull(1) ?? "",
                        replace: split?.getOrNull(2) ?? "",
                        onReplaceConfirm: (reg, replace) {
                          logic.onReplaceConfirm(reg, replace);
                        }),
                  );
                });
              })
        ],
        child: PrimaryIconButton(
          Icons.more_vert,
          color: Colors.white,
        ),
      ));
}

typedef void OnReplaceConfirm(String regex, String replace);

class ReplaceDialog extends StatelessWidget {
  ReplaceDialog({
    required this.regex,
    required this.replace,
    this.onReplaceConfirm,
    Key? key,
  }) : super(key: key);
  var regex = "";
  var replace = "";
  OnReplaceConfirm? onReplaceConfirm;

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
                controller: TextEditingController(text: regex),
                decoration: InputDecoration(labelText: "输入匹配内容"),
                onChanged: (value) {
                  regex = value;
                },
              ),
              TextField(
                controller: TextEditingController(text: replace),
                decoration: InputDecoration(labelText: "输入替换内容(可为空)"),
                onChanged: (value) {
                  replace = value;
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
                        if (regex.isEmpty) {
                          "匹配内容不能为空".showMessage();
                          return;
                        }
                        Get.back();
                        onReplaceConfirm?.call(regex, replace);
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
