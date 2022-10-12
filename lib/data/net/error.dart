import 'package:dio/dio.dart';

class NetError implements Error {
  NetError({
    this.response,
    this.message,
    this.code,
    this.stackTrace,
  });

  Response? response;

  String? message;

  int? code;

  String toString() =>
      "NetError [$code]: " + (message ?? "") + (stackTrace ?? "").toString();

  @override
  StackTrace? stackTrace;
}
