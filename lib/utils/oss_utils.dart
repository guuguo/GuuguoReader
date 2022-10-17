import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';

var AccessKeyId = "yJea2KUDRjoUtgLj";
var AccessKeySecret = "YkZOgawyyvstVMSscaYt4SluKrGoG6";

extension StringExtension on String {
  List<int> toBytes() {
    return utf8.encode(this);
  }
}

class OssUtils {
  static var f = DateFormat('EEE, dd MMM yyyy HH:mm:ss');
  ///获取签名字符串
  static String buildSignature(String httpMethod, String resourcePath, RequestOptions request) {
    var Date = f.format(DateTime.now().toUtc()) + " GMT";
    request.headers['Date']=Date;
    var CanonicalizedOSSHeaders = buildCanonicalizedOSSHeaders(request);
    var CanonicalizedResource = resourcePath;
    final headers = request.headers.map((key, value) => MapEntry(key.toLowerCase(), value));
    var string = StringBuffer()..writeln(httpMethod);

    //有md5 包含md5
    if (headers.containsKey(HttpHeaders.contentMD5Header)) {
      string.write(headers[HttpHeaders.contentMD5Header]);
    }
    string.writeln();
    //有 type包含type
    if (headers.containsKey(HttpHeaders.contentTypeHeader)) {
      string.write(headers[HttpHeaders.contentTypeHeader]);
    }
    string.writeln();
    string
      ..writeln(Date)
      ..write(CanonicalizedOSSHeaders)
      ..write(CanonicalizedResource);

    var Signature = base64.encode(Hmac(sha1, AccessKeySecret.toBytes()).convert(string.toString().toBytes()).bytes);
    var Authorization = "OSS " + AccessKeyId + ":" + Signature;
    return Authorization;
  }

  ///[additionalHeaderNames] 需要额外加入签名规范的header
  static String buildCanonicalizedOSSHeaders(RequestOptions request) {
    final canonicalOssHeadersString = StringBuffer();
    final headers = request.headers;
    final canonicalizedOssHeadersToSign = SplayTreeMap<String, String>();

    headers.forEach((key, value) {
      String lowerKey = key.toLowerCase();
      if (lowerKey.startsWith("x-oss-")) {
        canonicalizedOssHeadersToSign[lowerKey] = value.toString().trim();
      }
    });

    // Append canonicalized oss headers to sign to canonical string
    canonicalizedOssHeadersToSign.forEach((key, value) {
      canonicalOssHeadersString
        ..write(key)
        ..write(':')
        ..writeln(value);
    });
    return canonicalOssHeadersString.toString();
  }
}
