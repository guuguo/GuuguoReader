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

abstract class NovelReaderAnim {
  drawCanvas(Canvas canvas);

  bool gestureChange(ReaderGestureDetail detail);

  Animation? onPanEnd(DragEndDetails detail);
}

abstract class IReaderPageVm {
  Picture getPrePagePicture();

  Picture getCurrentPagePicture();

  Picture getNextPagePicture();

  toNextPage();

  toPrePage();
}

class PageAnimManager {
  GlobalKey canvasKey;
  IReaderPageVm pageDrawer;
  Size pageSize;
  AnimationController controller;

  late NovelReaderAnim readerAnim;

  PageAnimManager(this.canvasKey, this.pageDrawer, this.pageSize, this.controller) {
    readerAnim = ReaderSlideAnim(pageSize, controller, pageDrawer);
  }

  void gesturePanChange(ReaderGestureDetail detail) {
    if(controller.isAnimating) return;
    if (readerAnim.gestureChange(detail)) {
      (canvasKey.currentContext?.findRenderObject() as RenderCustomPaint?)?.markNeedsPaint();
    }
  }
  void toNextPage() {
    DragEndDetails details=DragEndDetails(velocity:Velocity(pixelsPerSecond: Offset(-1,0)));
    onPanEnd(details);
  }
  void toPrePage() {
    DragEndDetails details=DragEndDetails(velocity:Velocity(pixelsPerSecond: Offset(1,0)));
    onPanEnd(details);
  }
  void onPanEnd(DragEndDetails detail) {
    var anim = readerAnim.onPanEnd(detail);
    anim?.addListener(() {
      (canvasKey.currentContext?.findRenderObject() as RenderCustomPaint?)?.markNeedsPaint();
    });
    controller.forward();
  }

  onDraw(Canvas canvas) {
    readerAnim.drawCanvas(canvas);
  }
}
