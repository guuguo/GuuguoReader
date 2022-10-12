import 'package:get/get.dart';
import 'package:read_info/global/constant.dart';
import 'package:read_info/data/net_repository.dart';
import 'package:read_info/route_config.dart';

import '../../bean/book_item_bean.dart';
import '../../bean/entity/source_entity.dart';

class ExploreLogic extends GetxController {

  var query = "";
  late var page;
  var loading = false;
  var refreshing = true.obs;
  var loadEnd = false.obs;
  SourceEntity source;
  late NetRepository repository;
  List<BookItemBean> books=[];
  ExploreLogic(this.source) {
    repository=NetRepository(source);
    init();
  }

  Future toDetailPage(BookItemBean item) async {
    return await Get.toNamed(RouteConfig.detail,
        arguments: {ARG_ITEM_BEAN: item});
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

  refreshList() async {
    page = source.from;
    refreshing.value = true;
    loadEnd.value = false;
    update();
    books.clear();
    books.addAll(await repository.exploreBookList(pageNum: page));
    refreshing.value = false;
    update();
  }

  Future<bool> loadMore() async {
    print("开始加载更多");
    if(loading) return false;
    loading = true;
    update();
    page++;
    var list = await repository.exploreBookList(pageNum: page);
    if (list.isEmpty) {
      loadEnd.value = true;
    }
    books.addAll(list);
    loading = false;
    update();
    return true;
  }
}
