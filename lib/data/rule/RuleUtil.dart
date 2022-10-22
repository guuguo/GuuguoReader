import 'package:collection/collection.dart';
import 'package:html/dom.dart';

String? checkUrlRule(String baseUrl, String? rule) {
  final reg = RegExp(r'{{baseUrl}}');
  if (rule?.contains(reg) == true) {
    return rule?.replaceAll(reg, baseUrl);
  } else
    return null;
}

extension ElementListExt on List<Element> {
  List<Element> queryCustomSelectorAllFix(String selector) {
    final splitPoint = selector.split('.');
    List<Element> getIndex(List<Element> list, int? index) {
      if (index == null) return list;
      if (index >= 0)
        return [this[index]];
      else
        return [this[this.length - 1 + index]];
    }

    ///是否是  tag.a.1 的格式   或者.2 的数组格式
    if (splitPoint.length > 1) {
      if (splitPoint[0].isNotEmpty != true) {
        if (splitPoint.length == 2) {
          ///如果是.2 数组风格
          try {
            final index = int.parse(splitPoint[1]);
            return getIndex(this, index);
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
          return getIndex(res, index);
        }
        final res = querySelectorAllFix(selector);
        return getIndex(res, index);
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
  ///[urlReplace] 是否处理图片url等需要替换的值
  ///比如  dt@a@href##.*/(\\d+)/(\\d+)/##https://style.31xs.net/img/$1/$2/$2s.jpg
  ///从 https://m.31xs.com/201/201996/ url中提取出 两个数字关键词 201， 201996
  ///将其作为$1和$2替换到结果中
  ///
  String? parseRule(String? rule, [bool urlReplace = false]) {
    if (rule == null) return null;

    ///正则 处理 ##分割
    var regexSpan = rule.split('##');
    String? regex;
    String? replace;
    if (regexSpan.length > 1) {
      regex = regexSpan[1];
    }
    if (regexSpan.length > 2) {
      replace = regexSpan[2];
    }

    ///备选方案 处理 && 分割
    var rules = regexSpan[0].split('&&');
    String? resultStr;
    for (var i = 0; i < rules.length; i++) {
      resultStr = _selectElement(rules[i], regex, replace, urlReplace);
      if (resultStr != null) break;
    }
    return resultStr;
  }

  String? _selectElement(String rule, String? regex, String? replace, bool urlReplace) {
    ///css selector 处理 @ 分割
    var tags = rule.split('@');
    var attr;
    attr = tags.last;
    tags.removeLast();

    List<Element>? resultElement = [this];
    tags.where((element) => element.isNotEmpty).forEach((selector) {
      resultElement = resultElement?.queryCustomSelectorAllFix(selector);
    });
    String? resultStr;
    if (attr == "html") {
      resultStr = resultElement?.map((e) => e.innerHtml).whereNotNull().join('\n');
    } else if (attr == "text") {
      resultStr = resultElement?.map((e) => e.text).whereNotNull().join('\n');
    } else {
      resultStr = resultElement?.map((e) => e.attributes[attr]).whereNotNull().join('\n');
    }

    if (regex != null) {
      if (urlReplace) {
        final reg = RegExp(r'(?<=/)\d+(?=/)');
        List<String?> params = reg.allMatches(resultStr ?? "").map((e) => e[0]).toList();
        resultStr = resultStr?.replaceAll(RegExp(regex), replace ?? "");
        if (params.length >= 1 && params[0] != null) {
          resultStr = resultStr?.replaceAll(RegExp(r"\$1"), params[0]!);
        }
        if (params.length >= 2 && params[1] != null) {
          resultStr = resultStr?.replaceAll(RegExp(r"\$2"), params[1]!);
        }
      } else {
        resultStr = resultStr?.replaceAll(RegExp(regex), replace ?? "");
      }
    }
    if (resultStr?.isEmpty == true) return null;
    return resultStr;
  }

  List<Element> parseRuleWithoutAttr(String? rule) {
    if (rule == null) return [];
    var tags = rule.split('@');
    List<Element>? resultElement;

    tags.forEachIndexed((i, selector) {
      if (i == 0) {
        resultElement = this.querySelectorAllFix(selector);
      } else {
        resultElement = resultElement?.fold([], (previousValue, element) => [...(previousValue ?? []), ...element.querySelectorAllFix(selector)]);
      }
    });
    return resultElement ?? [];
  }

  List<Element> querySelectorAllFix(String selector) {
    if (selector.contains(":nth-of-type")) {
      return dealNthOfType(selector);
    }
    // if(selector.contains("text")){
    //   return dealNthOfType(selector);
    // }
    if (selector.contains(":")) {
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
