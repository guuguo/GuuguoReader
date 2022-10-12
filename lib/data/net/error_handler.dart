import 'package:dio/dio.dart';

class ErrorHandler extends InterceptorsWrapper {
  final Dio dio;

  ErrorHandler(this.dio);

  @override
  onResponse(
    Response response,
    ResponseInterceptorHandler handler,
  ) async {
    if (response.data["errCode"] != null) {
      handler.reject(DioError(
          error: response.data["errMessage"],
          requestOptions: response.requestOptions,
          response: response));
    } else {
      handler.next(response);
    }
  }
}
