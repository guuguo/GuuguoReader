import 'dart:ui';

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:read_info/utils/utils_screen.dart';
import 'package:read_info/widget/reader/reader_content_config.dart';
import 'package:read_info/widget/reader/reader_viewmodel.dart';
import 'package:read_info/widget/reader/reder_painter.dart';

class NovelReader extends StatefulWidget {
  const NovelReader({Key? key, required this.chapterProvider, required this.currentChapterIndex}) : super(key: key);
  final ChapterProvider chapterProvider;
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
    viewModel = ReaderViewModel(widget.chapterProvider, widget.currentChapterIndex);
    viewModel.addListener(() {
      setState(() {});
    });
    mPainter = NovelPagePainter(viewModel);
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    return GestureDetector(
      onTap: () {
      },
      onTapUp: (d){
        if(d.localPosition.dx<(viewModel.config?.pageSize.width??ScreenUtils.getScreenWidth())/2){
          viewModel.toPrePage();
        }else{
          viewModel.toNextPage();
        }
      },
      child: Builder(builder: (context) {
        var constrains = context.findRenderObject()?.constraints as BoxConstraints?;
        viewModel.setConfig(
          ReaderConfigEntity().copyWith(
            pageSize: Size(constrains?.maxWidth ?? ScreenUtils.getScreenWidth(), constrains?.maxHeight ?? ScreenUtils.getScreenHeight()),
          ),
        );
        if (viewModel.currentPageReady())
          return CustomPaint(
            key: canvasKey,
            isComplex: true,
            size: Size(constrains?.maxWidth ?? 100, constrains?.maxHeight ?? 100),
            painter: mPainter,
          );
        else
          return SizedBox(width: double.infinity, height: double.infinity);
      }),
    );
  }
}
