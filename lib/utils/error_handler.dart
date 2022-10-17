typedef InovkeIt<R> =R Function();
typedef OnFail =Result Function(dynamic e);

class Result<T> {
  T? data;
  dynamic error;
  OnFail? failCallback;
  get()=>data;
  success(T data){
    this.data=data;
  }
  onFail(OnFail onFail){
    this.failCallback = onFail;
  }
}

Future<Result> runCatching<R>(InovkeIt<R> block) async {
  var result = Result();
  try {
      result.success(await block());
  } catch (e) {
    result.failCallback?.call(e);
  }
  return result;
}