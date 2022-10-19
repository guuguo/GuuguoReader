import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:read_info/page/readhistory/view.dart';
import 'package:read_info/page/source/view.dart';

class HomeState {
  ///PageView页面
  late Map<IconLabel, Widget> pageList;

  int currentIndex=0;
  HomeState() {
    pageList = {
      IconLabel(Icons.chrome_reader_mode_outlined ,Icons.chrome_reader_mode, "阅读"):ReadHistoryPage(),
      IconLabel(Icons.source_outlined, Icons.source_rounded, "书源"): SourcePage(),
    };
  }
}

class IconLabel {
  IconData icon;
  IconData iconSelected;
  String label;

  IconLabel(this.icon, this.iconSelected, this.label);
}
