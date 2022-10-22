import 'dart:ui';

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:read_info/utils/utils_screen.dart';
import 'package:read_info/widget/reader/reader_content_config.dart';
import 'package:read_info/widget/reader/reader_viewmodel.dart';
import 'package:read_info/widget/reader/reder_painter.dart';

class ReaderGesture extends StatelessWidget {
  const ReaderGesture({
    Key? key,
    this.child,
    this.onCenterTap,
    this.onNextTap,
    this.onPreTap,
  }) : super(key: key);
  final Widget? child;
  final GestureTapCallback? onCenterTap;
  final GestureTapCallback? onNextTap;
  final GestureTapCallback? onPreTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapUp: (detail) {
        final size = (context.findRenderObject() as RenderBox).size;
        if (detail.localPosition.dy > size.height / 4 && detail.localPosition.dy < size.height * 3 / 4 && detail.localPosition.dx > size.width / 3 && detail.localPosition.dx < size.width * 2 / 3) {
          onCenterTap?.call();
          return;
        }
        if (detail.localPosition.dx > size.width / 2) {
          onNextTap?.call();
          return;
        }
        if (detail.localPosition.dx < size.width / 2) {
          onPreTap?.call();
          return;
        }
      },
      child: child,
    );
  }
}
