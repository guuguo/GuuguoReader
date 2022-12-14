import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:dio/dio.dart';
import 'package:enough_convert/enough_convert.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'package:read_info/data/net/dio_helper.dart';
import 'package:read_info/data/rule/RuleUtil.dart';
import 'package:read_info/data/rule/app_helper.dart';
import 'package:read_info/data/rule/novel_string_deal.dart';
import 'package:read_info/global/constant.dart';
import 'package:read_info/utils/developer.dart';
import 'package:uuid/uuid.dart';

import '../bean/book_item_bean.dart';
import '../bean/entity/source_entity.dart';

const int pageLimited = 20;

class SourceNetRepository {
  SourceEntity source;
  var _disposed = false;

  dispose() {
    _disposed = true;
  }

  SourceNetRepository(this.source);

  ///发现页
  Future<List<BookItemBean>> exploreBookList({required SourceExploreUrl explore, pageNum = 1}) async {
    final urlConfig = UrlConfig.fromUrl(explore.url!.replaceAll('{{page}}', "${pageNum}"));
    var res = await urlConfig.request<String>(getDio(), source.bookSourceUrl);
    //header.title@a@text
    var rule = source.ruleExplore;
    if (rule?.bookList?.isNotEmpty != true) {
      rule = source.ruleSearch;
    }
    var jsonMap = getJsonContent(res.data, rule?.jsonContent);
    var document = getDocumentContent(res.data);
    print("发现页:$rule");
    var list = _parseList(jsonMap,document,rule?.bookList);
    var bookList = list?.map((e) {
      return BookItemBean.FormSource(source)
        ..name = _parseRule(e,rule?.name)?.trim()
        ..intro = _parseRule(e,rule?.intro)?.trim()
        ..author = _parseRule(e,rule?.author)
        ..lastChapter = _parseRule(e,rule?.lastChapter)
        ..coverUrl = urlFix(_parseRule(e,rule?.coverUrl), source.bookSourceUrl!)
        ..bookUrl = _parseRule(e,rule?.bookUrl);
    }).toList();

    return bookList ?? [];
  }
parseRule(dynamic e,String rule,bool isJson){

}
  SourceExploreUrl? getSourceExplore([String? title = null]) {
    SourceExploreUrl? explore;
    if (title == null) {
      explore = source.exploreUrls?.first;
    } else {
      explore = source.exploreUrls?.firstWhere((element) => element.title == title);
    }
    return explore;
  }

  Dio? _dio;

  Dio getDio() => _dio != null
      ? _dio!
      : DioHelper.dio(source.bookSourceUrl ?? "", (dio) {
          dio.options = BaseOptions(
            requestEncoder: (req, option) {
              if (option.contentType?.toLowerCase().contains(RegExp('gb')) == true) {
                return gbk.encode(req);
              } else {
                return utf8.encode(req);
              }
            },
            responseDecoder: (rep, option, repBody) {
              if (repBody.headers['content-type']?.first.toLowerCase().contains(RegExp('gb')) == true) {
                return gbk.decode(rep,allowInvalid: true);
              }
              final key=repBody.headers.keys.firstWhere((element) => element.toLowerCase()=="content-type");
              if (repBody.headers[key]?.contains("text/html") == true) {
                var res = utf8.decode(rep, allowMalformed: true);
                final doc = parse(res);
                final docContentType = doc.querySelector('meta[http-equiv="Content-Type"]');
                if (docContentType != null) {
                  if (docContentType.attributes['content']?.contains("charset=gb") == true) {
                    return gbk.decode(rep,allowInvalid: true);
                  }
                }
                return res;
              }
              return utf8.decode(rep, allowMalformed: true);
            },
          );
        });

