import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../r.dart';

///圆角图片
class RoundedImage extends StatelessWidget {
  RoundedImage.url({
    this.width,
    this.height,
    this.radius = 8,
    this.borderSide,
    BoxFit? fit,
    required String imageUrl,
  }) : image = Image.network(
          imageUrl,
          width: width ?? (roundWidth(radius)),
          height: height ?? (roundWidth(radius)),
          fit: fit,
        );

  ///简化placeHolder 和error 的传输
  RoundedImage.urlSimple({
    this.width,
    this.height,
    this.radius,
    this.borderSide,
    required String imageUrl,
    BoxFit? fit,
    String? placeholderAssetPath,
  }) : image = Image.network(
          imageUrl,
          width: width ?? (roundWidth(radius)),
          height: height ?? (roundWidth(radius)),
          fit: fit,
        );

  RoundedImage.assets({
    this.width,
    this.height,
    this.radius,
    this.borderSide,
    BoxFit? fit,
    required String name,
  }) : image = Image.asset(
          name,
          fit: fit,
          width: width ?? (roundWidth(radius)),
          height: height ?? (roundWidth(radius)),
        );

  ///宽
  final double? width;

  ///高
  final double? height;

  ///圆角
  final double? radius;
  final Widget image;

  ///边框
  final BorderSide? borderSide;

  @override
  Widget build(BuildContext context) {
    Widget child = image;
    if (radius != null && radius! > 0)
      child = ClipRRect(
        borderRadius: BorderRadius.circular(radius!),
        child: image,
      );
    if (borderSide != null)
      child = Container(
        child: child,
        decoration: ShapeDecoration(
            shape: RoundedRectangleBorder(
                side: borderSide!, borderRadius: BorderRadius.circular(radius!))),
      );
    return child;
  }
}

double? roundWidth(double? radius) => radius == null ? null : radius * 2;
