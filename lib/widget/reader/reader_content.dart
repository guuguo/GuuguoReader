import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:read_info/data/rule/novel_string_deal.dart';
import 'package:read_info/utils/ext/list_ext.dart';
import 'package:read_info/widget/reader/reader_page_progress.dart';
import 'package:read_info/widget/reader/reader_viewmodel.dart';


class ReaderContentDrawer {
  TextPainter textPainter = TextPainter(textDirection: TextDirection.ltr);
  Paint bgPaint = Paint();
  Paint configData = Paint();
  ReaderViewModel model;

  ReaderContentDrawer(this.model);
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
      var limitHeight = height;
      if (pageIndex == 0) {
        limitHeight= limitHeight/ 2;
      }
      while (currentHeight < limitHeight) {
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
        int endOffset = textPainter.getPositionForOffset(Offset(width, limitHeight - currentHeight)).offset;

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
  ui.Picture? bgPicture;

  ui.Picture drawBackground( [bool forceRedraw = false]) {
    if (bgPicture == null || forceRedraw) {
        ui.PictureRecorder pageRecorder = new ui.PictureRecorder();
        Canvas pageCanvas = new Canvas(pageRecorder);
        final image=model.config.currentCanvasBgImage;
        if(image!=null) {
          paintImage(
              canvas: pageCanvas,
              rect: Offset.zero & model.config.pageSize,
              image: image.bg,
              fit: image.fit,
              repeat: ImageRepeat.repeat,
              scale: 1.0,
              alignment: Alignment.center,
              flipHorizontally: false,
              filterQuality: FilterQuality.high
          );
          // pageCanvas.drawImageRect(image,Offset.zero & Size(image.width.toDouble(),image.height.toDouble()),Offset.zero & model.config.pageSize, bgPaint);
        }else{
          bgPaint.color = model.config.currentCanvasBgColor;
          pageCanvas.drawRect(Offset.zero & model.config.pageSize, bgPaint);
        }
        bgPicture = pageRecorder.endRecording();

    }
    return bgPicture!;
  }

  ui.Picture drawContent(ReaderChapterData chapterData, int index,ReaderPageProgress pageProgress) {
    ui.PictureRecorder pageRecorder = new ui.PictureRecorder();
    Canvas pageCanvas = new Canvas(pageRecorder);

    if (chapterData.chapterContentConfigs.length == 0) {
      ///todo: 默认错误页面；
      return pageRecorder.endRecording();
    }

    var pageContentConfig = chapterData.chapterContentConfigs[index];

    final validContentHeight = (model.config.pageSize.height - model.config.contentPaddingVertical * 2);
    pageCanvas.drawPicture(drawBackground());
    var textColor = model.config.isDark ? Colors.white : model.config.contentTextColor;

    ///第一页画上章节名
    if (index == 0) {
      var entry = getChapterIndexName(chapterData.chapterName);

      ///绘制  章节名
      textPainter.textAlign=TextAlign.center;
      textPainter.text = TextSpan(
          text: "${entry.value}",
          style: TextStyle(
            color: textColor,
            height: 1.2,
            fontSize: model.config.bottomTipFontSize.toDouble() * 2.5,
            fontWeight: FontWeight.bold,
          ));
      textPainter.layout(maxWidth: model.config.pageSize.width - (2 * model.config.contentPaddingHorizontal));
      final chapterOffHeight = validContentHeight / 4 + model.config.contentPaddingVertical - textPainter.height / 2;
      textPainter.paint(pageCanvas, Offset((model.config.pageSize.width - textPainter.width) / 2, chapterOffHeight));

      ///绘制  第几章
      if (entry.key?.isNotEmpty == true) {
        textPainter.text = TextSpan(
            text: "${entry.key}",
            style: TextStyle(
              color: textColor.withAlpha(100),
              height: 1.2,
              fontSize: model.config.bottomTipFontSize.toDouble()*1.4 ,
            ));
        textPainter.layout(maxWidth: model.config.pageSize.width - (2 * model.config.contentPaddingHorizontal));
        textPainter.paint(pageCanvas, Offset((model.config.pageSize.width - textPainter.width) / 2, chapterOffHeight-textPainter.height-10));
      }
    }
    textPainter.textAlign=TextAlign.start;
    final startHeightOff = index == 0 ? (validContentHeight / 2 + model.config.contentPaddingVertical) : model.config.contentPaddingVertical.toDouble();

    ///绘制内容
    Offset offset = Offset(model.config.contentPaddingHorizontal.toDouble(), startHeightOff);

    List<String> paragraphContents = pageContentConfig.paragraphContents;
    textPainter.textAlign = TextAlign.start;
    for (String content in paragraphContents) {
      textPainter.text = TextSpan(
          text: content,
          style: TextStyle(
              color: textColor,
              height: pageContentConfig.currentContentLineHeight / pageContentConfig.currentContentFontSize,
              fontSize: pageContentConfig.currentContentFontSize.toDouble()));
      textPainter.layout(maxWidth: model.config.pageSize.width - (2 * model.config.contentPaddingHorizontal));
      textPainter.paint(pageCanvas, offset);

      offset = Offset(model.config.contentPaddingHorizontal.toDouble(), offset.dy + textPainter.computeLineMetrics().length * pageContentConfig.currentContentLineHeight);

      offset = Offset(model.config.contentPaddingHorizontal.toDouble(), offset.dy + pageContentConfig.currentContentParagraphSpacing);
    }

    ///绘制  章节名（1/5)
    textPainter.text = TextSpan(
        text: "${chapterData.chapterName}(${index + 1}/${chapterData.chapterContentConfigs.length})",
        style: TextStyle(color: textColor.withOpacity(0.8), height:1.2, fontSize: model.config.bottomTipFontSize.toDouble()));
    textPainter.layout(maxWidth: model.config.pageSize.width - (2 * model.config.contentPaddingHorizontal));
    textPainter.paint(pageCanvas, Offset((model.config.pageSize.width - textPainter.width) / 2, model.config.pageSize.height - model.config.bottomTipHeight.toDouble()));

    // pageCanvas.drawLine(OffSet((model.config.page)), p2, paint).
    ///绘制  1/100章
    textPainter.text = TextSpan(
        text: "${chapterData.chapterIndex + 1}/${pageProgress.totalChapterCount}章",
        style: TextStyle(color: textColor.withOpacity(0.8), height: 1.2, fontSize: model.config.bottomTipFontSize.toDouble()));
    textPainter.layout(maxWidth: model.config.pageSize.width - (2 * model.config.contentPaddingHorizontal));
    textPainter.paint(pageCanvas, Offset(model.config.pageSize.width - model.config.contentPaddingHorizontal.toDouble() - textPainter.width, model.config.pageSize.height - model.config.bottomTipHeight.toDouble()));
    return pageRecorder.endRecording();
  }
}

class ReaderChapterData {
  List<ReaderContentPageData> chapterContentConfigs = [];

  // HashMap<int, ReaderContentCanvasDataValue> chapterCanvasDataMap = HashMap();
  String? content;
  String? chapterName;
  int chapterIndex;
  int currentPageIndex = 0;
  List<String> comics = [];


  bool canToNextPage() {
    return currentPageIndex < chapterContentConfigs.length - 1;
  }

  bool toNextPage() {
    if(chapterContentConfigs.isEmpty) return false;
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
    if(chapterContentConfigs.isEmpty) return false;
    if (canToPrePage()) {
      currentPageIndex--;
      return true;
    }
    return false;
  }


  ReaderContentPageData? currentPageData() => chapterContentConfigs.getOrNull(currentPageIndex);

  ReaderContentPageData? pageDate(int page) {
    if (page >= chapterContentConfigs.length) return null;
    return chapterContentConfigs.getOrNull(page);
  }

  void clearCalculateResult() {
    chapterContentConfigs.clear();
  }

  void clear() {
    clearCalculateResult();
    content = null;
    chapterIndex = 0;
    currentPageIndex = 0;
  }

  ReaderChapterData.FromIndex({
    required this.chapterIndex,
  });

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
