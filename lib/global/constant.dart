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
final source_type_novel = 0;
final source_type_sms = 1;
final source_type_comic = 2;
const defaultSourceUrl="https://gist.githubusercontent.com/guuguo/d1902049ba71149587dc074605e18f3a/raw";

final sp_dark_mode="sp_dark_mode";

class BgImage{
  static Future<ui.Image> getImage(String res) {
    Completer<ui.Image> completer = Completer();
    AssetImage(res, bundle: rootBundle).resolve(ImageConfiguration.empty).addListener(ImageStreamListener((img, sync) {
      completer.complete(img.image);
    }));
    return completer.future;
  }

 static Future<BackgroundImage> getLight()async{
   final img= await getImage(Res.p04);
    return BackgroundImage(img,BoxFit.fill);
  }

  static Future<BackgroundImage> getDark()async{
    final img= await getImage(Res.p26);
    return BackgroundImage(img,BoxFit.scaleDown);
  }
}