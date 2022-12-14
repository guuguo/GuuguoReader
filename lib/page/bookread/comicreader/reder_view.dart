import 'dart:async';
import 'package:octo_image/octo_image.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'dart:ui' as ui;
import 'package:get/get.dart';
import 'package:read_info/page/bookread/comicreader/MySliverList.dart';
import 'package:read_info/page/bookread/comicreader/logic.dart';
import 'package:read_info/page/bookread/comicreader/reader_menu.dart';
import 'package:read_info/page/common/widget_common.dart';
import 'package:read_info/utils/developer.dart';
import 'package:read_info/utils/ext/scroll_ext.dart';
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
    this.sourceBuilder,
  }) : super(key: key);
  final VoidCallback showCategory;
  final Size pageSize;
  final ReaderPageProgress pageProgress;
  final WidgetBuilder? sourceBuilder;

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

  double? getOffsetYFromKey(GlobalKey key) {
    final render = secondColumnKey.currentContext?.findRenderObject() as RenderBox?;
    return render
        ?.localToGlobal(Offset.zero)
        .dy;
  }

  double? getHeightFromKey(GlobalKey key) {
    final render = key.currentContext?.findRenderObject() as RenderBox?;
    return render?.size.height;
  }

  var loadingMore = false;

  @override
  initState() {
    super.initState();
    controller = ScrollController();
    logic = ComicLogic(widget.pageProgress, controller);
    Get.lazyPut(() => logic);
    controller.addListener(() async {
      hideMenu();

      // controller.
      // final render = comicContentKey.currentContext?.findRenderObject() as RenderFlex?;

      // final dy=getOffsetYFromKey(secondColumnKey);
      //
      // ///??????????????????
      // if(dy!=null && dy<0 ) {
      //   try {
      //     final currentPage = controller.;
      //     if (currentPage != widget.pageProgress.currentChapterIndex) await widget.pageProgress.toNextPage();
      //   } catch(e){}
      // }
      ///???????????????200??????????????????????????????????????????
      if (controller.offset >= controller.position.maxScrollExtent) {
        if (!loadingMore) {
          loadingMore = true;
          try {
            // debug("???${logic.comics[0].first}????????????${getHeightFromKey(firstColumnKey)}");
            // debug("???${logic.comics[1].first}????????????${getHeightFromKey(secondColumnKey)}");
          } catch (e) {}
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
    await widget.pageProgress.toTargetChapter(chapterIndex);
    await logic.loadCurrentPage();
    controller.jumpTo(0);
  }

  @override
  Widget build(BuildContext context) {
    return InheritedReader(
      onMenuChange: changeMenuShow,
      showChapterIndex: widget.showCategory,
      loadChapter: (int? type) async {
        ///??????????????????
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
                child: CustomScrollView(
                  controller: controller,
                  slivers: [
                    GetBuilder<ComicLogic>(builder: (logic) {
                      return SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context,index){
                              try {
                                return ImageItem(logic.comics[index], index);
                              }catch (e) {return SizedBox(height:100);}
                            },
                              childCount:logic.comics.length,
                          ));
                    }),
                  ],
                )),
          ),
          if (menuShow)
            ComicReaderMenu(
              chapterName: widget.pageProgress.currentChapter?.chapterName,
              sourceBuilder: widget.sourceBuilder,
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

Widget ImageItem(ComicItem comic, int index) {
  final dealUrl = comic.url.replaceAll(RegExp("\/\/\/+"), '//');

  return Container(
    child: CachedNetworkImage(
      imageBuilder: (c,provider){
        provider.resolve(ImageConfiguration()).addListener(ImageStreamListener((img,call){
          comic.height =  img.image.height/img.image.width*MediaQuery.of(c).size.width;
        }));
        return Image(image: provider);
      },
      imageUrl: dealUrl,
      progressIndicatorBuilder: (c, u, p) =>
          Container(
            color: Colors.black,
            height: comic.height??comicImageDefaultHeight,
            child: Center(
              child: Text("????????????",style: TextStyle(color: Colors.white38,fontSize: 20),),
            ),
          ),
      errorWidget: (c, u, e) {
        return SizedBox(height: 400, child: Center(child: Text("????????????(${comic.index + 1}-${index + 1})")));
      },
    ),
  );
  ;
}

Future<Size> _calculateImageDimension(String url) {
  Completer<Size> completer = Completer();
  Image image = new Image(image: CachedNetworkImageProvider(url)); // I modified this line
  image.image.resolve(ImageConfiguration()).addListener(
    ImageStreamListener(
          (ImageInfo image, bool synchronousCall) {
        var myImage = image.image;
        Size size = Size(myImage.width.toDouble(), myImage.height.toDouble());
        completer.complete(size);
      },
    ),
  );
  return completer.future;
}

class ComicDelegate extends SliverChildDelegate {
  late List<ComicItem> list;

  @override
  Widget? build(BuildContext context, int index) {
    final comic = list[index];
    var child = ImageItem(comic, index);
    child = RepaintBoundary(child: child);
    child = IndexedSemantics(index: index, child: child);
    return child;
  }

  @override
  bool shouldRebuild(covariant SliverChildDelegate oldDelegate) {
    return false;
  }

  @override
  double? estimateMaxScrollOffset(int firstIndex, int lastIndex, double leadingScrollOffset, double trailingScrollOffset) {
    var sum = 0.0;
    for (int i = lastIndex; i < list.length; i++) {
      sum += list[i].height??comicImageDefaultHeight;
    }
    return sum;
  }

  @override
  int get estimatedChildCount => list.length;

  ComicDelegate(this.list);

  @override
  void didFinishLayout(int firstIndex, int lastIndex) {
    super.didFinishLayout(firstIndex, lastIndex);
  }

// @override
// int findIndexByKey(Key key) {
//   return super.findIndexByKey(key);
// }

}
