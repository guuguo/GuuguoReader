import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class MainCard extends StatelessWidget {
  const MainCard({Key? key, required this.child,
    this.margin = const EdgeInsets.symmetric(
        horizontal: 20, vertical: 10),
  }) : super(key: key);
  final Widget child;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    return Container(
        margin:margin,
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Theme
                .of(context)
                .cardColor),
        child: this.child);
  }
}
