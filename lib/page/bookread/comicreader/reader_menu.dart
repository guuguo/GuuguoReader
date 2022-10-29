import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:orientation/orientation.dart';
import 'package:read_info/widget/reader/reader_menu.dart';
import 'package:read_info/widget/reader/reder_view.dart';

import '../../../global/logic.dart';

class ComicReaderMenu extends StatelessWidget {
  const ComicReaderMenu({Key? key, this.chapterName}) : super(key: key);
  final String? chapterName;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
        child: DefaultTextStyle(
      style: TextStyle(inherit: false, color: Colors.white),
      child: IconTheme(
          data: IconTheme.of(context).copyWith(color: Colors.white),
          child: Column(
            children: [
              MenuHeader(context, chapterName),
              Expanded(child: SizedBox()),
              ComicMenuBottom(context),
            ],
          )),
    ));
  }
}
Widget ComicMenuBottom(BuildContext context) {
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
          IconMenu(Icons.screen_rotation, onPressed: () {
            rotationChange(context);
          }),
        ],
      ),
    ),
  );
}
void brightnessChange(BuildContext context) {
  Get.find<GlobalLogic>().changeThemeMode(context);
  Future.delayed(Duration(milliseconds: 20),(){
    NovelReader.of(context)?.onBrightnessChange?.call();
  });
}

void rotationChange(BuildContext context) {
  if (!Platform.isAndroid && !Platform.isIOS) return;
  if (MediaQuery.of(context)
        .orientation == Orientation.portrait) {
      OrientationPlugin.forceOrientation(DeviceOrientation.landscapeLeft);
    } else if (MediaQuery
        .of(context)
        .orientation == Orientation.landscape) {
      OrientationPlugin.forceOrientation(DeviceOrientation.portraitUp);
    }

}
