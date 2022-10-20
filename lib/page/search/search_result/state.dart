import 'package:get/get.dart';
import 'package:read_info/bean/book_item_bean.dart';
import 'package:read_info/bean/entity/source_entity.dart';
import 'package:read_info/global/constant.dart';

class SearchResultState {
  List<BookItemBean> books=[];
  int donnSourceCount=0;
  bool loading=false;
  late String searchKey;

  SearchResultState() {
    searchKey = Get.arguments[ARG_SEARCH_KEY];

  }
}
