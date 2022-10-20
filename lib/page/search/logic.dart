import 'package:get/get.dart';
import 'package:read_info/config/route_config.dart';

import '../../global/constant.dart';
import 'state.dart';

class SearchLogic extends GetxController {
  final SearchState state = SearchState();
  Future toSearchResultPage(String key) async {
    await Get.offAndToNamed(RouteConfig.searchResult,arguments: {ARG_SEARCH_KEY:key});
  }
}
