
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:read_info/utils/utils_screen.dart';

class ReaderConfigEntity {
  static const TYPE_ANIMATION_SIMULATION_TURN = 1;
  static const TYPE_ANIMATION_COVER_TURN = 2;
  static const TYPE_ANIMATION_SLIDE_TURN = 3;
  /// 翻页动画类型
  int currentAnimationMode = TYPE_ANIMATION_SIMULATION_TURN;

  /// 背景色
  Color currentCanvasBgColor = Color(0xfffff2cc);

  int currentPageIndex = 0;
  int currentChapterIndex = 0;
  String? novelId;

  int fontSize = 20;
  int lineHeight = 30;
  int paragraphSpacing = 10;
  Color contentTextColor = Colors.red;


  Size pageSize= Size(MediaQueryData.fromWindow(window).size.width, MediaQueryData.fromWindow(window).size.height);

  int contentPadding=20;
  int titleHeight=25;
  int bottomTipHeight=20;

  int titleFontSize=20;
  int bottomTipFontSize=12;
  ReaderConfigEntity();
  ReaderConfigEntity.New({
    required this.currentAnimationMode,
    required this.currentCanvasBgColor,
    required this.currentPageIndex,
    required this.currentChapterIndex,
    required this.novelId,
    required this.fontSize,
    required this.lineHeight,
    required this.paragraphSpacing,
    required this.pageSize,
    required this.contentPadding,
    required this.titleHeight,
    required this.bottomTipHeight,
    required this.titleFontSize,
    required this.bottomTipFontSize,
  });

  ReaderConfigEntity copyWith({
    int? currentAnimationMode,
    Color? currentCanvasBgColor,
    int? currentPageIndex,
    int? currentChapterIndex,
    String? novelId,
    int? fontSize,
    int? lineHeight,
    int? paragraphSpacing,
    Size? pageSize,
    int? contentPadding,
    int? titleHeight,
    int? bottomTipHeight,
    int? titleFontSize,
    int? bottomTipFontSize,
  }) {
    return ReaderConfigEntity.New(
      currentAnimationMode: currentAnimationMode ?? this.currentAnimationMode,
      currentCanvasBgColor: currentCanvasBgColor ?? this.currentCanvasBgColor,
      currentPageIndex: currentPageIndex ?? this.currentPageIndex,
      currentChapterIndex: currentChapterIndex ?? this.currentChapterIndex,
      novelId: novelId ?? this.novelId,
      fontSize: fontSize ?? this.fontSize,
      lineHeight: lineHeight ?? this.lineHeight,
      paragraphSpacing: paragraphSpacing ?? this.paragraphSpacing,
      pageSize: pageSize ?? this.pageSize,
      contentPadding: contentPadding ?? this.contentPadding,
      titleHeight: titleHeight ?? this.titleHeight,
      bottomTipHeight: bottomTipHeight ?? this.bottomTipHeight,
      titleFontSize: titleFontSize ?? this.titleFontSize,
      bottomTipFontSize: bottomTipFontSize ?? this.bottomTipFontSize,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReaderConfigEntity &&
          runtimeType == other.runtimeType &&
          currentAnimationMode == other.currentAnimationMode &&
          currentCanvasBgColor == other.currentCanvasBgColor &&
          currentPageIndex == other.currentPageIndex &&
          currentChapterIndex == other.currentChapterIndex &&
          fontSize == other.fontSize &&
          lineHeight == other.lineHeight &&
          paragraphSpacing == other.paragraphSpacing &&
          contentTextColor == other.contentTextColor &&
          pageSize == other.pageSize &&
          contentPadding == other.contentPadding &&
          titleHeight == other.titleHeight &&
          bottomTipHeight == other.bottomTipHeight &&
          titleFontSize == other.titleFontSize &&
          bottomTipFontSize == other.bottomTipFontSize;

  @override
  int get hashCode =>
      currentAnimationMode.hashCode ^
      currentCanvasBgColor.hashCode ^
      currentPageIndex.hashCode ^
      currentChapterIndex.hashCode ^
      fontSize.hashCode ^
      lineHeight.hashCode ^
      paragraphSpacing.hashCode ^
      contentTextColor.hashCode ^
      pageSize.hashCode ^
      contentPadding.hashCode ^
      titleHeight.hashCode ^
      bottomTipHeight.hashCode ^
      titleFontSize.hashCode ^
      bottomTipFontSize.hashCode;
}
