import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:read_info/utils/developer.dart';
import 'package:read_info/widget/reader/anim/page_anim_manager.dart';
import 'package:read_info/widget/reader/reder_gesture.dart';

class ReaderSlideAnim extends NovelReaderAnim {
  ReaderSlideAnim(this.pageSize, this.controller, this.pageDrawer) {
    shadowPath = Path()
      ..moveTo(0, 0)
      ..lineTo(pageSize.width, 0)
      ..lineTo(pageSize.width, pageSize.height)
      ..lineTo(0, pageSize.height)
      ..close();
  }

  IReaderPageVm pageDrawer;
  late Path shadowPath;
  AnimationController controller;

  final Size pageSize;
  Paint paint = Paint();

  @override
  drawCanvas(Canvas canvas) {
    if (deltaX == 0 || deltaX == pageSize.width) {
      canvas.drawPicture(pageDrawer.getCurrentPagePicture());
      return;
    }
    if (deltaX > 0) {
      canvas.drawPicture(pageDrawer.getCurrentPagePicture());
      canvas.save();
      canvas.translate(-pageSize.width + deltaX, 0);
      final path = Path()
        ..moveTo(0, 0)
        ..lineTo(pageSize.width, 0)
        ..lineTo(pageSize.width, pageSize.height)
        ..lineTo(0, pageSize.height)
        ..close();

      canvas.drawShadow(path, Colors.black87, 10, false);
      canvas.drawPicture(pageDrawer.getPrePagePicture());
      canvas.restore();
    }
    if (deltaX < 0) {
      canvas.drawPicture(pageDrawer.getNextPagePicture());
      canvas.save();
      canvas.translate(deltaX, 0);
      canvas.drawShadow(shadowPath, Colors.black87, 10, false);
      canvas.drawPicture(pageDrawer.getCurrentPagePicture());
      canvas.restore();
    }
  }

  Image? preImage;
  double deltaX = 0;
  ReaderGestureDetail? lastDetail;

  @override
  Animation? onPanEnd(DragEndDetails detail) {
    debug("页面滑动放手了");
    double begin = 0;
    double end = 0;

    ///-1 是上一页  0是当前页  1是下一页
    int target = 0;

    ///这一页往左走，到下一页
    if (deltaX <= 0 && detail.velocity.pixelsPerSecond.dx < 0) {
      begin = deltaX;
      end = -pageSize.width;
      target = 1;

      ///上一页往右走，到上一页
    }else if (deltaX >= 0 && detail.velocity.pixelsPerSecond.dx > 0) {
      begin = deltaX;
      end = pageSize.width;
      target = -1;

      ///回到当前页
    } else {
      begin = deltaX;
      end = 0;
      target = 0;
    }
    controller.reset();
    Animation<double> fling = Tween<double>(begin: begin, end: end).animate(controller);
    fling.addListener(() {
      deltaX = fling.value;
    });
    AnimationStatusListener? listener;
    listener=(status) {
      if (status == AnimationStatus.completed) {
        deltaX=0;
        if (target == -1) {
          pageDrawer.toPrePage();
        }else if(target ==1){
          pageDrawer.toNextPage();
        }
        fling.removeStatusListener(listener!);
      }
    };
    fling.addStatusListener(listener);
    return fling;
  }
  @override
  bool gestureChange(ReaderGestureDetail detail) {
    deltaX = detail.panDownDelta.dx;
    lastDetail = detail;
    return true;
  }
}
