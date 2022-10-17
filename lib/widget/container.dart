import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class RoundedBoxDecoration extends BoxDecoration {
  RoundedBoxDecoration({double? radius, Color? color, List<BoxShadow>? boxShadow})
      : super(
          borderRadius: BorderRadius.circular(radius ?? 0),
          color: color,
          boxShadow: boxShadow,
        );
}
