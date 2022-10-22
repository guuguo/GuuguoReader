import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../data/net_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'constant.dart';

class GlobalLogic extends GetxController {
  var themeMode = ThemeMode.system;
  GlobalLogic(){
    loadThemeMode();
  }
  void changeThemeMode(BuildContext context) {
    if (Theme.of(context).brightness == Brightness.dark) {
      themeMode = ThemeMode.light;
      sp.setBool(sp_dark_mode,false);
    } else {
      themeMode = ThemeMode.dark;
      sp.setBool(sp_dark_mode,true);
    }
    update();
  }
  late final SharedPreferences sp;
  void loadThemeMode() async {
    sp=await SharedPreferences.getInstance();
    final darkMode = sp.getBool(sp_dark_mode);
    if (darkMode == null)
      this.themeMode = ThemeMode.system;
    else if (darkMode == false) {
      this.themeMode = ThemeMode.light;
      update();
    } else {
      this.themeMode = ThemeMode.dark;
      update();
    }
  }
}
