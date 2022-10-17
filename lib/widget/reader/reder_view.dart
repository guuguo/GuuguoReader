import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:read_info/widget/reader/reader_content_config.dart';
import 'package:read_info/widget/reader/reader_viewmodel.dart';
import 'package:read_info/widget/reader/reder_painter.dart';

class NovelReader extends StatefulWidget {
  const NovelReader(
      {Key? key,
      required this.chapterProvider,
      required this.currentChapterIndex})
      : super(key: key);
  final ChapterProvider  chapterProvider;
  final int currentChapterIndex;

  @override
  State<NovelReader> createState() => _NovelReaderState();
}

class _NovelReaderState extends State<NovelReader> {
  NovelPagePainter? mPainter;
  late ReaderViewModel viewModel;
  GlobalKey canvasKey = new GlobalKey();

  initState() {
    super.initState();
    viewModel =ReaderViewModel(widget.chapterProvider, widget.currentChapterIndex);
    mPainter = NovelPagePainter(viewModel);
    viewModel.addListener(() {
      setState((){});
    });
    viewModel.setConfig(ReaderConfigEntity().copyWith(pageSize: Size(MediaQueryData.fromWindow(window).size.width, MediaQueryData.fromWindow(window).size.height)));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        viewModel.toNextPage();
      },
      child: Builder(
        builder: (context) {
          var constrains=context.findRenderObject()?.constraints as BoxConstraints?;
          return CustomPaint(
            key: canvasKey,
            isComplex: true,
            size: Size(constrains?.maxWidth??100, constrains?.maxHeight??100),
            painter: mPainter,
          );
        }
      ),
    );
  }
}
