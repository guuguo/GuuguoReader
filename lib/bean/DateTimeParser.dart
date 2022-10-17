import 'package:intl/intl.dart';

var formatter = new DateFormat('yyyy-MM-ddTHH:mm:ss.mmmZ');

class DateTimeParser {
  // Make sure to add a constant constructor, because dartson will initiate all tranformers
  // as constant to improve dart2js compilation.
  const DateTimeParser();

  DateTime? decode(String? value) {
    if (value == null || value == 'null') return null;
    DateTime date = DateTime.parse(value).toLocal();
    return date;
  }

  String encode(DateTime? value) => value.toString();
}
