import 'package:flutter/material.dart';

PopupMenuEntry popItem({IconData? icon, String? text, VoidCallback? onTap}) {
  return PopupMenuItem(
      child: Row(
        children: [
          Icon(icon),
          if (text != null) ...[SizedBox(width: 10), Text(text)]
        ],
      ),
      onTap: onTap);
}
