import 'package:collection/collection.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:read_info/commmon/utils.dart';
import 'package:read_info/data/source_net_repository.dart';
import 'package:read_info/global/constant.dart';
import 'package:read_info/data/net_repository.dart';
import 'package:read_info/config/route_config.dart';
import 'package:read_info/page/explore/state.dart';
import 'package:read_info/page/readhistory/state.dart';
import 'package:read_info/utils/developer.dart';

import '../../bean/book_item_bean.dart';
import '../../bean/entity/source_entity.dart';

class ExploreLogic extends GetxController {
  var query = "";

  var tabIndex = ValueNotifier(0);
  List<SourceExploreUrl> exploreTabs=[];
  SourceEntity source;
  late SourceNetRepository repository;
  Map<int,ExploreState> states={};

  ExploreLogic(this.source) {
    exploreTabs = source.exploreUrls ?? [];
    repository = SourceNetRepository(source);

    exploreTabs.forEachIndexed((i, e) {
      states[i] = ExploreState();
    });
    tabIndex.addListener(() {
      final state = states[tabIndex.value]!;
      if (state.books.isNotEmpty) {
        return;
      }
      refreshList(tabIndex.value);
    });
    init();
  }

  Future toDetailPage(BookItemBean item) async {
    var routeRouteConfig = RouteConfig.detailbook;
    if (source.bookSourceType == source_type_sms) {
      routeRouteConfig = RouteConfig.detailsms;
    }
    debug("跳转到详情页" + item.toString());
    return await Get.toNamed(routeRouteConfig, arguments: {ARG_BOOK_ITEM_BEAN: item, ARG_ITEM_SOURCE_BEAN: source});
  }

  Future<void> init() async {
    await refreshList(0);
  }

  showError(String msg) {
    if (isClosed) return;
    showMessage(msg);
  }

  refreshList(int index) async {
    final state=states[index]!;
    state.error = "";
    state.page = source.from ?? 1;
    state.refreshing = true;
    state.loadEnd = false;
    update();

    try {
      state.books = await repository.exploreBookList(explore:exploreTabs[index],pageNum: state.page);
    } catch (e) {
      debug(e);
      if (e is DioError)
        state.error = e.message;
      else
        state.error = e.toString();
    }

    ///只有一页
    if (repository.getSourceExplore()?.url?.contains("{{page}}") != true) {
      state.loadEnd = true;
    }
    state.refreshing = false;
    update();
  }

  Future<bool> loadMore(int index) async {
    print("开始加载更多");
    final state=states[index]!;
    if (state.loading) return false;
    state.loading = true;
    update();
    state.page++;
    final explore=exploreTabs[index];
    try {
      var list = await repository.exploreBookList(explore:explore,pageNum: state.page);
      if (list.isEmpty) {
        state.loadEnd = true;
      }
      state.books = [...state.books, ...list];
    } on DioError catch (e) {
      state.error = e.message;
    }

    state.loading = false;
    update();
    return true;
  }

  void updateIndex(int index) {
    tabIndex.value = index;
  }
}
