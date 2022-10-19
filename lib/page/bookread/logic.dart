import 'package:get/get.dart';
import 'package:read_info/data/local_repository.dart';
import 'package:read_info/data/source_net_repository.dart';

import '../../bean/book_item_bean.dart';
import '../../bean/entity/source_entity.dart';

class ContentLogic extends GetxController {

  Rx<String?> bookContent=Rx("");
  late BookDetailBean bookDetail;
  var refreshing = false.obs;

  late SourceNetRepository repository;
  SourceEntity source;
  ContentLogic(this.source) {
    repository=SourceNetRepository(source);
  }
  void init(BookDetailBean bean) async {
    this.bookDetail = bean;
    bean.sourceUrl=source.bookSourceUrl;
    LocalRepository.saveBookIfNone(bean);
    await loadContent();
  }

  BookChapterBean? getChapterByIndex(int index) {
    try {
      return bookDetail.chapters?.elementAt(index);
    } catch (e) {
      return null;
    }
  }

  int currentChapterIndex() {
    return bookDetail.readChapterIndex;
  }

  ///更新阅读进度
  void updateReadPage(int pageIndex, int chapterIndex) {
    bookDetail.readPageIndex = pageIndex;
    bookDetail.readChapterIndex = chapterIndex;
    LocalRepository.updateBook(bookDetail);
  }

  Future loadChapterContent(BookChapterBean? chapter) async {
    if (chapter == null) return;
    if (chapter.id != 0) {
      var saveChapter = await LocalRepository.queryBookContent(chapter.id);
      chapter.content = saveChapter;
    }
    if (!chapter.hasContent()) {
      await repository.queryBookContent(chapter);
      LocalRepository.updateChapterContent(chapter);
    }
  }

  loadContent() async {
    refreshing.value = true;
    update();
    var chapter=bookDetail.chapters![bookDetail.readChapterIndex];
    var bean = await repository.queryBookContent(chapter);
    bookContent.value = bean?.content?.content;
    refreshing.value = false;
    update();
  }
}
