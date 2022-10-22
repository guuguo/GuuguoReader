import 'package:read_info/bean/book_item_bean.dart';

class ExploreState {
  late int page;
  var loading = false;
  var error = "";
  var refreshing = true;
  var loadEnd = false;

  List<BookItemBean> books=[];
  ReadHistoryState() {
  }
}
