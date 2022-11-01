
import 'dart:ui' as ui;
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:read_info/global/constant.dart';
class BackgroundImage{
  ui.Image bg;
  BoxFit fit;

  BackgroundImage(this.bg, this.fit);
}
class ReaderConfigEntity {
  static const TYPE_ANIMATION_SIMULATION_TURN = 1;
  static const TYPE_ANIMATION_COVER_TURN = 2;
  static const TYPE_ANIMATION_SLIDE_TURN = 3;
  /// 翻页动画类型
  int currentAnimationMode = TYPE_ANIMATION_SIMULATION_TURN;

  /// 背景色
  Color currentCanvasBgColor = Color(0xfffff2cc);
  int? bgImageStyle = BgImage.bgStyleLight1;
  bool isDark=false;

  static BackgroundImage? currentCanvasBgImage;

  initBGImage()async {
    print("initBGImage start");
    currentCanvasBgImage= await BgImage.getBgImage(bgImageStyle,isDark);
    print("initBGImage end ");
  }

  int currentPageIndex = 0;
  int currentChapterIndex = 0;
  int fontSize = 18;
  int lineHeight = 30;
  int paragraphSpacing = 24;
  Color contentTextColor = Color(0xff040604);


  Size pageSize= Size(MediaQueryData.fromWindow(window).size.width, MediaQueryData.fromWindow(window).size.height);

  int contentPaddingHorizontal=20;
  int contentPaddingVertical=50;
  int titleHeight=25;
  int bottomTipHeight=40;

  int titleFontSize=20;
  int bottomTipFontSize=12;
  ReaderConfigEntity();
  ReaderConfigEntity.New({
    required this.currentAnimationMode,
    required this.currentCanvasBgColor,
    this.bgImageStyle,
    this.isDark=false,
    required this.currentPageIndex,
    required this.currentChapterIndex,
    required this.fontSize,
    required this.lineHeight,
    required this.paragraphSpacing,
    required this.pageSize,
    required this.contentPaddingHorizontal,
    required this.contentPaddingVertical,
    required this.titleHeight,
    required this.bottomTipHeight,
    required this.titleFontSize,
    required this.bottomTipFontSize,
    required this.contentTextColor,
  });

