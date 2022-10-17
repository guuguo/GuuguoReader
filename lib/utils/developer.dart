import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;

///是否在生产环境中
bool inProduction = const bool.fromEnvironment("dart.vm.product");

debug(Object? msg,
    {String tag = '自由',
    Object? error,
    StackTrace? stackTrace,
    Zone zone = Zone.root,
    jsonFormat = false}) {
  if (!inProduction) {
    if (msg is Error && stackTrace == null) {
      stackTrace = msg.stackTrace;
    }
    String? message;
    if (jsonFormat) {
      message = _convertObject(msg);
    } else {
      message = msg?.toString();
    }
    developer.log(message??"打印数据为空了",
        name: tag, level: 0, zone: zone, error: error, stackTrace: stackTrace);
  }
}

String _convertObject(Object? message) {
  String result;
  try {
    result = JsonEncoder.withIndent(' ').convert(message);
  } catch (e) {
    result = message.toString();
  }
  return result;
}
