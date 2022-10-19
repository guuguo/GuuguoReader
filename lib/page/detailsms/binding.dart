import 'package:get/get.dart';
import 'package:read_info/bean/entity/source_entity.dart';
import 'package:read_info/global/constant.dart';
import 'package:read_info/page/explore/logic.dart';

import 'logic.dart';

class DetailBinding extends Bindings {
  @override
  void dependencies() {
    SourceEntity sourceBean=Get.arguments[ARG_ITEM_SOURCE_BEAN];
    Get.lazyPut(() => DetailLogic(sourceBean));
  }
}
