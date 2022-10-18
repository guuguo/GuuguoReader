import 'dart:ui' as ui;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:read_info/bean/book_item_bean.dart';
import 'package:read_info/utils/utils_screen.dart';

import 'reader_content_config.dart';

class ReaderContentDrawer {
  TextPainter textPainter = TextPainter(textDirection: TextDirection.ltr);
  Paint bgPaint = Paint();
  Paint configData = Paint();
  ReaderConfigEntity configEntity = ReaderConfigEntity();

  /// em…………由于大量文字计算，即Cpu计算，在UI的Isolate会阻塞后续的UI事件（例如跳转，动画啥的），所以采取新建Isolate的方式，这也是flutter中建议的&……
  /// 但是目前尴尬的是：
  /// 非UI的Isolate不支持UI控件，即下面的textPainter废了……一调用就报错
  /// https://github.com/flutter/flutter/issues/30604
  /// 所以，理论上来说，这块的计算应该放到一个子线程中，对于目前功能来说，也可以说是isolate中，但是flutter 现在不支持……
  /// 现在个人有几种想法：
  /// 1、翻页的时候动态计算，只缓存几页的内容，下次翻页的时候再计算
  /// 2、https://github.com/flutter/flutter/issues/30604 裁剪canvas
  /// 3、平台计算……
  /// 4、自己新建一个主isolate？但是不给它任何View？
  ///
  ///
  /// 评测结果记录：
  /// 1、这样不行，这样无法计算上一章的最后一页
  /// 2、但是这种方式是基于不自定义段落间距，而固定所有行距实现的，无法自定义
  /// 3、但是不能保证Android平台和ios平台自己计算结果和flutter的一致……
  /// 4、好像https://pub.dev/packages/flutter_isolate 实现了这点。
  ///
  /// 现阶段基于flutter v1.10.14,其中有个LineMetrics，解决了无法获得段落展示高度的问题(说白了就是提供了行数，这样直接用行数*行高)，因此不需要一行一行的那种计算，大大减少了layout的次数
  /// 计算慢说白了就是layout导致的，flutter啥时候出个像android stackLayout或者painter breakText这种不需要布局测绘即可得出展示指针位置的方法啊

  static List<ReaderContentPageData> getChapterPageContentConfigList(
    int targetChapterId,
    String content,
    double height,
    double width,
    int fontSize,
    int lineHeight,
    int paragraphSpacing,
  ) {
    String tempContent;
    List<ReaderContentPageData> pageConfigList = [];
    double currentHeight = 0;
    int pageIndex = 0;

    TextPainter textPainter = TextPainter(textDirection: TextDirection.ltr);

    if (content == null) {
      return [];
    }

    List<String> paragraphs = content.split("\n");

    while (paragraphs.length > 0) {
      ReaderContentPageData config = ReaderContentPageData(
        currentChapterId: targetChapterId,
        currentContentFontSize: fontSize,
        currentContentLineHeight: lineHeight,
        currentContentParagraphSpacing: paragraphSpacing,
        currentPageIndex: pageIndex,
        paragraphContents: [],
      );

      while (currentHeight < height) {
        /// 如果最后一行再添一行比页面高度大，或者已经没有内容了，那么当前页面计算结束
        if (currentHeight + lineHeight >= height || paragraphs.length == 0) {
          break;
        }

        tempContent = paragraphs[0];

        /// 配置画笔 ///
        textPainter.text = TextSpan(text: tempContent, style: TextStyle(fontSize: fontSize.toDouble(), height: lineHeight / fontSize));
        textPainter.layout(maxWidth: width);

        /// 当前段落内容计算偏移量
        /// 为什么要减一个lineHeight？因为getPositionForOffset判断依据是只要能展示，即使展示不全，也在它的判定范围内，所以如需要减去一行高度
        int endOffset = textPainter.getPositionForOffset(Offset(width, height - currentHeight - lineHeight)).offset;

        /// 当前展示内容
        String currentParagraphContent = tempContent;

        /// 改变当前计算高度
        List<ui.LineMetrics> lineMetrics = textPainter.computeLineMetrics();

        /// 如果当前段落的内容展示不下，那么裁剪出展示内容，剩下内容填回去,否则移除顶部,计算下一个去
        if (endOffset < tempContent.length) {
          currentParagraphContent = tempContent.substring(0, endOffset);

          /// 剩余内容
          String leftParagraphContent = tempContent.substring(endOffset);

          /// 填入原先的段落数组中
          paragraphs[0] = leftParagraphContent;

          /// 改变当前计算高度,既然当前内容展示不下，那么currentHeight自然是height了
          currentHeight = height;
        } else {
          paragraphs.removeAt(0);

          currentHeight += lineHeight * lineMetrics.length;
          currentHeight += paragraphSpacing;
        }

        config.paragraphContents.add(currentParagraphContent);
      }

      pageConfigList.add(config);
      currentHeight = 0;
      pageIndex++;
    }

    return pageConfigList;
  }

