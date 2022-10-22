import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:read_info/widget/reader/reader_viewmodel.dart';

class NovelPagePainter extends CustomPainter {
  ReaderViewModel viewModel;
  NovelPagePainter(this.viewModel):super(repaint: viewModel);
  @override
  void paint(Canvas canvas, Size size) {
    if (viewModel.currentPageReady()) {
      viewModel.drawCurrentPage(canvas);
    } else {
      viewModel.drawBackground(canvas);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}