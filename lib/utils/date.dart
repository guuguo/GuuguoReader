///日期转换
class DateTimeUtil {
  ///获取友好的时间显示  3秒前  3天前
  static String beforeSimpleStr(DateTime? beforeDateTime) {
    if (beforeDateTime == null) {
      return '';
    }
    final now = DateTime.now();
    final span = now.difference(beforeDateTime);
    if (span.inSeconds < 60) {
      return '${span.inSeconds}秒前';
    }
    if (span.inMinutes < 60) {
      return '${span.inMinutes}分钟前';
    }
    if (span.inHours < 24) {
      return '${span.inHours}小时前';
    }
    if (span.inDays  < 30) {
      return '${span.inDays}天前';
    }
    if (span.inDays  ~/ 30 < 12) {
      return '${span.inDays ~/ 30}月前';
    }
    return '${span.inDays  ~/ 365}年前';
  }

  ///getDayBefore 获取多少天前的天数
  static int beforeDay(DateTime beforeDateTime) {
    if (beforeDateTime == null) {
      return 0;
    }
    final now = DateTime.now();
    final span = now.difference(beforeDateTime);
    return span.inDays;
  }

  ///获取星期字符串
  static String getWeekdayStr(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return '周一';
      case DateTime.tuesday:
        return '周二';
      case DateTime.wednesday:
        return '周三';
      case DateTime.thursday:
        return '周四';
      case DateTime.friday:
        return '周五';
      case DateTime.saturday:
        return '周六';
      case DateTime.sunday:
        return '周日';
    }
    return '';
  }

  ///字符转换数组
  static const List<String> mapArray = [
    '零',
    '一',
    '二',
    '三',
    '四',
    '五',
    '六',
    '七',
    '八',
    '九',
    '十',
    '十一',
    '十二',
  ];

  ///获取 数字转中文的日期字符串  如 2008年 1月 -> 二零零八年 一月
  static String getChineseDateStr(int year, int month) {
    final yearStr = year.toString();
    final newStr = StringBuffer();
    for (var i = 0; i < yearStr.length; i++) {
      final child = yearStr[i];
      try {
        newStr.write(mapArray[int.parse(child)]);
      } on Exception {
        newStr.write(child);
      }
    }
    return '${newStr.toString()}年 ${mapArray[month]}月';
  }

  ///获取是否今天或者昨天
  static String? getStrikeTimeStr(DateTime time) {
    final now = DateTime.now();
    if (time.year == now.year && time.month == now.month) {
      if (time.day == now.day)
        return '今天';
      else if (time.day == now.subtract(Duration(days: 1)).day)
        return '昨天';
      else
        return null;
    } else
      return null;
  }

}