  ReaderConfigEntity copyWith({
    int? currentAnimationMode,
    Color? currentCanvasBgColor,
    int? bgImageStyle,
    bool? isDark,
    int? currentPageIndex,
    int? currentChapterIndex,
    String? novelId,
    int? fontSize,
    int? lineHeight,
    int? paragraphSpacing,
    Size? pageSize,
    int? contentPaddingHorizontal,
    int? contentPaddingVertical,
    int? titleHeight,
    int? bottomTipHeight,
    int? titleFontSize,
    int? bottomTipFontSize,
    Color? contentTextColor,
  }) {
    return ReaderConfigEntity.New(
      currentAnimationMode: currentAnimationMode ?? this.currentAnimationMode,
      currentCanvasBgColor: currentCanvasBgColor ?? this.currentCanvasBgColor,
      bgImageStyle: bgImageStyle ?? this.bgImageStyle,
      isDark: isDark??this.isDark,
      currentPageIndex: currentPageIndex ?? this.currentPageIndex,
      currentChapterIndex: currentChapterIndex ?? this.currentChapterIndex,
      fontSize: fontSize ?? this.fontSize,
      lineHeight: lineHeight ?? this.lineHeight,
      paragraphSpacing: paragraphSpacing ?? this.paragraphSpacing,
      pageSize: pageSize ?? this.pageSize,
      contentPaddingHorizontal: contentPaddingHorizontal ?? this.contentPaddingHorizontal,
      contentPaddingVertical: contentPaddingVertical ?? this.contentPaddingVertical,
      titleHeight: titleHeight ?? this.titleHeight,
      bottomTipHeight: bottomTipHeight ?? this.bottomTipHeight,
      titleFontSize: titleFontSize ?? this.titleFontSize,
      bottomTipFontSize: bottomTipFontSize ?? this.bottomTipFontSize,
      contentTextColor: contentTextColor ?? this.contentTextColor,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReaderConfigEntity &&
          runtimeType == other.runtimeType &&
          currentAnimationMode == other.currentAnimationMode &&
          currentCanvasBgColor == other.currentCanvasBgColor &&
          bgImageStyle == other.bgImageStyle &&
          isDark == other.isDark &&
          currentPageIndex == other.currentPageIndex &&
          currentChapterIndex == other.currentChapterIndex &&
          fontSize == other.fontSize &&
          lineHeight == other.lineHeight &&
          paragraphSpacing == other.paragraphSpacing &&
          contentTextColor == other.contentTextColor &&
          pageSize == other.pageSize &&
          contentPaddingHorizontal == other.contentPaddingHorizontal &&
          contentPaddingVertical == other.contentPaddingVertical &&
          titleHeight == other.titleHeight &&
          bottomTipHeight == other.bottomTipHeight &&
          titleFontSize == other.titleFontSize &&
          bottomTipFontSize == other.bottomTipFontSize;

  @override
  int get hashCode =>
      currentAnimationMode.hashCode ^
      currentCanvasBgColor.hashCode ^
      bgImageStyle.hashCode ^
      isDark.hashCode ^
      currentPageIndex.hashCode ^
      currentChapterIndex.hashCode ^
      fontSize.hashCode ^
      lineHeight.hashCode ^
      paragraphSpacing.hashCode ^
      contentTextColor.hashCode ^
      pageSize.hashCode ^
      contentPaddingHorizontal.hashCode ^
      contentPaddingVertical.hashCode ^
      titleHeight.hashCode ^
      bottomTipHeight.hashCode ^
      titleFontSize.hashCode ^
      bottomTipFontSize.hashCode;

  Map<String, dynamic> toMap() {
    return {
      'currentAnimationMode': currentAnimationMode,
      'currentCanvasBgColor': currentCanvasBgColor.value,
      'bgImageStyle': bgImageStyle,
      'currentPageIndex': currentPageIndex,
      'currentChapterIndex': currentChapterIndex,
      'fontSize': fontSize,
      'lineHeight': lineHeight,
      'paragraphSpacing': paragraphSpacing,
      'contentTextColor': contentTextColor.value,
      'contentPaddingHorizontal': contentPaddingHorizontal,
      'contentPaddingVertical': contentPaddingVertical,
      'titleHeight': titleHeight,
      'bottomTipHeight': bottomTipHeight,
      'titleFontSize': titleFontSize,
      'bottomTipFontSize': bottomTipFontSize,
    };
  }

  factory ReaderConfigEntity.fromMap(dynamic map) {
    if (null == map) return ReaderConfigEntity();
    return ReaderConfigEntity.New(
      currentAnimationMode: map['currentAnimationMode'].toInt(),
      currentCanvasBgColor:Color(map['currentCanvasBgColor'].toInt()),
      bgImageStyle:map['bgImageStyle'].toInt(),
      currentPageIndex:map['currentPageIndex'].toInt(),
      currentChapterIndex:map['currentChapterIndex'].toInt(),
      fontSize:map['fontSize'].toInt(),
      lineHeight:map['lineHeight'].toInt(),
      paragraphSpacing:map['paragraphSpacing'].toInt(),
      titleHeight:map['titleHeight'].toInt(),
      bottomTipHeight:map['bottomTipHeight'].toInt(),
      bottomTipFontSize:map['bottomTipFontSize'].toInt(),
      titleFontSize:map['titleFontSize'].toInt(),
      contentPaddingHorizontal:map['contentPaddingHorizontal'].toInt(),
      contentPaddingVertical:map['contentPaddingVertical'].toInt(),
      contentTextColor:Color(map['contentTextColor'].toInt()),
      pageSize:Size(MediaQueryData.fromWindow(window).size.width, MediaQueryData.fromWindow(window).size.height),
    );
  }
}
