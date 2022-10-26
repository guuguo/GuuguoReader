import 'package:get/get.dart';

extension LoadingExt on String {
  SnackbarController showLoading() {
    return Get.snackbar("提示", this, showProgressIndicator: true, duration: Duration(seconds: 100));
  }
}