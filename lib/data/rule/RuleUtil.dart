import 'package:collection/collection.dart';
import 'package:html/dom.dart';
extension ElementListExt on List<Element>{
  List<Element> querySelectorAllFix(String selector) {
    return fold(
        [],
        (List previousValue, element) =>
            [...(previousValue), ...element.querySelectorAllFix(selector)]);
  }
}

extension ElementExt on Element{
  String? parseRule(String? rule) {
    if(rule==null) return null;
    ///正则 处理 ##分割
    var regexSpan = rule.split('##');
    String? regex;
    String? replace;
    if(regexSpan.length>1){
      regex=regexSpan[1];
    }
    if(regexSpan.length>2){
      replace=regexSpan[2];
    }

    ///备选方案 处理 && 分割
    var rules = regexSpan[0].split('&&');
    String? resultStr;
    for (var i = 0; i < rules.length; i++) {
      resultStr = _selectElement(rules[i], regex,replace);
      if (resultStr != null) break;
    }
    return resultStr;
  }

  String? _selectElement(String rule,String? regex,String? replace){
    ///css selector 处理 @ 分割
    var tags = rule.split('@');
    var attr;
    attr = tags.last;
    tags.removeLast();

    List<Element>? resultElement = [this];
    tags.where((element) => element.isNotEmpty).forEach((selector) {
      resultElement = resultElement?.querySelectorAllFix(selector);
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
      resultStr = resultStr?.replaceAll(RegExp(regex), replace ?? "");
    }
     if(resultStr?.isEmpty==true) return null;
    return resultStr;
  }
  List<Element> parseRuleWithoutAttr(String? rule){
    if(rule==null) return [];
    var tags=rule.split('@');
    List<Element>? resultElement;

    tags.forEachIndexed((i,selector) {
      if (i == 0) {
        resultElement = this.querySelectorAllFix(selector);
      } else {
        resultElement = resultElement?.fold([], (previousValue, element) => [...(previousValue??[]),... element.querySelectorAll(selector)]);
      }
    });
    return  resultElement??[];
  }
  // Element? querySelectorFix(String selector){
  //   if(selector.contains("nth-of-type")) {
  //     return querySelectorAllFix(selector).firstOrNull;
  //   }else{
  //     return querySelector(selector);
  //   }
  // }
  List<Element> querySelectorAllFix(String selector){
    if(selector.contains("nth-of-type")){
      final split=selector.split(':');
      var list=querySelectorAll(split[0]);
      RegExp exp = new RegExp(r"(?<=\().*(?=\))");
      final nth= exp.firstMatch(selector)?.group(0)??"n";
      final nsplit=nth.split('n');
      if(!nth.contains('n')){
        final cons=int.tryParse(nth)??1;
        if(list.length < cons) return[];
        return [list[cons-1]];
      }else if(nsplit.length==2){
        final n=int.tryParse(nsplit[0])??1;
        final cons=int.tryParse(nsplit[1].replaceAll('+', ''))??0;
        return list.whereIndexed((index, element)  =>(index+1-cons)%n==0&&(index+1-cons)/n>0).toList();
      }else{
        return list;
      }
    }else {
      return querySelectorAll(selector);
    }
  }
}

