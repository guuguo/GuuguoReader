import 'package:get/get.dart';
import 'package:read_info/data/local_repository.dart';
import 'package:read_info/data/source_net_repository.dart';
import 'package:read_info/utils/developer.dart';

import '../../bean/book_item_bean.dart';
import '../../bean/entity/source_entity.dart';

class ContentLogic extends GetxController {

  late BookDetailBean bookDetail;
  late SourceNetRepository repository;
  var readChapterIndex=0.obs;
  SourceEntity source;
  ContentLogic(this.source) {
    repository=SourceNetRepository(source);
  }
  void init(BookDetailBean bean) async {
    this.bookDetail = bean;
    bean.sourceUrl=source.bookSourceUrl;
    LocalRepository.saveBookIfNone(bean);
    readChapterIndex.value=bean.readChapterIndex;
    // await loadContent();
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
    debug("更新当前页面chapterIndex:${chapterIndex}  pageIndex:${pageIndex}");
    bookDetail.readPageIndex = pageIndex;
    bookDetail.readChapterIndex = chapterIndex;
    readChapterIndex.value=chapterIndex;
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
      debug("文章内容规则：${source.ruleContent}");
      debug("加载文章内容：${chapter.content?.content}");
      LocalRepository.updateChapterContent(chapter);
    }
  }
}
