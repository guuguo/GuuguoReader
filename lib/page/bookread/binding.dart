import 'package:get/get.dart';
import 'package:read_info/page/explore/logic.dart';

import '../detailsms/logic.dart';
import 'logic.dart';

class ContentBinding extends Bindings {
  @override
  void dependencies() {
    var logic=Get.find<DetailLogic>();
    Get.lazyPut(() => ContentLogic(logic.source));
  }
}
