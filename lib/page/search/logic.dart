import 'dart:convert';

import 'package:get/get.dart';
import 'package:read_info/config/route_config.dart';
import 'package:read_info/data/source_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../global/constant.dart';
import 'state.dart';

class SearchLogic extends GetxController {
  final SearchState state = SearchState();

  SearchLogic() {
    init();
  }

  init() async {
    final prefs = await SharedPreferences.getInstance();
    state.historys = json.decode(prefs.getString(sp_search_history) ?? "[]").map<String>((e) => e.toString()).toList();
    update();
  }

  saveHistory(String his) async {
    if (state.historys.contains(his)) {
      state.historys.remove(his);
      state.historys.insert(0, his);
    } else {
      state.historys.add(his);
    }
    final maxLength = 20;
    if (state.historys.length > maxLength) state.historys = state.historys.getRange(0, maxLength).toList();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(sp_search_history, json.encode(state.historys));
    update();
  }

  Future toSearchResultPage(String key) async {
    final souces = Get.arguments?[ARG_SOURCE_LIST] ?? await SourceManager.instance.ensureSources();
    await Get.offAndToNamed(RouteConfig.searchResult, arguments: {ARG_SEARCH_KEY: key, ARG_SOURCE_LIST: souces});
  }

}
