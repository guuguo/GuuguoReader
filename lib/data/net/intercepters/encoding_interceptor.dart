import 'package:dio/dio.dart';
import 'package:enough_convert/enough_convert.dart';

class EncodingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (options.queryParameters.isEmpty) {
      super.onRequest(options, handler);
      return;
    }
    bool isGbk=false;
    if (options.contentType?.toLowerCase().contains(RegExp('gb'))==true) {
      isGbk=true;
    }else{
      isGbk=false;
    }
    final queryParams = _getQueryParams(options.queryParameters,isGbk);
    handler.next(
      options.copyWith(
        path: _getNormalizedUrl(options.path, queryParams),
        queryParameters: Map.from({}),
      ),
    );
  }

  String _getNormalizedUrl(String baseUrl, String queryParams) {
    if (baseUrl.contains("?")) {
      return baseUrl + "&$queryParams";
    } else {
      return baseUrl + "?$queryParams";
    }
  }

  String _getQueryParams(Map<String, dynamic> map,bool isGbk) {
    String result = "";
    map.forEach((key, value) {
      if(isGbk) {
        result += "$key=${Uri.encodeQueryComponent(value,encoding: gbk)}&";
      }
      else{
        result += "$key=${Uri.encodeComponent(value)}&";
      }
    });
    return result;
  }
}