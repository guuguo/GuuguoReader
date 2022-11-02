import 'dart:collection';

import 'package:get/get.dart';
import 'package:read_info/data/local_repository.dart';
import 'package:read_info/data/source_net_repository.dart';
import 'package:read_info/global/constant.dart';
import 'package:read_info/page/common/widget_common.dart';
import 'package:read_info/utils/developer.dart';
import 'package:read_info/utils/ext/list_ext.dart';

import '../../bean/book_item_bean.dart';
import '../../bean/entity/source_entity.dart';

class ContentLogic extends GetxController {
  late BookDetailBean bookDetail;
  late SourceNetRepository repository;
  var readChapterIndex = 0;
  late SourceEntity source;

  ContentLogic() {
    source=Get.arguments[ARG_ITEM_SOURCE_BEAN];
    repository = SourceNetRepository(source);
  }

  void init(BookDetailBean bean) async {
    this.bookDetail = bean;
    LocalRepository.saveBookIfNone(bean);
    readChapterIndex = bean.readChapterIndex;
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
  BookChapterBean? currentChapter() {
    return bookDetail.chapters?[bookDetail.readChapterIndex];
  }

  Future deleteChapter(int chapterIndex) async {
    final chapter = bookDetail.chapters?.getOrNull(chapterIndex);
    if (chapter != null) {
      await LocalRepository.deleteChapterContent(chapter.id);
      chapter.content = null;
    }
  }

  ///更新阅读进度
  void updateReadPage(int pageIndex, int chapterIndex) {
    debug("更新当前页面chapterIndex:${chapterIndex}  pageIndex:${pageIndex} chapterTotal:${bookDetail.totalChapterCount}");
    bookDetail.readPageIndex = pageIndex;
    bookDetail.readChapterIndex = chapterIndex;
    bookDetail.updateAt=DateTime.now().millisecondsSinceEpoch;
    readChapterIndex = chapterIndex;
    LocalRepository.updateBookReadProgress(bookDetail);
  }

  Future loadChapterContent(BookChapterBean? chapter) async {
    if (chapter == null) return;
    if (chapter.id != 0) {
      var saveChapter = await LocalRepository.queryBookContent(chapter.id);
      chapter.content = saveChapter;
    }
    if (!chapter.hasContent()) {
      var cancel;
      if(chapter.chapterIndex==bookDetail.readChapterIndex) {
        cancel= "正在加载章节内容中".showLoading();
      }
      await repository.queryBookContent(chapter);
      cancel?.call();

      debug("文章内容规则：${source.ruleContent}");
      // debug("加载文章内容：${chapter.content?.content.substring(0,min) ?? "没找到内容"}");
      LocalRepository.updateChapterContent(chapter);
    }
  }
  loadChapters() async {
    if (bookDetail == null)
      return;
    var chapters = await repository.queryBookTocs(bookDetail);
    bookDetail = bookDetail.copyWith(chapters:chapters,totalChapterCount:chapters?.length??0);
    LocalRepository.saveBook(bookDetail);
    update();
  }
}
