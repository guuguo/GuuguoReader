import 'package:flutter/material.dart';

class MyGradient {

  static LinearGradient bgPrimary(BuildContext context) =>d
      LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: Theme
              .of(context)
              .brightness == Brightness.light
              ? [Color(0xFF0576FF), Color(0xFF0563FD)]
              : [Color(0xFF4535D1), Color(0xFF1C1562)]);
  static LinearGradient bgScaffold(BuildContext context) =>
      LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: Theme
              .of(context)
              .brightness == Brightness.light
          ? [Color(0xFFCFCFCF), Color(0xFFF2F2F2)]
          : [Color(0xFF131416), Color(0xFF474747)]);

  static LinearGradient bgCard1(BuildContext context) =>
      LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: Theme
              .of(context)
              .brightness == Brightness.light
          ? [Color(0xFF0576FF), Color(0xFF0563FD)]
          : [Color(0xFF4535D1), Color(0xFF1C1562)]);
}

class MyShadow{
  static List<BoxShadow> cardShadow(BuildContext context)=>
      [
        BoxShadow(
            color: Colors.blue.withAlpha(55),
            offset: Offset(0, 3),
            blurRadius: 12)
      ];
}
