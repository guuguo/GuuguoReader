import 'dart:async';
import 'dart:collection';

import 'package:collection/collection.dart';
import 'package:get/get.dart';
import 'package:read_info/bean/book_item_bean.dart';
import 'package:read_info/bean/entity/source_entity.dart';
import 'package:read_info/data/source_net_repository.dart';
import 'package:read_info/global/constant.dart';
import 'package:read_info/utils/developer.dart';

import '../../../data/source_manager.dart';
import 'state.dart';

class SearchResultLogic extends GetxController {
  late SearchResultState novelState;
  late SearchResultState comicState;
  var currentIndex = 0;
  late SourceManager manager = SourceManager();
  List<SourceEntity> selectedSources = [];
  late List<String> tags = [];
  final novelStr="小说";
  final comicStr="漫画";

  SearchResultState getState(int index) {
    if (tags[index] == novelStr) {
      return novelState;
    }
    return comicState;
  }

  @override
  onInit() {
    super.onInit();
    final searchKey= Get.arguments[ARG_SEARCH_KEY];
    selectedSources= Get.arguments[ARG_SOURCE_LIST];
    novelState = SearchResultState(searchKey);
    comicState = SearchResultState(searchKey);
    if(selectedSources.any((element) => element.bookSourceType==source_type_novel)){
      tags.add(novelStr);;
    }
    if(selectedSources.any((element) => element.bookSourceType==source_type_comic)){
      tags.add(comicStr);;
    }

    updateIndex(0);
  }

  Future searchBook([bool isComic = false]) async {
    var state = isComic ? comicState : novelState;
    if (state.searchKey.isEmpty) return null;
    state.loading = true;
    state.donnSourceCount = 0;
    update();
    final loading = Completer();
    searchFromSources(state.searchKey, (list, totalCount, doneCount) {
      var result = combineAndSortListWithScore(state.searchKey, list, state.books);
      state.books = result;
      state.donnSourceCount = doneCount;
      state.totalSearchCount = totalCount;
      if (doneCount >= totalCount) {
        state.loading = false;
        loading.complete();
      }
      update();
    }, isComic: isComic);
    return loading.future;
  }
///////书源搜索功能
  Future searchFromSources(String searchKey, SearchCallBack callBack,{isComic=false}) async {
    List<SourceNetRepository> bookSourcesRep;
    if (isComic)
      bookSourcesRep = selectedSources.where((e) => e.bookSourceType == source_type_comic).map((e) => SourceNetRepository(e)).toList();
    else
      bookSourcesRep = selectedSources.where((e) => e.bookSourceType == source_type_novel).map((e) => SourceNetRepository(e)).toList();

    var sourceCount = bookSourcesRep.length;
    var okSourceCount = 0;
    var errorSourceCount = 0;
    if(bookSourcesRep.isEmpty) {
      callBack.call([],sourceCount,okSourceCount+errorSourceCount);
      return;
    }
    for (final book in bookSourcesRep) {
      book.searchBookList(searchKey).then((res) {
        okSourceCount++;
        callBack.call(res,sourceCount,okSourceCount+errorSourceCount);
      }).catchError((e) {
        debug(e);
        errorSourceCount++;
        callBack.call([],sourceCount,okSourceCount+errorSourceCount);
      });
    }
  }
  ///按照相似度评分，并按照相似度排序合并
  Map<String, List<BookItemBean>> combineAndSortListWithScore(String keyword, List<BookItemBean> books, Map<String, List<BookItemBean>> books2) {
    if (books.isEmpty) return books2;

    ///搜索计算相似度分值使用
    var searchScore = HashMap<String, int>();
    int calcScore(BookItemBean bean) {
      final lScore = searchScore[bean.name];
      if (lScore != null) return lScore;
      if (bean.name == keyword) {
        return 100;
      }
      if (bean.name?.contains(keyword) == true) {
        return 99;
      }

      var score = 0;
      for (var i = 0; i < keyword.length; i++) {
        if (bean.name?.contains(keyword[i]) == true) {
          score++;
        }
      }
      searchScore[bean.name ?? ""] = score;
      return score;
    }

    books.forEach((element) {
      final name = element.name ?? "";
      books2[name] = [...(books2[name] ?? []), element];
    });
    return LinkedHashMap.fromEntries(books2.entries.sorted((a, b) => calcScore(b.value.first).compareTo(calcScore(a.value.first))));
  }


  void updateIndex(int index) async {
    final state=getState(index);
    if (!state.loading && state.books.isEmpty) {
        await searchBook(tags[index] == comicStr);
    }

    currentIndex = index;
    update();
  }
}
