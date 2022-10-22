import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:read_info/utils/utils_screen.dart';
import 'package:read_info/widget/reader/reader_content_config.dart';
import 'package:read_info/widget/reader/reader_viewmodel.dart';
import 'package:read_info/widget/reader/reder_gesture.dart';
import 'package:read_info/widget/reader/reder_painter.dart';

import '../../page/view/my_appbar.dart';

typedef ReadPageChangeCallback = void Function(int pageIndex, int chapterIndex);

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

  @override
  State<NovelReader> createState() => _NovelReaderState();
}

class _NovelReaderState extends State<NovelReader> {
  NovelPagePainter? mPainter;
  late ReaderViewModel viewModel;
  GlobalKey canvasKey = new GlobalKey();
  var menuShow = false;

  @override
  initState() {
    super.initState();
    viewModel = ReaderViewModel(widget.chapterProvider, widget.readChangeCallback, widget.startChapterIndex, widget.startReadPageIndex);
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
    return Stack(
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
          child: CustomPaint(
            key: canvasKey,
            isComplex: true,
            size: widget.pageSize,
            painter: mPainter,
          ),
        )),
        if (menuShow)
          Positioned.fill(
              child: DefaultTextStyle(
                style: TextStyle(inherit: false,color:Colors.white),
                child: IconTheme(
                    data: IconTheme.of(context).copyWith(color: Colors.white),
                    child: Column(
                      children: [
                        MenuHeader(),
                        Expanded(child: SizedBox()),
                        MenuBottom(),
                      ],
                    )),
              )),
      ],
    );
  }

  void changeMenuShow() {
    setState(() {
      menuShow = !menuShow;
    });
  }
  void hideMenu() {
    if(menuShow){
      setState(() {
        menuShow = false;
      });
    }
  }

  Widget MenuHeader() {
    return Container(
      padding: EdgeInsets.only(top:MediaQuery.of(context).padding.top),
        height: kToolbarHeight,
        width: double.infinity,
        color: Colors.black54,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: MyBackButton(),
              ),
            Text(viewModel.currentChapter?.chapterName??"",style:TextStyle(fontSize: 18))
          ],
        ));
  }

  Widget MenuBottom() {
    return Container(
      height: 100,
      width: double.infinity,
      color: Colors.black54,
      child: Container(
        constraints: BoxConstraints.loose(Size(600,double.infinity)),
        child: Row(
          mainAxisSize:MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
             IconMenu(Icons.format_list_bulleted,onPressed: (){
               changeMenuShow();
               widget.showIndex();
             }),
            IconMenu(Icons.format_list_bulleted),
            IconMenu(Icons.format_list_bulleted),
            IconMenu(Icons.format_list_bulleted),
            IconMenu(Icons.format_list_bulleted),
          ],
        ),
      ),
    );
  }

  Widget IconMenu(IconData icon,{VoidCallback? onPressed}) {
    return Expanded(child:GestureDetector(onTap:onPressed,child: Icon(icon)));
  }
}
