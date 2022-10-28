import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:read_info/widget/reader/reader_content_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'constant.dart';

class GlobalLogic extends GetxController {
  var themeMode = ThemeMode.system;
  GlobalLogic(){
    loadThemeMode();
  }
  void changeThemeMode(BuildContext context)async {
    final sp=await spf;
    if (Theme.of(context).brightness == Brightness.dark) {
      themeMode = ThemeMode.light;
      sp.setBool(sp_dark_mode,false);
    } else {
      themeMode = ThemeMode.dark;
      sp.setBool(sp_dark_mode,true);
    }
    update();
  }

  isDark(BuildContext context) {
    if (themeMode == ThemeMode.dark) {
      return true;
    } else if (themeMode == ThemeMode.light) {
      return false;
    }
    return MediaQuery.of(context).platformBrightness == Brightness.dark;
  }

   SharedPreferences? _sp;

  Future<SharedPreferences> get spf async {
    if(_sp==null){
       _sp= await SharedPreferences.getInstance();
       return _sp!;
    }
    return _sp!;
  }

  void loadThemeMode() async {
    final sp=await spf;
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
  void saveConfig(ReaderConfigEntity entity) async {
    final sp=await spf;
    var map=entity.toMap();
    sp.setString(sp_novel_config, json.encode(map));
  }
  Future<ReaderConfigEntity?> getConfig() async {
    final sp=await spf;
    final jsonStr=sp.getString(sp_novel_config);
    if(jsonStr!=null)
      return ReaderConfigEntity.fromMap(json.decode(jsonStr));
    return null;
  }
}