  ///发现页
  Future<List<BookItemBean>> searchBookList(String? searchKey) async {
    if (searchKey?.isNotEmpty != true) return [];
    String? searchUrl = source.searchUrl;
    if (searchUrl?.isNotEmpty != true) return [];

    searchUrl = searchUrl!.replaceAll(RegExp(r"{{key}}"), searchKey ?? "");

    final urlConfig = UrlConfig.fromUrl(searchUrl);
    Response<dynamic> res = await urlConfig.request<String>(getDio(), source.bookSourceUrl);

    //header.title@a@text
    var rule = source.ruleSearch;
    var jsonRule = rule?.jsonContent;

    ///json 规则
    var jsonMap = getJsonContent(res.data, jsonRule);
    var document = getDocumentContent(res.data);
    var list = _parseList(jsonMap,document, rule?.bookList);
    var bookList = list
        ?.map((e) => BookItemBean.FormSource(source)
      ..name = _parseRule(e, rule?.name)?.trim()
      ..intro = _parseRule(e, rule?.intro)?.trim()
      ..author = _parseRule(e, rule?.author)
      ..lastChapter = _parseRule(e, rule?.lastChapter)
      ..coverUrl = urlFix(_parseRule(e, rule?.coverUrl), source.bookSourceUrl!)
      ..bookUrl = _parseRule(e, rule?.bookUrl))
        .toList();

    return bookList ?? [];
  }

  List? _parseList(dynamic jsonMap, Element? document, String? rule) {
    if (jsonMap != null) return parseRuleJsonList(jsonMap, rule);
    return document?.parseRuleWithoutAttr(rule);
  }
  String? _parseRule(dynamic dynamic, String? rule,[AttrBean? attrBean=null]) {
    if(dynamic is Element){
      return dynamic.parseRule(rule,attrBean)?.trim();
    }
    return parseRuleJson(dynamic, rule,attrBean)?.trim();
  }

  Future<BookDetailBean?> queryBookDetail(BookItemBean bean) async {
    final urlConfig = UrlConfig.fromUrl(bean.bookUrl ?? "");
    var res = await urlConfig.request<dynamic>(getDio(), source.bookSourceUrl);

    var element = parse(res.data).documentElement;
    if (element == null) return null;
    var rule = source.ruleBookInfo;
    var bookBean = BookDetailBean(id: Uuid().v1(), sourceUrl: source.bookSourceUrl, updateAt: DateTime.now().millisecondsSinceEpoch)
      ..name = element.parseRule(rule?.name) ?? bean.name
      ..author = element.parseRule(rule?.author) ?? bean.author
      ..coverUrl = urlFix(element.parseRule(rule?.coverUrl) ?? bean.coverUrl, source.bookSourceUrl!)
      ..kind = element.parseRule(rule?.kind)?.trim()
      ..lastChapter = element.parseRule(rule?.lastChapter)
      ..intro = element.parseRule(rule?.intro)?.trim()
      ..tocUrl = urlFix(checkUrlRule(bean.bookUrl!, rule?.tocUrl) ?? element.parseRule(rule?.tocUrl) ?? bean.bookUrl, source.bookSourceUrl!);
    if (bookBean.tocUrl == bean.bookUrl) {
      bookBean.chapters = await getChapters(element, bookBean);
    }
    return bookBean;
  }

  Future<List<BookChapterBean>?> queryBookTocs(BookDetailBean bean) async {
    if(_disposed) return null;

    var config = UrlConfig.fromUrl(bean.tocUrl ?? "");
    var res = await config.request<dynamic>(getDio(), source.bookSourceUrl);
    var element = parse(res.data).documentElement;
    if (element == null) return null;
    debug("获取所有章节列表${source.ruleToc}");
    List<BookChapterBean> resList = await getChapters(element, bean);

    HashMap<String, BookChapterBean> maps = HashMap();
    bean.chapters?.forEach((e) {
      maps[e.chapterName ?? ""] = e;
    });
    var newChapters = resList.map((e) => maps[e.chapterName ?? ""] ?? e).toList();
    return newChapters;
  }

  Future<List<BookChapterBean>> getChapters(Element element, BookDetailBean bookBean) async {
    var attrBean = AttrBean(baseUrl: bookBean.tocUrl);

    ///json 规则
    var jsonMap = getJsonContent(element.outerHtml, source.ruleToc?.jsonContent);
    var document = element;

    var rule = source.ruleToc;
    var list = _parseList(jsonMap, document, rule?.chapterList);
    var resList = list
        ?.mapIndexed((i, e) => BookChapterBean(id: Uuid().v1(), bookId: bookBean.id, chapterIndex: i)
          ..chapterName = _parseRule(e, rule?.chapterName, attrBean)?.trim()
          ..chapterUrl = urlFix(_parseRule(e, rule?.chapterUrl, attrBean), source.bookSourceUrl!))
        .toList()??[];
    if (rule?.nextTocUrl?.isNotEmpty == true) {
      var nextTocUrl = _parseRule(element,rule?.nextTocUrl);
      if (nextTocUrl?.isNotEmpty == true) {
        var config = UrlConfig.fromUrl(nextTocUrl ?? "");
        var res = await config.request<dynamic>(getDio(), bookBean.tocUrl);
        final ele = parse(res.data).documentElement;
        if (ele != null) resList.addAll(await getChapters(ele, bookBean));
      }
    }
    return resList;
  }

