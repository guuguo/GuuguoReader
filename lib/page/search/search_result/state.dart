
import 'package:read_info/bean/book_item_bean.dart';

class SearchResultState {
  Map<String,List<BookItemBean>> books= {};
  int donnSourceCount=0;
  int totalSearchCount=0;
  bool loading=false;
  late String searchKey;

  SearchResultState(this.searchKey);
}
