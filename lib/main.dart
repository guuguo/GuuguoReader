import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

void main() async {
  sqfliteFfiInit();
  WidgetsFlutterBinding.ensureInitialized();
  await InitLogic.initialSource();


  HttpOverrides.global = MyHttpOverrides();
  runApp(MyApp());
  if (Platform.isAndroid) {
    SystemUiOverlayStyle style = SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,

        ///这是设置状态栏的图标和字体的颜色
        ///Brightness.light  一般都是显示为白色
        ///Brightness.dark 一般都是显示为黑色
        statusBarIconBrightness: Brightness.light);
    SystemChrome.setSystemUIOverlayStyle(style);
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Get.lazyPut(() => GlobalLogic());
    return GetBuilder<GlobalLogic>(
        builder: (controller) => GetMaterialApp(
              // theme:themeMode== ,
              // themeMode: controller.themeMode,
              initialRoute: RouteConfig.home,
              getPages: RouteConfig.getPages,
              title: '信息阅读',
              theme: kLightDiaryTheme.data,
              darkTheme: kDarkDiaryTheme.data,
            ));
  }
}
