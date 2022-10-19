import 'package:get/get.dart';
import 'package:read_info/bean/book_item_bean.dart';
import 'package:read_info/config/route_config.dart';
import 'package:read_info/global/constant.dart';

import '../../data/local_repository.dart';
import 'state.dart';

class ReadHistoryLogic extends GetxController {
  final ReadHistoryState state = ReadHistoryState();
  ReadHistoryLogic(){
    getAllReadBooks();
  }
  getAllReadBooks()async{
    var books= await (await LocalRepository.database()).bookDao.findAllBooks();
    state.books=books;
    update();
  }

  Future toReadPage(BookDetailBean item) async {
    var routeRouteConfig = RouteConfig.bookcontent;
    var source = await LocalRepository.findSource(item.sourceUrl);
    var chapters = await LocalRepository.findBookChapters(item);
    if (chapters.isNotEmpty != true) {
      Get.snackbar("提示", "缓存失效，需要重新获取");
      return;
    }
    item.chapters = chapters;
    return await Get.toNamed(routeRouteConfig, arguments: {ARG_BOOK_DETAIL_BEAN: item, ARG_ITEM_SOURCE_BEAN: source});
  }
}
