import 'dart:convert';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:dio/dio.dart';
import 'package:enough_convert/enough_convert.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'package:read_info/bean/entity/source_header_entity.dart';
import 'package:read_info/data/net/dio_helper.dart';
import 'package:read_info/data/rule/RuleUtil.dart';
import 'package:read_info/data/rule/app_helper.dart';
import 'package:read_info/generated/json/base/json_convert_content.dart';
import 'package:uuid/uuid.dart';

import '../bean/book_item_bean.dart';
import '../bean/entity/source_entity.dart';

const int pageLimited = 20;

class SourceNetRepository {
  SourceEntity source;

  SourceNetRepository(this.source);

  ///发现页
  Future<List<BookItemBean>> exploreBookList({String? title, pageNum = 1}) async {
    SourceExploreUrl? explore;
    explore = getSourceExplore(title);
    if (explore == null) return [];
    var res = await getDio().get<String>(explore.url!.replaceAll('{{page}}', "${pageNum}"));
    var document = parse(res.data);
    //header.title@a@text
    var rule = source.ruleExplore;
    var list = document.documentElement?.parseRuleWithoutAttr(rule?.bookList);
    var bookList = list
        ?.map((e) => BookItemBean.FormSource(source)
          ..name = e.parseRule(rule?.name)?.trim()
          ..intro = e.parseRule(rule?.intro)?.trim()
          ..author = e.parseRule(rule?.author)
          ..lastChapter = e.parseRule(rule?.lastChapter)
          ..coverUrl = urlFix(e.parseRule(rule?.coverUrl, true), source.bookSourceUrl!)
          ..bookUrl = e.parseRule(rule?.bookUrl))
        .toList();

    return bookList ?? [];
  }

  SourceExploreUrl? getSourceExplore([String? title=null]) {
    SourceExploreUrl? explore;
    if (title == null) {
      explore = source.exploreUrl?.first;
    } else {
      explore = source.exploreUrl?.firstWhere((element) => element.title == title);
    }
    return explore;
  }

  Dio? _dio;

  Dio getDio() => _dio != null
      ? _dio!
      : DioHelper.dio(source.bookSourceUrl ?? "", (dio) {
          var headerStr = source.header;
          dio.interceptors.add(new InterceptorsWrapper(onRequest: (o, h) {
            o.responseDecoder = (res, opt, resbody) {
              if (resbody.headers['content-type']?.first.toLowerCase().contains(RegExp('gb')) == true) {
                return gbk.decode(res);
              } else {
                return utf8.decode(res);
              }
            };
            if (headerStr?.isNotEmpty != true) return;
            o.headers.addAll(json.decode(headerStr!));
            h.next(o);
          }));
        });

  ///发现页
  Future<List<BookItemBean>> searchBookList(String? searchKey) async {
    if (searchKey?.isNotEmpty != true) return [];
    String? searchUrl = source.searchUrl;
    if (searchUrl?.isNotEmpty != true) return [];

    final index = searchUrl!.indexOf(',');

    var method = "get";
    var charset = "utf-8";
    String? contentType;;
    dynamic body;
    searchUrl = searchUrl.replaceAll(RegExp(r"{{key}}"), searchKey ?? "");

    if (index >= 0) {
      final methodJson = json.decode(searchUrl.substring(index + 1));
      searchUrl = searchUrl.substring(0, index);
      method = methodJson['method'] ?? "get";
      body = methodJson['body'] ?? "";
      charset = methodJson['charset'] ?? "";
      contentType = methodJson['contentType'];
      if (body is Map)
        contentType = contentType ?? Headers.jsonContentType;
      else
        contentType = contentType ?? Headers.formUrlEncodedContentType;
    }

    if (charset.isNotEmpty) {
      contentType = contentType?.replaceAll(RegExp(r"utf-8"), charset);
    }

    Response<String?> res = await getDio().request<String>(
      searchUrl,
      data: body,
      queryParameters: method == "get"?body:null,
      options: Options(
          method: method,
          contentType: contentType,
          requestEncoder: (req, option) {
            if (option.contentType?.toLowerCase().contains(RegExp('gb'))==true) {
              return gbk.encode(req);
            } else {
              return utf8.encode(req);
            }
          },
          ),
    );

    var document = parse(res.data);
    //header.title@a@text
    var rule = source.ruleSearch;
    var list = document.documentElement?.parseRuleWithoutAttr(rule?.bookList);
    var bookList = list
        ?.map((e) => BookItemBean.FormSource(source)
          ..name = e.parseRule(rule?.name)?.trim()
          ..intro = e.parseRule(rule?.intro)?.trim()
      ..author = e.parseRule(rule?.author)
      ..lastChapter = e.parseRule(rule?.lastChapter)
      ..coverUrl = urlFix(e.parseRule(rule?.coverUrl, true), source.bookSourceUrl!)
      ..bookUrl = e.parseRule(rule?.bookUrl))
        .toList();

    return bookList ?? [];
  }

