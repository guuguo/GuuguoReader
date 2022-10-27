import 'dart:async';
import 'dart:ui' as ui show Image, Codec, FrameInfo;
import 'package:cached_network_image_platform_interface/cached_network_image_platform_interface.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:read_info/page/bookread/comicreader/logic.dart';
import 'package:read_info/page/bookread/comicreader/reader_menu.dart';
import 'package:read_info/page/common/widget_common.dart';
import 'package:read_info/utils/developer.dart';
import 'package:read_info/widget/reader/reader_page_progress.dart';
import 'package:read_info/widget/reader/reader_viewmodel.dart';
import 'package:read_info/widget/reader/reder_gesture.dart';
import 'package:read_info/widget/reader/reder_view.dart';

typedef ReadPageChangeCallback = void Function(int pageIndex, int chapterIndex);

class ComicReader extends StatefulWidget {
  const ComicReader({
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
  State<ComicReader> createState() => ComicReaderState();
}

class ComicReaderState extends State<ComicReader> {
  late ReaderViewModel viewModel;
  late ScrollController controller;
  var menuShow = false;
  GlobalKey comicContentKey = GlobalKey();
  GlobalKey firstColumnKey = GlobalKey();
  GlobalKey secondColumnKey = GlobalKey();

  late ComicLogic logic;

  double? getOffsetYFromKey(GlobalKey key){
   final render= secondColumnKey.currentContext?.findRenderObject() as RenderBox?;
   return  render?.localToGlobal(Offset.zero).dy;
  }
  double? getHeightFromKey(GlobalKey key){
    final render= secondColumnKey.currentContext?.findRenderObject() as RenderBox?;
    return  render?.size.height;
  }
  @override
  initState() {
    super.initState();
    controller = ScrollController();
    logic = ComicLogic(widget.pageProgress, controller);
    Get.lazyPut(() => logic);
    controller.addListener(() async {
      hideMenu();

      // controller.
      final render = comicContentKey.currentContext?.findRenderObject() as RenderFlex?;
      final height = render?.size.height;
      final dy=getOffsetYFromKey(secondColumnKey);

      ///滚动到下一页
      if(dy!=null && dy<0 ) {
        final currentPage = logic.comics[1].first;
        if (currentPage != widget.pageProgress.currentChapterIndex) await widget.pageProgress.toNextPage();
      }

      if (height == null) return;
      var loadingMore = false;

      ///离底部还有200距离的时候，加载下一章的数据
      if (controller.offset > height - widget.pageSize.height-200) {
        if (!loadingMore) {
          loadingMore = true;
          await logic.addNextComicChapter(getHeightFromKey(firstColumnKey));
          loadingMore = false;
        }
      }
    });
    logic.loadCurrentPage();
  }

  update() {
    if (mounted) setState(() {});
  }

  void jumpToChapter(int chapterIndex) async {
    final loading = "正在加载数据".showLoading();
    await widget.pageProgress.toTargetChapter(chapterIndex);
    loading.close();
    logic.loadCurrentPage();
  }

  @override
  Widget build(BuildContext context) {
    return InheritedReader(
      onMenuChange: changeMenuShow,
      showChapterIndex: widget.showCategory,
      loadChapter: (int? type) async {
        ///重新加载本章
        if (type == null) {
          logic.reloadCurrentPageCache();
        }
      },
      child: Stack(
        children: [
          Positioned.fill(
            child: ReaderGesture(
              onNextTap: () {
                hideMenu();
              },
              onPreTap: () {
                hideMenu();
              },
              onCenterTap: () {
                changeMenuShow();
              },
              child: SingleChildScrollView(
                controller: controller,
                child: GetBuilder<ComicLogic>(
                  assignId: true,
                  builder: (logic) {
                    // final comics = logic.comics.fold<List<String>>([], (List<String> pre,Pair<int,List<String>> ele) => pre..addAll(ele.seconed));

                    return Column(
                      key: comicContentKey,
                      children: logic.comics
                          .mapIndexed((i, pair) => Column(
                                key: i == 0 ? firstColumnKey : (i == 1 ? secondColumnKey : null),
                                children: pair.seconed.mapIndexed((i,e) => ImageItem(i,e)).toList(),
                              ))
                          .toList(),
                    );
                  },
                ),
              ),
            ),
          ),
          if (menuShow)
            ComicReaderMenu(
              chapterName: widget.pageProgress.currentChapter?.chapterName,
            ),
        ],
      ),
    );
  }

  Widget ImageItem(int index,String url) {
    final dealUrl = url.replaceAll(RegExp("\/\/\/+"), '//');
    debug("$index $dealUrl");
    return Container(
      constraints: BoxConstraints(minHeight: 200),
      child: CachedNetworkImage(
          imageRenderMethodForWeb: ImageRenderMethodForWeb.HttpGet,
        progressIndicatorBuilder: (c, u, p) => Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
        errorWidget: (c, u, e) {
          // debug("$index $dealUrl 出错了-url:${u}");
          return Center(child: Text("该图片无法加载"));
        },
        imageUrl: dealUrl,
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
