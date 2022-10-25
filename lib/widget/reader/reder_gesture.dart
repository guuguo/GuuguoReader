import 'dart:ui';

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:read_info/utils/utils_screen.dart';
import 'package:read_info/widget/reader/reader_content_config.dart';
import 'package:read_info/widget/reader/reader_viewmodel.dart';
import 'package:read_info/widget/reader/reder_painter.dart';

class ReaderGestureDetail {
  Offset panDownDelta;
  Offset fingerPosition;
  Offset lastDelta;

  ReaderGestureDetail(this.panDownDelta, this.fingerPosition, this.lastDelta);
}

typedef GesturePanCallback =void Function(ReaderGestureDetail);
class ReaderGesture extends StatelessWidget {
  ReaderGesture({
    Key? key,
    this.child,
    this.onCenterTap,
    this.onNextTap,
    this.onPreTap,
    this.onPanChange,
    this.onPanEnd,
  }) : super(key: key);
  final Widget? child;
  final GestureTapCallback? onCenterTap;
  final GestureTapCallback? onNextTap;
  final GestureTapCallback? onPreTap;
  final GesturePanCallback? onPanChange;
  final GestureDragEndCallback? onPanEnd;
  late Offset dragDownPosition;

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
      onPanStart: (DragStartDetails details){
        dragDownPosition=details.localPosition;
      },
      onPanUpdate: (DragUpdateDetails details){
        onPanChange?.call(ReaderGestureDetail(details.localPosition-dragDownPosition, details.localPosition,details.delta));
      },
      onPanEnd: (DragEndDetails details){
        onPanEnd?.call(details);
      },
      child: child,
    );
  }
}
