import 'dart:ui';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:read_info/utils/utils_screen.dart';
import 'package:read_info/widget/reader/reader_content_config.dart';
import 'package:read_info/widget/reader/reader_menu.dart';
import 'package:read_info/widget/reader/reader_viewmodel.dart';
import 'package:read_info/widget/reader/reder_gesture.dart';
import 'package:read_info/widget/reader/reder_painter.dart';

import '../../../page/view/my_appbar.dart';

abstract class NovelReaderAnim {
  drawCanvas(ReaderGestureDetail detail,Picture prePage,Picture nextPage);
  Animation createFlingAnim();

}
class ReaderSlideAnim extends NovelReaderAnim{
  @override
  drawCanvas(ReaderGestureDetail detail, Picture prePage, Picture nextPage) {
    // TODO: implement drawCanvas
    throw UnimplementedError();
  }

  @override
  Animation createFlingAnim() {
    // TODO: implement createFlingAnim
    throw UnimplementedError();
  }

}