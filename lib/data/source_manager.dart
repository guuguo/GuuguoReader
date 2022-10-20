import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'package:read_info/bean/entity/source_header_entity.dart';
import 'package:read_info/data/net/dio_helper.dart';
import 'package:read_info/data/rule/RuleUtil.dart';
import 'package:read_info/data/rule/app_helper.dart';
import 'package:read_info/generated/json/base/json_convert_content.dart';

import '../bean/book_item_bean.dart';
import '../bean/entity/source_entity.dart';

const int pageLimited = 20;

class SourceManager {
  List<SourceEntity> sources=[];

}
