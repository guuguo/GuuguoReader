import 'package:get/get.dart';

import 'logic.dart';

class ContentBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ContentLogic());
  }
}
