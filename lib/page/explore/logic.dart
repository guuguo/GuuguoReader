import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:read_info/commmon/utils.dart';
import 'package:read_info/data/source_net_repository.dart';
import 'package:read_info/global/constant.dart';
import 'package:read_info/data/net_repository.dart';
import 'package:read_info/config/route_config.dart';

import '../../bean/book_item_bean.dart';
import '../../bean/entity/source_entity.dart';

class ExploreLogic extends GetxController {
  var query = "";
  late var page;
  var loading = false;
  var error = "".obs;
  var refreshing = true.obs;
  var loadEnd = false.obs;
  SourceEntity source;
  late SourceNetRepository repository;
  Rx<List<BookItemBean>> books = Rx([]);

  ExploreLogic(this.source) {
    repository = SourceNetRepository(source);
    init();
  }

  Future toDetailPage(BookItemBean item) async {

  }

  Future<void> init() async {
      await refreshList();
  }

  showError(String msg) {
    if (isClosed) return;
    showMessage(msg);
  }

  refreshList() async {
    error.value = "";
    page = source.from??1;
    refreshing.value = true;
    loadEnd.value = false;
    update();
    try {
      books.value = await repository.exploreBookList(pageNum: page);
    } on DioError catch (e) {
      error.value=e.message;
      // showError(e.message);
    }
    refreshing.value = false;
    update();
  }

  Future<bool> loadMore() async {
    print("开始加载更多");
    if (loading) return false;
    loading = true;
    update();
    page++;
    try {
      var list = await repository.exploreBookList(pageNum: page);
      if (list.isEmpty) {
        loadEnd.value = true;
      }
      books.value = [...books.value..addAll(list)];
    } on DioError catch (e) {
      error.value = e.message;
    }

    loading = false;
    update();
    return true;
  }
}
