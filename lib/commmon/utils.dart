import 'package:get/get.dart';

showMessage(String msg, {int duration = 2000}) {
  var cancel = Future.delayed(Duration(milliseconds: duration), () {
    Get.back();
  });
  Future dialogFuture = Get.defaultDialog(
      middleText: msg,
      title: "提示",
      textCancel: "关闭",
      onCancel: () {
        Get.back();
      }).then((d) {
    cancel.ignore();
  });
}

