import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:read_info/global/constant.dart';
import 'package:read_info/widget/reader/reader_content_config.dart';
import 'package:read_info/widget/reader/reader_menu.dart';
import 'package:read_info/widget/reader/reader_page_progress.dart';
import 'package:read_info/widget/reader/reader_viewmodel.dart';
import 'package:read_info/widget/reader/reder_gesture.dart';
import 'package:read_info/widget/reader/reder_painter.dart';

import '../../global/logic.dart';
import 'anim/page_anim_manager.dart';

typedef ReadPageChangeCallback = void Function(int pageIndex, int chapterIndex);
typedef ReadConfigChangeCallback = void Function(ReaderConfigEntity config);

class InheritedReader extends InheritedWidget {
  InheritedReader({
    required Widget child,
    this.onMenuChange,
    this.showChapterIndex,
    this.loadChapter,
    this.onBrightnessChange,
    this.onConfigChange,
  }) : super(child: child);
  ValueChanged<bool?>? onMenuChange;
  VoidCallback? showChapterIndex;
  ReadConfigChangeCallback? onConfigChange;

  /// loadChapter(null) [null] 代表重新加载本章
  ///
  ValueChanged<int?>? loadChapter;
  VoidCallback? onBrightnessChange;

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
  final Size pageSize;
  final ReaderPageProgress pageProgress;

  static InheritedReader? of(BuildContext context) {
    final InheritedReader? inheritedReader = context.dependOnInheritedWidgetOfExactType<InheritedReader>();
    return inheritedReader;
  }

  @override
  State<NovelReader> createState() => NovelReaderState();
}

class NovelReaderState extends State<NovelReader> with MenuShowBehavior, TickerProviderStateMixin {
  NovelPagePainter? mPainter;
  late ReaderViewModel viewModel;
  GlobalKey canvasKey = new GlobalKey();
  late PageAnimManager animManager;
  late AnimationController controller;

  @override
  initState() {
    super.initState();
    init();
  }

  init() async {
    var pageSize = widget.pageSize;
    final isDarkMode = Get.find<GlobalLogic>().isDark(context);
    final img = isDarkMode ? await BgImage.getDark() : await BgImage.getLight();
    final textColor = isDarkMode ? Colors.white : Color(0xff040604);

    controller = AnimationController(duration: const Duration(milliseconds: 150), vsync: this);
    viewModel = ReaderViewModel(
      widget.pageProgress,
      ReaderConfigEntity().copyWith(
        pageSize: widget.pageSize,
        currentCanvasBgImage: img,
        contentTextColor: textColor,
      ),
      canvasKey,
    );
    animManager = PageAnimManager(canvasKey, viewModel, pageSize, controller);
    viewModel.addListener(() {
      setState(() {});
    });
    mPainter = NovelPagePainter(animManager, viewModel);
  }

  void jumpToChapter(int chapterIndex) {
    viewModel.toChapter(chapterIndex);
  }

  @override
  Widget build(BuildContext context) {
    return mPainter == null
        ? SizedBox()
        : InheritedReader(
            onConfigChange: (config) {
              viewModel.setConfig(config);
            },
            onBrightnessChange: () async {
              hideMenu();
              final isDarkMode=Get.find<GlobalLogic>().isDark(context);
              final img = isDarkMode ?await BgImage.getDark():await BgImage.getLight();
              final textColor = isDarkMode ? Colors.white : Color(0xff040604);
              viewModel.setConfig(viewModel.config.copyWith(currentCanvasBgImage: img, contentTextColor: textColor));
            },
            onMenuChange: changeMenuShow,
            showChapterIndex: widget.showCategory,
            loadChapter: (int? type) async {
              ///重新加载本章
              if (type == null) {
                await widget.pageProgress.reloadCurrentPageCache();
                setState(() {});
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
                    child: Builder(builder: (context) {
                      return OrientationBuilder(builder: (context, orientation) {
                        final size = orientation == Orientation.portrait ? Size(widget.pageSize.width, widget.pageSize.height) : Size(widget.pageSize.height, widget.pageSize.width);
                        viewModel.setConfig(viewModel.config.copyWith(pageSize: size));
                        return CustomPaint(
                          key: canvasKey,
                          isComplex: true,
                          size: size,
                          painter: mPainter,
                        );
                      });
                    }),
                  ),
                ),
                if (menuShow)
                  ReaderMenu(
                    config: viewModel.config,
                    chapterName: widget.pageProgress.currentChapter?.chapterName,
                  ),
              ],
            ),
          );
  }
}

mixin MenuShowBehavior<T extends StatefulWidget> on State<T> {
  var menuShow = false;

  bool hideMenu() {
    return changeMenuShow(false);
  }

  changeStatusBarColor() {
    if (menuShow)
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    else {
      if (MediaQuery.of(context).platformBrightness == Brightness.light) {
        SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
      } else {
        SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
      }
    }
    ;
  }

  bool changeMenuShow([bool? bool = null]) {
    if (bool == null) {
      setState(() {
        menuShow = !menuShow;
        changeStatusBarColor();
      });
      return true;
    } else if (bool) {
      if (menuShow == false) {
        setState(() {
          menuShow = true;
          changeStatusBarColor();
        });
        return true;
      }
    } else {
      if (menuShow == true) {
        setState(() {
          menuShow = false;
          changeStatusBarColor();
        });
        return true;
      }
    }
    return false;
  }
}
