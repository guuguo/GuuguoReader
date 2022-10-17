import 'package:dio/dio.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'package:read_info/data/net/dio_helper.dart';
import 'package:read_info/data/rule/RuleUtil.dart';
import 'package:read_info/generated/json/base/json_convert_content.dart';

import '../bean/book_item_bean.dart';
import '../bean/entity/source_entity.dart';

const int pageLimited = 20;

class SourceNetRepository {
  SourceEntity source;

  SourceNetRepository(this.source);

  ///
  Future<List<BookItemBean>> exploreBookList(
      {String? title, pageNum = 1}) async {
    SourceExploreUrl? explore;
    if(title==null){
      explore=source.exploreUrl?.first;
    }else {
      explore =
          source.exploreUrl?.firstWhere((element) => element.title == title);
    }
    if (explore == null) return [];
    var res = await getDio()
        .get<String>(explore.url!.replaceAll('{{page}}', "${pageNum}"));
    var document = parse(res.data);
    //header.title@a@text
    var rule = source.ruleExplore;
    var list = document.documentElement?.parseRuleWithoutAttr(rule?.bookList);
    var bookList = list
        ?.map((e) => BookItemBean()
          ..name = e.parseRule(rule?.name)?.trim()
          ..intro = e.parseRule(rule?.intro)?.trim()
          ..author = e.parseRule(rule?.author)
          ..coverUrl = e.parseRule(rule?.coverUrl)
          ..bookUrl = e.parseRule(rule?.bookUrl))
        .toList();

    return bookList??[];
  }

  Dio getDio() => DioHelper.dio(source.bookSourceUrl ?? "");

  Future<BookDetailBean?> queryBookDetail(BookItemBean bean) async {
    var res = await getDio().get<dynamic>(bean.bookUrl ?? "");
    var element = parse(res.data).documentElement;
    if (element == null) return null;
    var rule = source.ruleBookInfo;
    var bookBean= BookDetailBean()
      ..name = element.parseRule(rule?.name)
      ..author = element.parseRule(rule?.author)
      ..coverUrl = element.parseRule(rule?.coverUrl)
      ..kind = element.parseRule(rule?.kind)?.trim()
      ..lastChapter = element.parseRule(rule?.lastChapter)
      ..intro = element.parseRule(rule?.intro)?.trim()
      ..tocUrl = element.parseRule(rule?.tocUrl);
    print("打印 tocUrl");
    print(bookBean.tocUrl);
    return bookBean;
  }
  Future<List<BookChapterBean>?> queryBookTocs(BookDetailBean bean) async {
    var res = await getDio().get<dynamic>(bean.tocUrl ?? "");
    var element = parse(res.data).documentElement;
    if (element == null) return null;
    var rule = source.ruleToc;
    var list = element.parseRuleWithoutAttr(rule?.chapterList);
    var resList=list.map((e) => BookChapterBean()
      ..chapterName = e.parseRule(rule?.chapterName)?.trim()
      ..chapterUrl = e.parseRule(rule?.chapterUrl)).toList();

    return resList;
  }

  Future<BookChapterBean?> queryBookContent(BookChapterBean bean) async {
    var res = await getDio().get<dynamic>(bean.chapterUrl ?? "");
    var element = parse(res.data).documentElement;
    if (element == null) return null;
    var rule = source.ruleContent;
    var originContent=element.parseRule("${rule?.content}")
        ?.trim();
    var result=originContent;
    rule?.replaceRegex?.split('&&').forEach((element) {
      var replaces =
          element.split('##').where((element) => element.isNotEmpty).toList();
      var reg = replaces[0];
      var replace = "";
      if (replaces.length == 2) {
        replace = replaces[1];
      }
      result = result?.replaceAll(RegExp(reg), replace);
    });

    var resBean = BookContentBean()
      ..content = dealHtmlContentResult(result);
    bean.content = resBean;
    return bean;
  }
  String? dealHtmlContentResult(String? html){
    if(html==null) return null;
    var result=StringBuffer();
    var lastStart=0;
    var originHtml=html;
    RegExp(r"&nbsp;").allMatches(originHtml).forEach((match){
      result.write(originHtml.substring(lastStart,match.start));
      result.write(' ');
      lastStart=match.end;
    });
    result.write(originHtml.substring(lastStart));

    lastStart=0;
    originHtml=result.toString();
    result.clear();

    RegExp(r"<.*?>").allMatches(originHtml).forEach((match) {
      result.write(originHtml.substring(lastStart, match.start));
      if (match[0]?.contains(RegExp('br')) == true ||
          match[0]?.contains(RegExp('p')) == true) {
        result.write('\n');
      }
      lastStart = match.end;
    });
    result.write(originHtml.substring(lastStart));

    return result.toString();
  }
}
