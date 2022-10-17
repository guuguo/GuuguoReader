import 'package:intl/intl.dart';

extension DateTimeExt on DateTime {
  String format(String str) {
    final DateFormat formatter = DateFormat(str);
    return formatter.format(this);
  }
}

typedef ItemBuilder<T> =T Function(int index);