  ui.Picture drawContent(ReaderChapterData chapterData, int index) {
    ui.PictureRecorder pageRecorder = new ui.PictureRecorder();
    Canvas pageCanvas = new Canvas(pageRecorder);

    if (chapterData.chapterContentConfigs.length == 0) {
      ///todo: 默认错误页面；
      return pageRecorder.endRecording();
    }

    var pageContentConfig = chapterData.chapterContentConfigs[index];

    bgPaint.color = configEntity.currentCanvasBgColor;
    pageCanvas.drawRect(Offset.zero & configEntity.pageSize, bgPaint);
    // ///绘制章节名
    // textPainter.text = TextSpan(
    //     text: "${dataValue.chapterName}",
    //     style: TextStyle(
    //         color: Colors.red[700],
    //         height: configEntity.titleHeight.toDouble() /
    //             configEntity.titleFontSize,
    //         fontWeight: FontWeight.bold,
    //         fontSize: configEntity.titleFontSize.toDouble()));
    // textPainter.layout(
    //     maxWidth:
    //         configEntity.pageSize.width - (2 * configEntity.contentPadding));
    // textPainter.paint(
    //     pageCanvas,
    //     Offset(configEntity.contentPadding.toDouble(),
    //         configEntity.contentPadding.toDouble()));

    ///绘制内容
    Offset offset = Offset(configEntity.contentPadding.toDouble(), configEntity.contentPadding.toDouble());

    List<String> paragraphContents = pageContentConfig.paragraphContents;
    textPainter.textAlign = TextAlign.start;
    for (String content in paragraphContents) {
      textPainter.text = TextSpan(
          text: content,
          style: TextStyle(
              color: configEntity.contentTextColor,
              height: pageContentConfig.currentContentLineHeight / pageContentConfig.currentContentFontSize,
              fontSize: pageContentConfig.currentContentFontSize.toDouble()));
      textPainter.layout(maxWidth: configEntity.pageSize.width - (2 * configEntity.contentPadding));
      textPainter.paint(pageCanvas, offset);

      offset = Offset(configEntity.contentPadding.toDouble(), offset.dy + textPainter.computeLineMetrics().length * pageContentConfig.currentContentLineHeight);

      offset = Offset(configEntity.contentPadding.toDouble(), offset.dy + pageContentConfig.currentContentParagraphSpacing);
    }
    textPainter.text = TextSpan(
        text: "${chapterData.chapterName}(${index + 1}/${chapterData.chapterContentConfigs.length})",
        style: TextStyle(color: configEntity.contentTextColor, height: configEntity.bottomTipHeight.toDouble() / configEntity.bottomTipFontSize, fontSize: configEntity.bottomTipFontSize.toDouble()));
    textPainter.layout(maxWidth: configEntity.pageSize.width - (2 * configEntity.contentPadding));
    textPainter.paint(
        pageCanvas, Offset((configEntity.pageSize.width - textPainter.width) / 2, configEntity.pageSize.height - configEntity.contentPadding.toDouble() - configEntity.bottomTipHeight.toDouble()));

    textPainter.text = TextSpan(
        text: "${chapterData.chapterIndex + 1}/${100}章",
        style: TextStyle(color: configEntity.contentTextColor, height: configEntity.bottomTipHeight.toDouble() / configEntity.bottomTipFontSize, fontSize: configEntity.bottomTipFontSize.toDouble()));
    textPainter.layout(maxWidth: configEntity.pageSize.width - (2 * configEntity.contentPadding));
    textPainter.paint(pageCanvas,
        Offset(configEntity.pageSize.width - configEntity.contentPadding.toDouble() - textPainter.width, configEntity.pageSize.height - configEntity.contentPadding.toDouble() - textPainter.height));
    return pageRecorder.endRecording();
  }
}

