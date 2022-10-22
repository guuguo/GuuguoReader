import 'dart:convert';
import 'dart:developer' as developer;
import 'package:dio/dio.dart';

const EXCLUDE_URL = ['getRealTimeUserData'];

// Log 拦截器
class LogsInterceptors extends InterceptorsWrapper {
  final String topBorder = '┌---------------------------------------------------';
  final String bottomBorder = '└---------------------------------------------------';

  final AnsiColor requestColor = AnsiColor.fg(80);
  final AnsiColor responseColor = AnsiColor.fg(100);
  final AnsiColor errorColor = AnsiColor.fg(196);

  final String env;
  final Dio dio;

  LogsInterceptors(
    this.dio, {
    this.env = 'dev',
  });

  @override
  onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    printRequest(options, null);
    handler.next(options);
  }

  @override
  onResponse(
    Response response,
    ResponseInterceptorHandler handler,
  ) async {
    printResponse(response, null);
    handler.next(response);
  }

  @override
  onError(
    DioError err,
    ErrorInterceptorHandler handler,
  ) async {
    printError(err, null);
    handler.next(err);
  }

  /// 打印request
  void printRequest(RequestOptions options, AnsiColor? color) {
    if (env == 'dev' || env == 'test') {
      String top = topBorder;
      String url = formatContent('开始请求：url: ${options.uri.toString()}');
      String headers = formatContent('headers: ${options.headers.toString()}');
      String data ;
      try {
        data = formatContent('data: ${(options.data as FormData?)?.fields.join(',')}');
      } catch (e) {
        data = formatContent('data: ${options.data.toString()}');
      }
      String query = formatContent('query: ${options.queryParameters.toString()}');
      String bottom = bottomBorder;
      if (color != null) {
        top = color(top);
        url = color(url);
        headers = color(headers);
        data = color(data);
        query = color(query);
        bottom = color(bottom);
      }
      print(top);
      print(url);
      print(headers);
      print(data);
      print(query);
      print(bottom);
    }
  }

  /// 打印response
  void printResponse(Response response, AnsiColor? color) {
    if (env == 'dev' || env == 'test') {
      String top = topBorder;
      String url = formatContent('开始响应：url: ${response.requestOptions.uri.toString()}');
      String headers = formatContent('headers: ${response.requestOptions.headers.toString()}');
      String query = formatContent('query: ${response.requestOptions.queryParameters.toString()}');
      var data=response.requestOptions.data;
      String params = data is FormData?formatContent('body: ${data.fields.join(',')}'):data.toString();
      String res = formatContent('response: ${json.encode(response.data)}');
      String bottom = bottomBorder;
      if (color != null) {
        top = color(top);
        url = color(url);
        res = color(res);
        bottom = color(bottom);
      }
      developer.log(top);
      developer.log(response.requestOptions.method + ":" + url);
      developer.log(headers);
      developer.log(query);
      developer.log(params);
      // developer.log(res);
      developer.log(bottom);
    }
  }

  /// 打印error
  void printError(DioError err, AnsiColor? color) {
    if (env == 'dev' || env == 'test') {
      String top = topBorder;
      String url = formatContent('出错了：${err.requestOptions.method}->url: ${err.requestOptions.path}');
      String error = formatContent('error: ${err.toString()}');
      String res = formatContent('response: ${err.response?.toString() ?? ''}');
      String bottom = bottomBorder;
      if (color != null) {
        top = color(top);
        url = color(url);
        error = color(error);
        res = color(res);
        bottom = color(bottom);
      }
      print(top);
      print(url);
      print(error);
      print(res);
      print(bottom);
    }
  }

  /// 格式化超长的数据
  String formatContent(String content) {
    return '| $content';
//    if (content.length <= 50) return '| $content';
//    StringBuffer sb = StringBuffer();
//    int times = ((content.length + 50) / 50).ceil();
//    for (int i = 0; i < times; i++) {
//      final int begin = i * 50;
//      final int end = i == times ? content.length : (i + 1) * 50;
//      sb.write('| ');
//      sb.write(content.substring(begin, end));
//      if (i != times) sb.write('\n');
//    }
//    return sb.toString();
  }
}

/// This class handles colorizing of terminal output.
class AnsiColor {
  /// ANSI Control Sequence Introducer, signals the terminal for new settings.
  static const ansiEsc = '\x1B[';

  /// Reset all colors and options for current SGRs to terminal defaults.
  static const ansiDefault = '${ansiEsc}0m';

  final int? fg;
  final int? bg;
  final bool color;

  AnsiColor.none()
      : fg = null,
        bg = null,
        color = false;

  AnsiColor.fg(this.fg)
      : bg = null,
        color = true;

  AnsiColor.bg(this.bg)
      : fg = null,
        color = true;

  @override
  String toString() {
    if (fg != null) {
      return '${ansiEsc}38;5;${fg}m';
    } else if (bg != null) {
      return '${ansiEsc}48;5;${bg}m';
    } else {
      return '';
    }
  }

  String call(String msg) {
    if (color) {
      return '${this}$msg$ansiDefault';
    } else {
      return msg;
    }
  }

  AnsiColor toFg() => AnsiColor.fg(bg);

  AnsiColor toBg() => AnsiColor.bg(fg);

  /// Defaults the terminal's foreground color without altering the background.
  String get resetForeground => color ? '${ansiEsc}39m' : '';

  /// Defaults the terminal's background color without altering the foreground.
  String get resetBackground => color ? '${ansiEsc}49m' : '';

  static int grey(double level) => 232 + (level.clamp(0.0, 1.0) * 23).round();
}