  Future<BookChapterBean?> queryBookContent(BookChapterBean bean) async {
    var result = await queryBookContentByUrl(bean.chapterUrl, source.ruleContent, bean.chapterUrl);
    result = dealHtmlContentResult(result) ?? "";

    if (result.isEmpty) {
      result = "没找到内容";
    }
    if (source.bookSourceType == source_type_novel) {
      result = result.split(RegExp('\n')).whereNot((element) => element.isEmpty).map((e) {
        return "　　${e.trim()}";
      }).join('\n');
    }
    if (result.isNotEmpty) bean.content = ChapterContent.FromChapter(bean, result);
    return bean;
  }

  Future<String> queryBookContentByUrl(String? url, SourceRuleContent? rule, String? baseUrl) async {
    if(_disposed) return "";
    if (url?.isNotEmpty != true) return "";

    final urlConfig = UrlConfig.fromUrl(url!);
    Response<dynamic> res;
    try {
      res = await urlConfig.request(getDio(), baseUrl);
    } catch (e) {
      return "";
    }
    var element = parse(res.data).documentElement;
    if (element == null) return "";

    var originContent = element.parseRule("${rule?.content}");
    var result = originContent;

    rule?.replaceRegex?.split('&&').forEach((element) {
      var replaces = element.split('##').where((element) => element.isNotEmpty).toList();
      var reg = replaces[0];
      var replace = "";
      if (replaces.length == 2) {
        replace = replaces[1];
      }
      result = result?.replaceAll(RegExp(reg), replace);
    });

    var nextUrl = element.parseRule("${rule?.nextContentUrl}")?.trim();
    if (nextUrl?.isNotEmpty == true && result?.isNotEmpty == true) {
      ///和下一页是否是正常断开？判断最后结束是不是中文结束，如果是中文非标点符号，则说明是异常断开
      bool nomalBreak = true;
      if (RegExp(r"[\u4e00-\u9fa5]\s*$").hasMatch(result ?? "")) {
        nomalBreak = false;
      }
      result = (result ?? "") + (nomalBreak ? "\n" : "") + await queryBookContentByUrl(nextUrl, rule, urlConfig.searchUrl);
    }

    return result ?? "";
  }
}

class UrlConfig {
  var method = "get";
  var charset = "utf-8";
  dynamic body;
  String? contentType;
  String? searchUrl;

  static UrlConfig fromUrl(String searchUrl) {
    try {
      searchUrl = Uri.decodeComponent(searchUrl);
    }catch (e) {}
    if (searchUrl.isEmpty) throw "url为空，不做网络请求";
    var index = -1;
    if (searchUrl.contains(RegExp(r'{[\s\S]*}'))) {
      index = searchUrl.indexOf(',');
    }
    var config = UrlConfig();
    config.searchUrl = searchUrl;
    if (index == -1) return config;
    final methodJson = json.decode(searchUrl.substring(index + 1));
    searchUrl = searchUrl.substring(0, index);
    config.searchUrl = searchUrl;
    config.method = methodJson['method'] ?? "get";
    config.body = methodJson['body'];
    config.charset = methodJson['charset'] ?? "";
    config.contentType = methodJson['contentType'];
    if (config.body is Map)
      config.contentType = config.contentType ?? Headers.jsonContentType;
    else
      config.contentType = config.contentType ?? Headers.formUrlEncodedContentType;

    if (config.charset.isNotEmpty) {
      config.contentType = config.contentType?.replaceAll(RegExp(r"utf-8"), config.charset);
    }
    return config;
  }

  request<T>(Dio dio, String? baseUrl) async {
    searchUrl = urlFix(searchUrl, baseUrl ?? "");
    print(body);
    return await dio.request<T>(searchUrl ?? "",
        data: body,
        queryParameters: method == "get" ? body : null,
        options: Options(
          method: method,
          contentType: contentType,
        ));
  }
}