class ReaderChapterData {
  List<ReaderContentPageData> chapterContentConfigs = [];

  // HashMap<int, ReaderContentCanvasDataValue> chapterCanvasDataMap = HashMap();
  String? content;
  String? chapterName;
  int chapterIndex = 0;

  int currentPageIndex = 0;

  bool canToNextPage() {
    return currentPageIndex < chapterContentConfigs.length - 1;
  }

  bool toNextPage() {
    if (canToNextPage()) {
      currentPageIndex++;
      return true;
    }
    return false;
  }

  bool canToPrePage() {
    return currentPageIndex > 0;
  }

  bool toPrePage() {
    if (canToPrePage()) {
      currentPageIndex--;
      return true;
    }
    return false;
  }

  ReaderContentPageData currentPageData() => chapterContentConfigs[currentPageIndex];

  ReaderContentPageData? pageDate(int page) {
    if (page >= chapterContentConfigs.length) return null;
    return chapterContentConfigs[page];
  }

  void clearCalculateResult() {
    chapterContentConfigs.clear();
    // chapterCanvasDataMap.clear();
  }

  void clear() {
    clearCalculateResult();
    content = null;
    chapterIndex = 0;
    currentPageIndex = 0;
  }

// @override
// bool operator ==(Object other) =>
//     identical(this, other) ||
//         other is ReaderContentDataValue &&
//             runtimeType == other.runtimeType &&
//             chapterIndex == other.chapterIndex &&
//             novelId == other.novelId &&
//             currentPageIndex == other.currentPageIndex;
//
// @override
// int get hashCode =>
//     chapterIndex.hashCode ^
//     novelId.hashCode ^
//     currentPageIndex.hashCode;
}

class ReaderContentPageData {
  int currentContentFontSize;
  int currentContentLineHeight;
  int currentContentParagraphSpacing;

  int currentPageIndex;
  int? currentChapterId;

  List<String> paragraphContents;
  ui.Picture? pagePicture;

  // ui.Image? pageImage;

  ReaderContentPageData({
    required this.currentContentFontSize,
    required this.currentContentLineHeight,
    required this.currentContentParagraphSpacing,
    required this.currentPageIndex,
    this.currentChapterId,
    required this.paragraphContents,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReaderContentPageData &&
          runtimeType == other.runtimeType &&
          currentContentFontSize == other.currentContentFontSize &&
          currentContentLineHeight == other.currentContentLineHeight &&
          currentContentParagraphSpacing == other.currentContentParagraphSpacing &&
          currentPageIndex == other.currentPageIndex &&
          currentChapterId == other.currentChapterId &&
          paragraphContents == other.paragraphContents;

  @override
  int get hashCode =>
      currentContentFontSize.hashCode ^
      currentContentLineHeight.hashCode ^
      currentContentParagraphSpacing.hashCode ^
      currentPageIndex.hashCode ^
      currentChapterId.hashCode ^
      paragraphContents.hashCode;

  Map toJson() {
    Map map = new Map();
    map["currentContentFontSize"] = this.currentContentFontSize;
    map["currentContentLineHeight"] = this.currentContentLineHeight;
    map["currentContentParagraphSpacing"] = this.currentContentParagraphSpacing;
    map["currentPageIndex"] = this.currentPageIndex;
    map["currentChapterId"] = this.currentChapterId;
    map["paragraphConfigs"] = this.paragraphContents;
    return map;
  }

  static ReaderContentPageData fromMap(Map<String, dynamic> map) {
    ReaderContentPageData chapterConfig = new ReaderContentPageData(
      currentContentFontSize: map['currentContentFontSize'],
      currentContentLineHeight: map['currentContentLineHeight'],
      currentContentParagraphSpacing: map['currentContentParagraphSpacing'],
      currentPageIndex: map['currentPageIndex'],
      currentChapterId: map['currentChapterId'],
      paragraphContents: (map['paragraphConfigs'] as List?)?.map((e) => e?.toString() ?? "").toList() ?? [],
    );
    return chapterConfig;
  }
}
