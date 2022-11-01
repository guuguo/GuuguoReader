import 'package:collection/collection.dart';
import 'package:html/dom.dart';
import 'package:read_info/utils/ext/match_ext.dart';
String? checkUrlRule(String baseUrl, String? rule) {
  final reg = RegExp(r'{{baseUrl}}');
  if (rule?.contains(reg) == true) {
    return rule?.replaceAll(reg, baseUrl);
  } else
    return null;
}
List<Element> getElementsByIndex(List<Element> list, int? index) {
  if (index == null|| list.isEmpty) return list;
  if (index >= 0) {
    if (index < list.length) return [list[index]];
    return [];
  } else {
    final resI = list.length - 1 + index;
    if (resI >= 0) return [list[resI]];
    return [];
  }
}

extension ElementListExt on List<Element> {

  List<Element> queryCustomSelectorAllFix(String selector) {
    final splitPoint = selector.split('.');


    ///是否是  tag.a.1 的格式   或者.2 的数组格式
    if (splitPoint.length > 1) {
      if (splitPoint[0].isNotEmpty != true) {
        if (splitPoint.length == 2) {
          ///如果是.2 数组风格
          try {
            final index = int.parse(splitPoint[1]);
            return getElementsByIndex(this, index);
          } catch (e) {
            ///如果走到catch 说明是 .class的风格 不处理交给后续css selector

          }
        }
      } else {
        int? index;
        if (splitPoint.length > 2) {
          try {
            index = int.parse(splitPoint[2]);
          } catch (e) {}
        }
        final value = splitPoint[1];
        if (splitPoint[0] == "tag") {
          selector = value;
        } else if (splitPoint[0] == "class") {
          selector = ".${value}";
        } else if (splitPoint[0] == "id") {
          selector = "#${value}";
        } else if (splitPoint[0] == "text") {
          final res = this.where((element) => element.text.contains(RegExp(value))).toList();
          return getElementsByIndex(res, index);
        }
        final res = querySelectorAllFix(selector);
        return getElementsByIndex(res, index);
      }
    }
    return querySelectorAllFix(selector);
  }

  List<Element> querySelectorAllFix(String selector) {
    return fold([], (List previousValue, element) => [...(previousValue), ...element.querySelectorAllFix(selector)]);
  }
}

extension ElementExt on Element {
  ///[rule] 匹配规则
  ///当前支持
  /// - && 连接多个不同的匹配结果
  /// - @ 分割css 选择器匹配
  /// - ## 后面跟随正则表达式
  /// 比如ol.am-breadcrumb@li:nth-of-type(2)@text
  ///[matchReplace] 是否处理图片url等需要替换的值
  ///比如  dt@a@href##.*/(\\d+)/(\\d+)/##https://style.31xs.net/img/$1/$2/$2s.jpg
  ///从 https://m.31xs.com/201/201996/ url中提取出 两个数字关键词 201， 201996
  ///将其作为$1和$2替换到结果中
  ///
  String? parseRule(String? rule, [AttrBean? attrBean = null]) {
    if (rule?.isNotEmpty != true) return null;
    if (attrBean != null) {
      rule = attrBean.dealRes(rule);
    }

    ///正则 处理 ##分割
    var regexSpan = rule!.split('##');
    String? regex;
    String? replace;
    if (regexSpan.length > 1) {
      regex = regexSpan[1];
    }
    if (regexSpan.length > 2) {
      replace = regexSpan[2];
    }

    String? resultStr=_selectElement(regexSpan[0], regex, replace, rule.endsWith("###"));
    return resultStr;
  }

  String? _selectElement(String rule, String? regex, String? replace, bool urlReplace) {
    ///处理 && 分割
    if(rule.contains('&&')) {
      var rules = rule.split('&&');
      return rules.map((e) => _selectElement(e, regex, replace, urlReplace)).join('\n');
    }
    ///处理 || 分割
    if (rule.contains('||')) {
      var rules = rule.split('||');
      for (String e in rules) {
        final res = _selectElement(e, regex, replace, urlReplace);
        if (res?.isNotEmpty == true) return res;
      }
      return null;
    }

    if(rule.isEmpty){
      rule="html";
    }
    ///css selector 处理 @ 分割
    var tags = rule.split('@');
    var attr;
    attr = tags.last;
    tags.removeLast();

    List<Element> resultElement = [this];
    tags.where((element) => element.isNotEmpty).forEach((selector) {
      resultElement = resultElement.queryCustomSelectorAllFix(selector);
    });
    String? resultStr;
    if (attr == "html") {
      resultStr = resultElement.map((e) => e.innerHtml).whereNotNull().join('\n');
    }else if (attr == "outerHtml") {
      resultStr = resultElement.map((e) => e.outerHtml).whereNotNull().join('\n');
    } else if (attr == "text"||attr=="textNodes") {
      resultStr = resultElement.map((e) => e.text).whereNotNull().join('\n');
    } else {
      resultStr = resultElement.map((e) => e.attributes[attr]).whereNotNull().join('\n');
    }

    resultStr = replaceContentWithRule(resultStr, regex, replace,urlReplace);
    if (resultStr?.isEmpty == true) return null;
    return resultStr;
  }

