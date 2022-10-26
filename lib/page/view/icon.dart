import 'package:flutter/material.dart';
import 'package:read_info/global/custom/my_theme.dart';

class PrimaryIconButton extends StatelessWidget {
  const PrimaryIconButton(this.icon, {Key? key,this.onPressed,this.color}) : super(key: key);
  final IconData? icon;
  final VoidCallback? onPressed;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      visualDensity: VisualDensity.compact,
      enableFeedback: false,
      padding: EdgeInsets.all(4),
      onPressed: onPressed,
      icon: Icon(icon, color: color??MyTheme(context).primaryColor, size: 20),
    );
  }
}
