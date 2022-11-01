import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:read_info/global/custom/my_theme.dart';
import 'package:read_info/page/bookread/comicreader/reader_menu.dart';
import 'package:read_info/page/view/icon.dart';
import 'package:read_info/page/view/my_appbar.dart';
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
  return Container(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: kToolbarHeight,
            color: bgColor,
            child: Row(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: MyBackButton(),
                ),
                Expanded(child: Text(chapterName ?? "", style: TextStyle(fontSize: 18), overflow: TextOverflow.ellipsis)),
                menuButton(),
              ],
            ),
          ),
          if (sourceBuilder != null) sourceBuilder.call(context)
        ],
      ));
}

Widget menuButton() {
  return PopupMenuButton(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    padding: EdgeInsets.zero,
    itemBuilder: (BuildContext context) => [
      PopupMenuItem(
          child: Row(
            children: [
              Icon(Icons.import_contacts, color: MyTheme.of(context).textColor),
              SizedBox(width: 10),
              Text("重新下载本章"),
            ],
          ),
          onTap: () async {
            NovelReader.of(context)?.loadChapter?.call(null);
          })
    ],
    child: PrimaryIconButton(
      Icons.more_vert,
      color: Colors.white,
    ),
  );
}