  List<Element> parseRuleWithoutAttr(String? rule) {
    if(rule==null) return [this];
    ///处理 && 分割
    if(rule.contains('&&')) {
      var rules = rule.split('&&');
      return rules.map((e) => parseRuleWithoutAttr(e)).flattened.toList();
    }
    ///处理 || 分割
    if (rule.contains('||')) {
      var rules = rule.split('||');
      for (String e in rules) {
        final res = parseRuleWithoutAttr(e);
        if (res.isNotEmpty == true) return res;
      }
      return [];
    }

    if (rule == null) return [];
    var tags = rule.split('@');
    List<Element> resultElement = [this];

    tags.forEachIndexed((i, selector) {
      resultElement = resultElement.queryCustomSelectorAllFix(selector);
    });
    return resultElement;
  }

  List<Element> querySelectorAllFix(String selector) {
    if (selector.contains(":nth-of-type")) {
      return dealNthOfType(selector);
    }
    if (selector.contains(":(")) {
      return dealNthOfType(selector);
    } else {
      return querySelectorAll(selector);
    }
  }

  List<Element> dealNthOfType(String selector) {
    final split = selector.split(':');
    var list = querySelectorAll(split[0]);
    RegExp exp = new RegExp(r"(?<=\().*(?=\))");
    final nth = exp.firstMatch(selector)?.group(0) ?? "n";
    final nsplit = nth.split('n');
    if (!nth.contains('n')) {
      final cons = int.tryParse(nth) ?? 1;
      if (list.length < cons) return [];
      return [list[cons - 1]];
    } else if (nsplit.length == 2) {
      final n = int.tryParse(nsplit[0]) ?? 1;
      final cons = int.tryParse(nsplit[1].replaceAll('+', '')) ?? 0;
      return list.whereIndexed((index, element) => (index + 1 - cons) % n == 0 && (index + 1 - cons) / n > 0).toList();
    } else {
      return list;
    }
  }
}
String? getJsonContent(String? httpRes,String? jsonRule){
  if(jsonRule?.isNotEmpty!=true) return null;
  ///正则 处理 ##分割
  var regexSpan = jsonRule!.split('##');
  String? regex;
  String? replace;
  if (regexSpan.length > 1) {
    regex = regexSpan[1];
  }
  if (regexSpan.length > 2) {
    replace = regexSpan[2];
  }
  final jsonContent = replaceContentWithRule(httpRes ?? "", regex, replace, jsonRule.endsWith('###'));
  if(jsonContent?.isNotEmpty==true) return jsonContent;
  return null;
}
String? replaceContentWithRule(String resultStr, String? regex, String? replace, bool urlReplace) {
  String? result = resultStr;
  if (resultStr.isNotEmpty == true && regex != null) {
    final originReg = RegExp(regex);
    if (urlReplace) {
      final allMatches = originReg.allMatches(resultStr);
      var s1 = allMatches.firstOrNull?.groupOrNull(1);
      var s2 = allMatches.firstOrNull?.groupOrNull(2);
      var s3 = allMatches.firstOrNull?.groupOrNull(3);

      replace = replace?.replaceAll(RegExp(r"\$1"), s1 ?? "");
      replace = replace?.replaceAll(RegExp(r"\$2"), s2 ?? "");
      replace = replace?.replaceAll(RegExp(r"\$3"), s3 ?? "");
      result = replace;
    } else {
      result = resultStr.replaceAll(originReg, replace ?? "");
    }
  }
  return result;
}

///支持的格式 data.1.booName
String? parseRuleJson(dynamic jsonObj, String? rule, [AttrBean? attrBean = null]) {
  if (rule?.isNotEmpty != true) return null;
  if (attrBean != null) {
    rule = attrBean.dealRes(rule);
  }

  ///正则 处理 ##分割
  var regexSpan = rule!.split('##');
  String? regex;
  String? replace;
  if (regexSpan.length > 1) {
    regex = regexSpan[1];
  }
  if (regexSpan.length > 2) {
    replace = regexSpan[2];
  }
  final list=parseRuleJsonList(jsonObj,regexSpan[0]);
  var res=list?.join('\n')??"";
  String? resultStr=replaceContentWithRule(res.toString(), regex, replace, rule.endsWith("###"));
  return resultStr;
}
class AttrBean{

  String? baseUrl = "";

  AttrBean({this.baseUrl = ""});

  String? dealRes(String? rule) {
    if (rule?.isNotEmpty != true) return null;
    var result=rule!.replaceAll("{{baseUrl}}", baseUrl ?? "");
    return result;
  }
}
List? parseRuleJsonList(dynamic jsonObj, String? rule) {
  if (rule?.isNotEmpty != true) return null;
  ///处理 && 分割
  if(rule!.contains('&&')) {
    var rules = rule.split('&&');
    return rules.map((e) => parseRuleJsonList(jsonObj,e)).whereNotNull().flattened.toList();
  }

  if(rule.contains("rawText")){
    return [rule.split('.')[1]];
  }
  List<dynamic> res = jsonObj is List?jsonObj:[jsonObj];
  rule.split('.').forEach((ruleE) {
    res= res.fold<List<dynamic>>([], (previousValue, element) {
      final newEle=element[ruleE];
      if(newEle is List){
        return [...previousValue,...newEle];
      }else{
        return [...previousValue,newEle];
      }
    }).whereNotNull().toList();
  });
  return res;
}

main() {
  final reg=RegExp(r'data-bid="([^"]+)"');
  var str='<a href="//book.qidian.com/info/1031777108" target="_blank" data-eid="qd_C39" data-bid="1031777108"><img src="//bookcover.yuewen.com/qdbimg/349573/1031777108/150" alt="光阴之外在线阅读"></a>';
  var matches=reg.allMatches(str).toList();
  print(matches);
}