  Future<BookDetailBean?> queryBookDetail(BookItemBean bean) async {
    var res = await getDio().get<dynamic>(bean.bookUrl ?? "");
    var element = parse(res.data).documentElement;
    if (element == null) return null;
    var rule = source.ruleBookInfo;
    var bookBean = BookDetailBean(id:Uuid().v1())
      ..name = element.parseRule(rule?.name) ?? bean.name
      ..author = element.parseRule(rule?.author) ?? bean.author
      ..coverUrl = urlFix(element.parseRule(rule?.coverUrl, true) ?? bean.coverUrl, source.bookSourceUrl!)
      ..kind = element.parseRule(rule?.kind)?.trim()
      ..lastChapter = element.parseRule(rule?.lastChapter)
      ..intro = element.parseRule(rule?.intro)?.trim()
      ..tocUrl = checkUrlRule(bean.bookUrl!, rule?.tocUrl) ?? element.parseRule(rule?.tocUrl) ?? bean.bookUrl;
    if (bookBean.tocUrl == bean.bookUrl) {
      bookBean.chapters = getChapters(element,bookBean);
    }
    return bookBean;
  }

  Future<List<BookChapterBean>?> queryBookTocs(BookDetailBean bean) async {
    var res = await getDio().get<dynamic>(bean.tocUrl ?? "");
    var element = parse(res.data).documentElement;
    if (element == null) return null;
    List<BookChapterBean> resList = getChapters(element,bean);

    return resList;
  }

  List<BookChapterBean> getChapters(Element element,BookDetailBean bookBean) {
    var rule = source.ruleToc;
    var list = element.parseRuleWithoutAttr(rule?.chapterList);
    var resList = list
        .mapIndexed((i,e) => BookChapterBean(id: Uuid().v1(),bookId: bookBean.id,chapterIndex: i)
          ..chapterName = e.parseRule(rule?.chapterName)?.trim()
          ..chapterUrl = e.parseRule(rule?.chapterUrl))
        .toList();
    return resList;
  }

  Future<BookChapterBean?> queryBookContent(BookChapterBean bean) async {
    var result = await queryBookContentByUrl(bean.chapterUrl, source.ruleContent);
    if (result.isNotEmpty) bean.content = ChapterContent.FromChapter(bean, result);
    return bean;
  }

  Future<String> queryBookContentByUrl(String? url, SourceRuleContent? rule) async {
    if (url?.isNotEmpty != true) return "";
    var res = await getDio().get<dynamic>(url ?? "");
    var element = parse(res.data).documentElement;
    if (element == null) return "";

    var originContent = element.parseRule("${rule?.content}")?.trim();
    var result = originContent;
    var nextUrl = element.parseRule("${rule?.nextContentUrl}")?.trim();

    rule?.replaceRegex?.split('&&').forEach((element) {
      var replaces = element.split('##').where((element) => element.isNotEmpty).toList();
      var reg = replaces[0];
      var replace = "";
      if (replaces.length == 2) {
        replace = replaces[1];
      }
      result = result?.replaceAll(RegExp(reg), replace);
    });

    if (nextUrl?.isNotEmpty == true && result?.isNotEmpty == true) {
      result =(result ?? "") + await queryBookContentByUrl(nextUrl, rule);
    }

    return result ?? "";
  }

  String? dealHtmlContentResult(String? html) {
    if (html == null) return null;
    var result = StringBuffer();
    var lastStart = 0;
    var originHtml = html;
    RegExp(r"&nbsp;").allMatches(originHtml).forEach((match) {
      result.write(originHtml.substring(lastStart, match.start));
      result.write(' ');
      lastStart = match.end;
    });
    result.write(originHtml.substring(lastStart));

    lastStart = 0;
    originHtml = result.toString();
    result.clear();

    RegExp(r"<.*?>").allMatches(originHtml).forEach((match) {
      result.write(originHtml.substring(lastStart, match.start));
      if (match[0]?.contains(RegExp('br')) == true || match[0]?.contains(RegExp('p')) == true) {
        result.write('\n');
      }
      lastStart = match.end;
    });
    result.write(originHtml.substring(lastStart));

    return result.toString();
  }
}
