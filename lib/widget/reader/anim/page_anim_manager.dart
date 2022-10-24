import 'dart:ui';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:read_info/utils/developer.dart';
import 'package:read_info/utils/utils_screen.dart';
import 'package:read_info/widget/reader/anim/reder_slide_anim.dart';
import 'package:read_info/widget/reader/reader_content_config.dart';
import 'package:read_info/widget/reader/reader_menu.dart';
import 'package:read_info/widget/reader/reader_viewmodel.dart';
import 'package:read_info/widget/reader/reder_gesture.dart';
import 'package:read_info/widget/reader/reder_painter.dart';

import '../../../page/view/my_appbar.dart';

abstract class IReaderPageDrawer{
  Picture getPrePagePicture();
  Picture getNextPagePicture();
}
class PageAnimManager{
  GlobalKey canvasKey;
  IReaderPageDrawer pageDrawer;
  Size pageSize;
  late NovelReaderAnim anim;
  PageAnimManager(this.canvasKey,this.pageDrawer,this.pageSize){
    anim=ReaderSlideAnim();
  }

  void gesturePanChange(ReaderGestureDetail detail) {
    debug("downDelta:${detail.panDownDelta} fingerPosition:${detail.fingerPosition} lastDelta:${detail.lastDelta}");
  }

  onDraw(Canvas canvas){

  }
}