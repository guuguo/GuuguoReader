import 'package:get/get.dart';
import 'package:read_info/data/source_net_repository.dart';

import '../../bean/book_item_bean.dart';
import '../../bean/entity/source_entity.dart';

class ContentLogic extends GetxController {

  Rx<BookContentBean?> bookContent=Rx(null);
  late BookChapterBean bookToc;
  late BookDetailBean bookDetail;
  var refreshing = false.obs;
  BookChapterBean? getNextToc(){
    var index=bookDetail.tocs?.indexOf(bookToc);
    if(index==null||index==(bookDetail.tocs?.length??0)-1 ){
      return null;
    }
    return bookDetail.tocs![index+1];
  }
  late SourceNetRepository repository;
  SourceEntity source;
  ContentLogic(this.source) {
    repository=SourceNetRepository(source);
  }
  void init(BookDetailBean bean,BookChapterBean bookToc) async {
    this.bookDetail = bean;
    this.bookToc = bookToc;
    await loadContent();
  }

  BookChapterBean? getChapterByIndex(int index) {
    try {
      return bookDetail.tocs?.elementAt(index);
    } catch (e) {
      return null;
    }
  }

  int currentChapterIndex() {
    return bookDetail.tocs!.indexOf(bookToc);
  }
  loadContent() async {
    refreshing.value = true;
    update();
    var bean = await repository.queryBookContent(bookToc);
    bookContent.value = bean?.content;
    refreshing.value = false;
    update();
  }
}
