import 'dart:ui';

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

import '../../page/view/my_appbar.dart';

typedef ReadPageChangeCallback = void Function(int pageIndex, int chapterIndex);

class InheritedReader extends InheritedWidget {
  InheritedReader({required Widget child, this.onMenuChange, this.showChapterIndex}) : super(child: child);
  ValueChanged<bool?>? onMenuChange;
  VoidCallback? showChapterIndex;

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) {
    return false;
  }
}

class NovelReader extends StatefulWidget {
  const NovelReader({
    Key? key,
    required this.chapterProvider,
    required this.readChangeCallback,
    required this.startChapterIndex,
    required this.startReadPageIndex,
    required this.showIndex,
    required this.pageSize,
  }) : super(key: key);
  final ChapterProvider chapterProvider;
  final ReadPageChangeCallback readChangeCallback;
  final VoidCallback showIndex;
  final int startChapterIndex;
  final int startReadPageIndex;
  final Size pageSize;

  static InheritedReader? of(BuildContext context) {
    final InheritedReader? inheritedReader = context.dependOnInheritedWidgetOfExactType<InheritedReader>();
    return inheritedReader;
  }

  @override
  State<NovelReader> createState() => NovelReaderState();
}

class NovelReaderState extends State<NovelReader> {
  NovelPagePainter? mPainter;
  late ReaderViewModel viewModel;
  GlobalKey canvasKey = new GlobalKey();
  var menuShow = false;

  @override
  initState() {
    super.initState();
    viewModel = ReaderViewModel(
      widget.chapterProvider,
      widget.readChangeCallback,
      widget.startChapterIndex,
      widget.startReadPageIndex,
      ReaderConfigEntity().copyWith(
        pageSize: widget.pageSize,
      ),
    );
    viewModel.addListener(() {
      setState(() {});
    });
    mPainter = NovelPagePainter(viewModel);
  }

  void jumpToChapter(int chapterIndex) {
    viewModel.toChapter(chapterIndex);
  }

  @override
  Widget build(BuildContext context) {
    return InheritedReader(
      onMenuChange: changeMenuShow,
      showChapterIndex: widget.showIndex,
      child: Stack(
        children: [
          Positioned.fill(
            child: ReaderGesture(
              onNextTap: () {
                hideMenu();
                viewModel.toNextPage();
              },
              onPreTap: () {
                hideMenu();
                viewModel.toPrePage();
              },
              onCenterTap: () {
                changeMenuShow();
              },
              onPanChange: viewModel.gesturePanChange,
              child: CustomPaint(
                key: canvasKey,
                isComplex: true,
                size: widget.pageSize,
                painter: mPainter,
              ),
            ),
          ),
          if (menuShow) ReaderMenu(
            chapterName: viewModel.currentChapter?.chapterName,
          ),
        ],
      ),
    );
  }

  void changeMenuShow([bool? bool = null]) {
    if (bool == null) {
      setState(() {
        menuShow = !menuShow;
      });
    } else if (bool) {
      if (menuShow == false)
        setState(() {
          menuShow = true;
        });
    } else {
      if (menuShow == true)
        setState(() {
          menuShow = false;
        });
    }
  }

  void hideMenu() {
    changeMenuShow(false);
  }
}
