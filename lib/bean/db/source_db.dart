import 'package:floor/floor.dart';

@entity
class Source{
  @PrimaryKey()
  final String? bookSourceUrl;
  final String? detail;
  final String? bookSourceName;

  Source({this.bookSourceUrl, this.detail,this.bookSourceName});
}