import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'package:read_info/data/net/dio_helper.dart';
import 'package:read_info/data/rule/RuleUtil.dart';
import 'package:read_info/generated/json/base/json_convert_content.dart';

import '../bean/book_item_bean.dart';
import '../bean/entity/source_entity.dart';

const int pageLimited = 20;

class NetRepository {
  static Future<List<SourceEntity>> getSources(String url) async {
    try {
      var res = await _getDio().get<String>(url);
      List<dynamic>? resJson = json.decode(res.data ?? "");
      List<SourceEntity> list= resJson?.map((e) => SourceEntity.fromJson(e)).toList() ?? [];
      return list;
    } catch (e) {
      print(e);
      return [];
    }
  }

  static Dio _getDio() => DioHelper.dio();
}
