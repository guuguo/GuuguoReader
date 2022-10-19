import 'package:get/get.dart';
import 'package:read_info/config/route_config.dart';
import 'package:read_info/data/net_repository.dart';
import 'package:read_info/data/source_net_repository.dart';

import '../../bean/book_item_bean.dart';
import '../../bean/entity/source_entity.dart';
import '../../data/local_repository.dart';
import '../../global/constant.dart';

class DetailLogic extends GetxController {

  Rx<BookDetailBean?> detail=Rx(null);
  late BookItemBean item;
  var refreshing = false.obs;

  late SourceNetRepository repository;
  SourceEntity source;
  DetailLogic(this.source) {
    repository=SourceNetRepository(source);
  }
  void init(BookItemBean bean) async {
    this.item = bean;
    await loadMailDetail();
  }

  Future toBookContentPage(BookChapterBean toc) async {
    var routeRouteConfig = RouteConfig.bookcontent;
    detail.value?.readChapterIndex=detail.value!.chapters!.indexOf(toc);
    return await Get.toNamed(routeRouteConfig,
        arguments: { ARG_BOOK_DETAIL_BEAN: detail.value,ARG_ITEM_SOURCE_BEAN: source});
  }

  loadMailDetail() async {
    refreshing.value = true;
    update();
    var bean = await repository.queryBookDetail(item);
    detail.value = bean;
    refreshing.value = false;
    update();
    loadTocs();
  }
  loadTocs() async {
    if (detail.value == null)
      return;
    var chapters = await repository.queryBookTocs(detail.value!);
    detail.value = detail.value!.copyWith(chapters:chapters,totalChapterCount:chapters?.length??0 );
    update();
  }
}
