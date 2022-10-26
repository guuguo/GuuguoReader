import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:read_info/res.dart';
import 'package:read_info/utils/utils_screen.dart';
import 'package:read_info/widget/reader/reader_content_config.dart';
import 'package:read_info/widget/reader/reader_menu.dart';
import 'package:read_info/widget/reader/reader_page_progress.dart';
import 'package:read_info/widget/reader/reader_viewmodel.dart';
import 'package:read_info/widget/reader/reder_gesture.dart';
import 'package:read_info/widget/reader/reder_painter.dart';

import 'anim/page_anim_manager.dart';

typedef ReadPageChangeCallback = void Function(int pageIndex, int chapterIndex);

class InheritedReader extends InheritedWidget {
  InheritedReader({required Widget child, this.onMenuChange, this.showChapterIndex,this.loadChapter}) : super(child: child);
  ValueChanged<bool?>? onMenuChange;
  VoidCallback? showChapterIndex;
  /// loadChapter(null) [null] 代表重新加载本章
  ///
  ValueChanged<int?>? loadChapter;

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) {
    return false;
  }
}

class NovelReader extends StatefulWidget {
  const NovelReader({
    Key? key,
    required this.pageProgress,
    required this.showCategory,
    required this.pageSize,
  }) : super(key: key);
  final VoidCallback showCategory;
  // final int startChapterIndex;
  // final int startReadPageIndex;
  final Size pageSize;
  final ReaderPageProgress pageProgress;

  static InheritedReader? of(BuildContext context) {
    final InheritedReader? inheritedReader = context.dependOnInheritedWidgetOfExactType<InheritedReader>();
    return inheritedReader;
  }

  @override
  State<NovelReader> createState() => NovelReaderState();
}

class NovelReaderState extends State<NovelReader> with TickerProviderStateMixin {
  NovelPagePainter? mPainter;
  late ReaderViewModel viewModel;
  GlobalKey canvasKey = new GlobalKey();
  var menuShow = false;
  late PageAnimManager animManager;
  late AnimationController controller ;

  @override
  initState() {
    super.initState();
    AssetImage(Res.p04, bundle: rootBundle).resolve(ImageConfiguration.empty).addListener(ImageStreamListener((img, sync) {
      final image = img.image;
      controller = AnimationController(duration: const Duration(milliseconds: 150), vsync: this);
      viewModel = ReaderViewModel(
        widget.pageProgress,
        ReaderConfigEntity().copyWith(
          pageSize: widget.pageSize,
          currentCanvasBgImage: image,
        ),
        canvasKey,
      );
      animManager = PageAnimManager(canvasKey, viewModel, widget.pageSize, controller);
      viewModel.addListener(() {
        setState(() {});
      });
      mPainter = NovelPagePainter(animManager, viewModel);

    }));
  }

  void jumpToChapter(int chapterIndex) {
    viewModel.toChapter(chapterIndex);
  }

  @override
  Widget build(BuildContext context) {
    return mPainter==null?SizedBox():InheritedReader(
      onMenuChange: changeMenuShow,
      showChapterIndex: widget.showCategory,
      loadChapter: (int? type)async{
        ///重新加载本章
        if (type == null) {
          await widget.pageProgress.reloadCurrentPageCache();
          setState(() { });
        }
      },
      child: Stack(
        children: [
          Positioned.fill(
            child: ReaderGesture(
              onNextTap: () {
                hideMenu();
                animManager.toNextPage();
              },
              onPreTap: () {
                hideMenu();
                animManager.toPrePage();
              },
              onCenterTap: () {
                changeMenuShow();
              },
              onPanChange: (d) async {
                animManager.gesturePanChange(d);
              },
              onPanEnd: animManager.onPanEnd,
              child: CustomPaint(
                key: canvasKey,
                isComplex: true,
                size: widget.pageSize,
                painter: mPainter,
              ),
            ),
          ),
          if (menuShow) ReaderMenu(
            chapterName: widget.pageProgress.currentChapter?.chapterName,
          ),
        ],
      ),
    );
  }

  bool changeMenuShow([bool? bool = null]) {
    if (bool == null) {
      setState(() {
        menuShow = !menuShow;
      });
      return true;

    } else if (bool) {
      if (menuShow == false) {
        setState(() {
          menuShow = true;
        });
        return true;
      }
    } else {
      if (menuShow == true){
        setState(() {
          menuShow = false;
        });
        return true;
      }
    }
    return false;
  }

  bool hideMenu() {
    return changeMenuShow(false);
  }
}
