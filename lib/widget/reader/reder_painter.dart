import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:read_info/widget/reader/anim/page_anim_manager.dart';
import 'package:read_info/widget/reader/reader_viewmodel.dart';

class NovelPagePainter extends CustomPainter {
  PageAnimManager pageAnim;
  ChangeNotifier notifier;
  NovelPagePainter(this.pageAnim,this.notifier):super(repaint: notifier);
  @override
  void paint(Canvas canvas, Size size) {
    pageAnim.onDraw(canvas);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}