import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:read_info/config/config.dart';
import 'package:read_info/utils/developer.dart';
import 'package:read_info/utils/oss_utils.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

import 'error_handler.dart';
import 'intercepters/log_interceptors.dart';

///缓存的超时时间
const String _OPTIONS_CACHE_AGE = "OPTIONS_CACHE_AGE";

///缓存的类型
const String _OPTIONS_CACHE_TYPE = "OPTIONS_CACHE_TYPE";

///额外的key 最终key请求的URL + 额外的key 的md5值
const String _OPTIONS_CACHE_SUB_KEY = "OPTIONS_CACHE_SUB_KEY";

///最大超时时间
const Duration CACHE_MAX_AGE = Duration(days: 15);

///json格式化展示
const jsonFormat = false;

///开始请求的时候需不需要打印
const apiRequestLogPrint = false;
enum NetMethod {
  get,
  post,
  put,
  delete,
}

void netErrorPrint(Object e, String url, params) {
  debug(e, tag: "网络请求出错了");
  debug(url, tag: "url");
  debug(params, tag: "参数");
}

Response _checkResponse(Response<Map> response) {
  return response;
}

class DioHelper {
  static const METHOD_GET = "GET";
  static const METHOD_POST = "POST";
  static const METHOD_PUT = "PUT";
  static const METHOD_POST_FORM = "POST_FORM";

  static const _TAG = '网络';

  static final ContentType contentTypeXxxForm = ContentType.parse("application/x-www-form-urlencoded");

  static Dio dio([String baseUrl = ""]) {
    var _dio = new Dio();
    // 配置dio实例
    _dio.options
      ..baseUrl = baseUrl
      ..connectTimeout = 20000
      ..receiveTimeout = 8000;

    _dio.interceptors.add(LogsInterceptors(_dio));
    return _dio;
  }

  Future<Response> download(String url, {String? savePath}) async {
    if (savePath == null) {
      savePath = await getSaveCachePath();
    }
    final res = await Dio().download(url, savePath);
    return res;
  }


  static Future<String> getSaveCachePath({String? fileName}) async =>
      path.join((await getTemporaryDirectory()).path, "guuguohome", "temp_" + (fileName ?? DateTime.now().microsecondsSinceEpoch.toString()) + ".jpg");
}



///Generate MD5 hash
String generateMd5(String data) {
  final content = Utf8Encoder().convert(data);
  final digest = md5.convert(content);
  return hex.encode(digest.bytes);
} //
