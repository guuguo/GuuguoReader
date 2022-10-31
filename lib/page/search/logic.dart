import 'package:get/get.dart';
import 'package:read_info/config/route_config.dart';
import 'package:read_info/data/source_manager.dart';

import '../../global/constant.dart';
import 'state.dart';

class SearchLogic extends GetxController {
  final SearchState state = SearchState();

  SearchLogic() {}

  Future toSearchResultPage(String key) async {
    final souces = Get.arguments?[ARG_SOURCE_LIST] ?? await SourceManager.instance.ensureSources();
    await Get.offAndToNamed(RouteConfig.searchResult, arguments: {ARG_SEARCH_KEY: key, ARG_SOURCE_LIST: souces});
  }
}
