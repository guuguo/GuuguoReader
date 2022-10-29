import 'dart:async';
import 'dart:ui' as ui;
import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:read_info/res.dart';
import 'package:read_info/widget/reader/reader_content_config.dart';

import '../bean/entity/source_entity.dart';

final ARG_BOOK_ITEM_BEAN="item_bean";
final ARG_BOOK_DETAIL_BEAN="book_detail";
final ARG_ITEM_SOURCE_BEAN="source_bean";
final ARG_SEARCH_KEY="seach_key";
final ARG_SOURCE_LIST="source_list";
final source_type_novel = 0;
final source_type_sms = 1;
final source_type_comic = 2;
const defaultSourceUrl="https://gist.githubusercontent.com/guuguo/d1902049ba71149587dc074605e18f3a/raw";

final sp_dark_mode="sp_dark_mode";
///小说阅读器配置
final sp_novel_config="sp_novel_config";

class BgImage{
  static int  bgStyleLight1=0;
  static int  bgStyleLight2=1;
  static int  bgStyleLight3=2;
  static int  bgStyleLight4=3;
  static int  bgStyleColor=-1;
  static int  bgStyleDark=-2;

  static Future<BackgroundImage?> getBgImage(int? bgStyle,bool isDark) async {
    if(isDark )return await _getDark();
    if (bgStyle == null) return null;
    if (bgStyle == bgStyleColor) return null;
    if (bgStyle == bgStyleLight1) return await _getLight();
    if (bgStyle == bgStyleLight2) return await _getLight2();
    if (bgStyle == bgStyleLight3) return await _getLight3();
    if (bgStyle == bgStyleDark) return await _getDark();
    return null;
  }

  static Future<ui.Image> getImage(String res) {
    Completer<ui.Image> completer = Completer();
    AssetImage(res, bundle: rootBundle).resolve(ImageConfiguration.empty).addListener(ImageStreamListener((img, sync) {
      completer.complete(img.image);
    }));
    return completer.future;
  }

 static Future<BackgroundImage> _getLight()async{
   final img= await getImage(Res.p04);
    return BackgroundImage(img,BoxFit.fill);
  }
  static Future<BackgroundImage> _getLight2()async{
    final img= await getImage(Res.p05);
    return BackgroundImage(img,BoxFit.fill);
  }
  static Future<BackgroundImage> _getLight3()async{
    final img= await getImage(Res.p24);
    return BackgroundImage(img,BoxFit.scaleDown);
  }

  static Future<BackgroundImage> _getDark()async{
    final img= await getImage(Res.p26);
    return BackgroundImage(img,BoxFit.scaleDown);
  }
}