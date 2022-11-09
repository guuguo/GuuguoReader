import 'dart:collection';

import 'package:get/get.dart';
import 'package:read_info/config/route_config.dart';
import 'package:read_info/data/net_repository.dart';
import 'package:read_info/data/source_manager.dart';
import 'package:read_info/data/source_net_repository.dart';

import '../../bean/book_item_bean.dart';
import '../../bean/entity/source_entity.dart';
import '../../data/local_repository.dart';
import '../../global/constant.dart';

class DetailLogic extends GetxController {
  Rx<BookDetailBean?> detail = Rx(null);
  late List<BookItemBean> items;
  late BookItemBean item;
  var refreshing = false.obs;
  var refreshTocs = false.obs;

  late SourceNetRepository repository;
  SourceEntity source;

  DetailLogic(this.source) {
    repository = SourceNetRepository(source);
  }

  void init(List<BookItemBean> bean) async {
    this.items = bean;
    this.item = bean.first;
    await loadDetail();
  }
  ///从详情中初始化
  Future initFromDetail(BookDetailBean bean,BookItemBean item) async {
    this.items = bean.searchResult.toList();
    this.item = item;
    this.detail.value=bean;
    await loadDetail(true);
  }

  Future toBookContentPage(BookChapterBean toc) async {
    var routeRouteConfig = RouteConfig.bookcontent;
    detail.value?.readChapterIndex = detail.value!.chapters!.indexOf(toc);
    return await Get.toNamed(routeRouteConfig, arguments: {ARG_BOOK_DETAIL_BEAN: detail.value, ARG_ITEM_SOURCE_BEAN: source});
  }

  loadDetail([bool forceNet=false]) async {
    refreshing.value = true;
    BookDetailBean? bookDetail=detail.value;
    detail.value=null;
    update();
    if (!forceNet) {
      bookDetail = await LocalRepository.queryBookDetail(item);
      if (bookDetail != null) {
        detail.value = bookDetail;
        refreshing.value = false;
        update();
      }
    }
    var bean = await repository.queryBookDetail(item);

    ///更新缓存的内容
    if (bookDetail != null) {
      bean?.id = bookDetail.id;
    }
    bean?.searchResult = ((bookDetail?.searchResult ?? HashSet())..addAll(items));
    bean?.readChapterIndex = bookDetail?.readChapterIndex??0;

    detail.value = bean;
    refreshing.value = false;
    update();
    if (bean?.chapters?.isNotEmpty != true) await loadTocs();
  }

  loadTocs() async {
    if (detail.value == null) return;
    refreshTocs.value=true;
    var chapters = await repository.queryBookTocs(detail.value!);
    refreshTocs.value=false;
    detail.value = detail.value!.copyWith(chapters: chapters, totalChapterCount: chapters?.length ?? 0);
    update();
  }

  void changeSource(BookItemBean? value) {
    if (value?.source == null) return;
    if (value!.source == source) return;
    detail.value?.sourceUrl = value.source?.bookSourceUrl;
    source = value.source!;
    repository = SourceNetRepository(source);
    item=value;
    loadDetail(true);
  }

  void onRuleConfirm(SourceRuleBookInfo? rule) {
    if (source.ruleBookInfo == rule) {
      return;
    }
    source.ruleBookInfo = rule;
    SourceManager.instance.insertOrUpdateSources([source]);
    loadDetail();
  }
}
