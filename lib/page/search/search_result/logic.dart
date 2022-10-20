import 'package:get/get.dart';
import 'package:read_info/global/constant.dart';

import '../../../data/source_manager.dart';
import 'state.dart';

class SearchResultLogic extends GetxController {
  final SearchResultState state = SearchResultState();

  late SourceManager manager=SourceManager();
  SearchResultLogic(){

    searchBook();
  }
  searchBook(){
    if(state.searchKey.isEmpty) return;
    state.loading=true;
    state.donnSourceCount=0;
    update();
    SourceManager.instance.searchFromSources(state.searchKey, (list, totalCount, doneCount) {
      state.books.addAll(list);
      state.donnSourceCount =doneCount;
      if(doneCount>=totalCount){
        state.loading=false;
      }
      update();
    });
  }
}
