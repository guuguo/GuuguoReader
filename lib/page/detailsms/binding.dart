import 'package:get/get.dart';
import 'package:read_info/page/explore/logic.dart';

import 'logic.dart';

class DetailBinding extends Bindings {
  @override
  void dependencies() {
    var mainLogic=Get.find<ExploreLogic>();
    Get.lazyPut(() => DetailLogic(mainLogic.source));
  }
}
