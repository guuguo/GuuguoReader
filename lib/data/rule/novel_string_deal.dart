

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

MapEntry<String?,String> getChapterIndexName(String? chapter){
  if(chapter?.isNotEmpty!=true) return MapEntry(null,"");
  MapEntry<String?, String> res;
  res = getChapterIndexNameWithSeparated(chapter!, ',');
  if (res.key!=null) {
    return res;
  }

  res = getChapterIndexNameWithSeparated(chapter, '.');
  if (res.key!=null) {
    return res;
  }

  res = getChapterIndexNameWithSeparated(chapter, '，');
  if (res.key!=null) {
    return res;
  }

  res = getChapterIndexNameWithSeparated(chapter, '、');
  if (res.key!=null) {
    return res;
  }

  res = getChapterIndexNameWithSeparated(chapter, ' ');
  if (res.key!=null) {
    return res;
  }

  var reg=RegExp(r'（[一|二|三|四|五|六|七|八|九|十|百]+?）');
  var index=reg.firstMatch(chapter);
  if(index!=null) return MapEntry(index[0],chapter.replaceAll(reg, ""));

  reg=RegExp(r'\([一|二|三|四|五|六|七|八|九|十|百]+?\)');
  index=reg.firstMatch(chapter);
  if(index!=null) return MapEntry(index[0],chapter.replaceAll(reg, ""));


  return res;
}
MapEntry<String?,String> getChapterIndexNameWithSeparated(String chapter,String separated){
  var splits= chapter.split(separated);
  var name;
  splits = splits.where((element) => element.isNotEmpty).toList();
  if(splits.length>1){
    name =splits[1];
    final index =int.tryParse(splits[0]);
    if(index!=null){
      return MapEntry("第${ConvertNumberToChineseMoneyWords.toChinese(index)}章",name);
    }
    return MapEntry(splits[0], splits[1]);
  }
  else return MapEntry(null, chapter);
}
class ConvertNumberToChineseMoneyWords{
  // 大写数字
  static List<String> NUMBERS = ["一", "二", "三", "四", "五", "六", "七", "八", "九", "十",""];

  static String toChinese(int index) {
    if(index > 100){
      return index.toString();
    }
    StringBuffer stringBuffer = StringBuffer();
    if(index / 10 < 1){
      return NUMBERS[index];
    }
    int tenUnit = index ~/ 10;
    int remainder = index % 10;
    if(remainder == 9){
      tenUnit++;
      remainder = 10;
    }
    if(tenUnit == 1){
      stringBuffer..write("十")..write(NUMBERS[remainder]);
      return stringBuffer.toString();
    }
    stringBuffer..write(NUMBERS[tenUnit - 1])..write("十")..write(NUMBERS[remainder]);
    return stringBuffer.toString();
  }
}