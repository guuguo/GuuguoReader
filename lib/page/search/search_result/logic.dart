import 'dart:collection';

import 'package:collection/collection.dart';
import 'package:get/get.dart';
import 'package:read_info/bean/book_item_bean.dart';
import 'package:read_info/global/constant.dart';

import '../../../data/source_manager.dart';
import 'state.dart';

class SearchResultLogic extends GetxController {
  late SearchResultState state;

  late SourceManager manager=SourceManager();
  @override
  onInit() {
    super.onInit();
    final searchKey = Get.arguments[ARG_SEARCH_KEY];
    state = SearchResultState(searchKey);
    searchBook();
  }
  void searchBook(){
    if(state.searchKey.isEmpty) return;
    state.loading=true;
    state.donnSourceCount=0;
    update();
    SourceManager.instance.searchFromSources(state.searchKey, (list, totalCount, doneCount) {
      var result=combineAndSortListWithScore(state.searchKey,list,state.books);
      state.books=result;
      state.donnSourceCount =doneCount;
      if(doneCount>=totalCount){
        state.loading=false;
      }
      update();
    });
  }
  ///按照相似度评分，并按照相似度排序合并
  Map<String,List<BookItemBean>> combineAndSortListWithScore(String keyword,List<BookItemBean> books,Map<String,List<BookItemBean>> books2){
    var i=0;var j=0;
    List<BookItemBean> result=[];
    ///搜索计算相似度分值使用
    var searchScore=HashMap<String,int>();
    int calcScore(BookItemBean bean) {
      final lScore = searchScore[bean.name];
      if (lScore != null) return lScore;
      if (bean.name == keyword) {
        return 100;
      }
      if(bean.name?.contains(keyword)==true){
        return 99;
      }

      var score=0;
      for (var i=0;i<keyword.length;i++) {
        if(bean.name?.contains(keyword[i])==true){
          score++;
        }
      }
      searchScore[bean.name??""]=score;
      return score;
    }
    books.forEach((element) {
      final name=element.name??"";
      books2[name]=[...(books2[name]??[]),element];
    });
    return LinkedHashMap.fromEntries(books2.entries.sorted((a,b)=>calcScore(b.value.first).compareTo(calcScore(a.value.first))));
  }
}
