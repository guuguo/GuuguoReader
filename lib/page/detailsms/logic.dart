import 'package:get/get.dart';
import 'package:read_info/config/route_config.dart';
import 'package:read_info/data/net_repository.dart';
import 'package:read_info/data/source_net_repository.dart';

import '../../bean/book_item_bean.dart';
import '../../bean/entity/source_entity.dart';
import '../../data/local_repository.dart';
import '../../global/constant.dart';
import '../search/search_result/logic.dart';

class DetailLogic extends GetxController {

  Rx<BookDetailBean?> detail=Rx(null);
  late List<BookItemBean> items;
  late BookItemBean item;
  var refreshing = false.obs;

  late SourceNetRepository repository;
  SourceEntity source;
  DetailLogic(this.source) {
    repository=SourceNetRepository(source);
  }
  void init(List<BookItemBean> bean) async {
    this.items = bean;
    this.item=bean.first;
    await loadDetail();
  }

  Future toBookContentPage(BookChapterBean toc) async {
    var routeRouteConfig = RouteConfig.bookcontent;
    detail.value?.readChapterIndex=detail.value!.chapters!.indexOf(toc);
    return await Get.toNamed(routeRouteConfig,
        arguments: { ARG_BOOK_DETAIL_BEAN: detail.value,ARG_ITEM_SOURCE_BEAN: source});
  }

  loadDetail() async {
    refreshing.value = true;
    update();
    final bookDetail=await LocalRepository.queryBookDetail(item);
    if (bookDetail != null) {
      detail.value = bookDetail;
      refreshing.value = false;
      update();
    }
    var bean = await repository.queryBookDetail(item);
    ///更新缓存的内容
    if(bookDetail!=null) {
      bean?.id = bookDetail.id;
      bean?.searchResult = [...(bookDetail.searchResult), ...items];
    }

    detail.value = bean;
    refreshing.value = false;
    update();
    if (bean?.chapters?.isNotEmpty != true) loadTocs();
  }

  loadTocs() async {
    if (detail.value == null)
      return;
    var chapters = await repository.queryBookTocs(detail.value!);
    detail.value = detail.value!.copyWith(chapters:chapters,totalChapterCount:chapters?.length??0 );
    update();
  }
}
