import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:orientation/orientation.dart';
import 'package:read_info/global/custom/my_theme.dart';
import 'package:read_info/global/logic.dart';
import 'package:get/get.dart';
import 'package:read_info/config/route_config.dart';
import 'package:read_info/theme/darkmode.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'data/local_repository.dart';
import 'logic/init.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}

void main() async {
  sqfliteFfiInit();
  WidgetsFlutterBinding.ensureInitialized();
  await InitLogic.initialSource();

  HttpOverrides.global = MyHttpOverrides();
  runApp(MyApp());
  OrientationPlugin.setPreferredOrientations([...DeviceOrientation.values]..remove(DeviceOrientation.portraitDown));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Get.lazyPut(() => GlobalLogic());
    return GetBuilder<GlobalLogic>(builder: (controller) {
      final color=Theme.of(context).bottomAppBarTheme.color;
      OrientationPlugin.setEnabledSystemUIOverlays(SystemUiOverlay.values);
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
          systemNavigationBarColor:color,
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Theme.of(context).brightness));
      return GetMaterialApp(
        initialRoute: RouteConfig.home,
        getPages: RouteConfig.getPages,
        title: '信息阅读',
        themeMode: Get.find<GlobalLogic>().themeMode,
        theme: kLightDiaryTheme.data,
        darkTheme: kDarkDiaryTheme.data,
      );
    });
  }
}
