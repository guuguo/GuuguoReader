import 'dart:async';

import 'package:flutter/cupertino.dart';

extension ScrollExt on ScrollController {
  scrollToKey(GlobalKey key) {
    Timer(Duration(milliseconds: 100),(){
      RenderBox box = key.currentContext?.findRenderObject() as RenderBox;
      print(box);
      Offset? offset = box.localToGlobal(Offset.zero);
      final animateHeight = this.offset + offset.dy-200;
      this.animateTo(animateHeight, duration: Duration(milliseconds: 400), curve: Curves.decelerate);
    });
  }
}
