import 'dart:ui';

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:read_info/utils/utils_screen.dart';
import 'package:read_info/widget/reader/reader_content_config.dart';
import 'package:read_info/widget/reader/reader_viewmodel.dart';
import 'package:read_info/widget/reader/reder_painter.dart';
typedef ReadPageChangeCallback= void Function(int pageIndex,int chapterIndex);

class NovelReader extends StatefulWidget {
  const NovelReader({
    Key? key,
    required this.chapterProvider,
    required this.readChangeCallback,
    required this.startChapterIndex,
    required this.startReadPageIndex,
   required this.pageSize,
  }) : super(key: key);
  final ChapterProvider chapterProvider;
  final ReadPageChangeCallback readChangeCallback;
  final int startChapterIndex;
  final int startReadPageIndex;
  final Size pageSize;

  @override
  State<NovelReader> createState() => _NovelReaderState();
}

class _NovelReaderState extends State<NovelReader> {
  NovelPagePainter? mPainter;
  late ReaderViewModel viewModel;
  GlobalKey canvasKey = new GlobalKey();
  @override
  initState() {
    super.initState();
    viewModel = ReaderViewModel(widget.chapterProvider,widget.readChangeCallback, widget.startChapterIndex,widget.startReadPageIndex);
    viewModel.addListener(() {
      setState(() {});
    });
    mPainter = NovelPagePainter(viewModel);
    viewModel.setConfig(
      ReaderConfigEntity().copyWith(
        pageSize: widget.pageSize,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return GestureDetector(
      onTap: () {},
      onTapUp: (d) {
        if (d.localPosition.dx < (viewModel.config?.pageSize.width ?? ScreenUtils.getScreenWidth()) / 2) {
          viewModel.toPrePage();
        } else {
          viewModel.toNextPage();
        }
      },
      child: Builder(builder: (context) {
        var constrains = context.findRenderObject()?.constraints as BoxConstraints?;
        if (viewModel.currentPageReady())
          return CustomPaint(
            key: canvasKey,
            isComplex: true,
            size: widget.pageSize,
            painter: mPainter,
          );
        else
          return SizedBox(width: double.infinity, height: double.infinity);
      }),
    );
  }
}
