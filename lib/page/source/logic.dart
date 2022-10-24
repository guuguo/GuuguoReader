import 'package:get/get.dart';
import 'package:read_info/data/local_repository.dart';
import 'package:read_info/data/source_manager.dart';
import 'package:read_info/global/constant.dart';
import 'package:read_info/data/net_repository.dart';
import 'package:read_info/config/route_config.dart';

import '../../bean/entity/source_entity.dart';

class SourceLogic extends GetxController {

  var query = "";
  var refreshing = true.obs;
  Rx<List<SourceEntity>> sources=SourceManager.instance.sourcesRx;
  SourceLogic() {
    init();
  }

  Future toSourcePage(SourceEntity item) async {
    return await Get.toNamed(RouteConfig.explore,
        arguments: {ARG_ITEM_SOURCE_BEAN: item});
  }

  Future<void> init() async {
    try {
      await refreshList();
    } catch (e) {
      if(isClosed) return;
      Get.defaultDialog(
          middleText: e.toString(),
          textCancel: "关闭",
          onCancel: () {
            Get.back();
          });
    }
  }
  Future<void> deleteSource(SourceEntity source) async {
    await SourceManager.instance.deleteSource(source);
    update();
  }

  importSource({String url = defaultSourceUrl})async{
    try {
      var sourcesResult = await NetRepository.getSources(url);
      await SourceManager.instance.insertOrUpdateSources(sourcesResult);
      update();
    }catch (e) {
      print(e);
    }
  }
  refreshList() async {
    refreshing.value = true;
    update();
    sources.value=await SourceManager.instance.ensureSources();
    refreshing.value = false;
    update();
  }

}
