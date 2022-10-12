// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:read_info/global/custom/my_page_transitions.dart';

class DiaryTheme {
  const DiaryTheme._(this.name, this.themeMode, this.data);

  final String name;
  final ThemeMode themeMode;
  final ThemeData data;

  @override
  String toString() {
    return 'DiaryTheme{name: $name, data: $data}';
  }
}

final DiaryTheme kDarkDiaryTheme = DiaryTheme._('Dark', ThemeMode.dark, _buildDarkTheme());
final DiaryTheme kLightDiaryTheme = DiaryTheme._('Light', ThemeMode.light, _buildLightTheme());

final kCupertinoLightTheme = _buildCupertinoLightTheme();
final kCupertinoDarkTheme = _buildCupertinoDarkTheme();

T adaptWidth<T>(BuildContext context, {required T lValue, T? mValue, T? sValue}) {
  mValue = mValue ?? lValue;
  sValue = sValue ?? mValue;
  if (MediaQuery.of(context).size.width > 1200) {
    return lValue;
  } else {
    return (MediaQuery.of(context).size.width > 615 ? mValue! : sValue!);
  }
}

TextTheme _buildTextTheme(TextTheme base, [Color? color]) {
  return base.apply(bodyColor: color).copyWith(
        subtitle1: base.subtitle1!.copyWith(fontFamily: 'GoogleSans'),
        bodyText1: base.bodyText1!.copyWith(fontSize: 15),
        subtitle2: base.subtitle2!,
      );
}

CupertinoThemeData _buildCupertinoLightTheme() {
  return CupertinoThemeData(brightness: Brightness.light);
}

CupertinoThemeData _buildCupertinoDarkTheme() {
  final base = CupertinoThemeData(brightness: Brightness.dark);
  return base.copyWith(barBackgroundColor: Color(0xFF202124), textTheme: CupertinoTextThemeData(navTitleTextStyle: base.textTheme.navTitleTextStyle.copyWith(color: Colors.white)));
}

ThemeData _buildDarkTheme() {
  const primaryColor = Color(0xFF202124);
  const secondaryColor = Color(0xFF13B9FD);
  final base = ThemeData.dark();
  final colorScheme = const ColorScheme.dark().copyWith(
    primary: primaryColor,
    secondary: secondaryColor,
    surface: Color(0xFFEEEEEE),
  );
  return base.copyWith(
    primaryColor: primaryColor,
    buttonColor: primaryColor,
    splashColor: Colors.white12,
    cupertinoOverrideTheme: _buildCupertinoDarkTheme(),
    indicatorColor: Colors.white,
    accentColor: secondaryColor,
    pageTransitionsTheme: MyPageTransitionsTheme(),
    canvasColor: const Color(0xFF202124),
    backgroundColor: const Color(0xFF202124),
    errorColor: const Color(0xFFB00020),
    buttonTheme: ButtonThemeData(
      colorScheme: colorScheme,
      textTheme: ButtonTextTheme.primary,
    ),
    textTheme: _buildTextTheme(base.textTheme),
    primaryTextTheme: _buildTextTheme(base.primaryTextTheme),
    accentTextTheme: _buildTextTheme(base.accentTextTheme),
  );
}

ThemeData _buildLightTheme() {
  const primaryColor = Color(0xFF0175c2);
  const secondaryColor = Color(0xFF13B9FD);
  final colorScheme = const ColorScheme.light()
      .copyWith(primary: primaryColor, secondary: secondaryColor, surface: Colors.white, onPrimary: Colors.white, onSecondary: primaryColor, background: const Color(0xFFF8F9FA));
  final base = ThemeData.light();
  return base.copyWith(
    colorScheme: colorScheme,
    appBarTheme: base.appBarTheme.copyWith(color: Colors.white, iconTheme: base.iconTheme, textTheme: base.textTheme, brightness: Brightness.light),
    primaryColor: primaryColor,
    buttonColor: primaryColor,
    cupertinoOverrideTheme: _buildCupertinoLightTheme(),
    indicatorColor: Colors.white,
    pageTransitionsTheme: MyPageTransitionsTheme(),
    splashColor: Colors.black12,
    splashFactory: InkRipple.splashFactory,
    accentColor: secondaryColor,
    scaffoldBackgroundColor: const Color(0xFFF4F5F5),
    errorColor: const Color(0xFFB00020),
    buttonTheme: ButtonThemeData(
      colorScheme: colorScheme,
      textTheme: ButtonTextTheme.primary,
    ),
    textTheme: _buildTextTheme(base.textTheme, Color(0xff333333)),
    primaryTextTheme: _buildTextTheme(base.primaryTextTheme),
    accentTextTheme: _buildTextTheme(base.accentTextTheme),
    backgroundColor: const Color(0xFFF8F9FA),
    chipTheme: ChipThemeData.fromDefaults(
      brightness: Brightness.light,
      secondaryColor: primaryColor,
      labelStyle: _buildTextTheme(base.textTheme).bodyText2!,
    ).copyWith(
      backgroundColor: Color(0xFFF4F5F5),
    ),
  );
}

MaterialStateProperty<Color> kButtonBackgroundColor(BuildContext context) => MaterialStateProperty.resolveWith<Color>(
      (Set<MaterialState> states) {
        if (states.contains(MaterialState.pressed)) return Theme.of(context).colorScheme.primary.withOpacity(0.5);
        return Theme.of(context).colorScheme.primary;
      },
    );

MaterialStateProperty<Color> kButtonForegroundColor(BuildContext context) => MaterialStateProperty.resolveWith<Color>(
      (Set<MaterialState> states) {
        if (states.contains(MaterialState.pressed)) return Theme.of(context).colorScheme.onPrimary.withOpacity(0.5);
        return Theme.of(context).colorScheme.onPrimary;
      },
    );

MaterialStateProperty<TextStyle> kButtonTextStyle(BuildContext context) {
  final defaultStyle = Theme.of(context).textTheme.button;
  final defaultColor = Theme.of(context).colorScheme.onPrimary;

  return MaterialStateProperty.resolveWith<TextStyle>(
    (Set<MaterialState> states) {
      if (states.contains(MaterialState.pressed)) return defaultStyle!.copyWith(color: defaultColor.withOpacity(0.5));
      return defaultStyle!.copyWith(color: defaultColor);
    },
  );
}
