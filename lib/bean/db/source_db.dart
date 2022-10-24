import 'package:floor/floor.dart';

@entity
class Source{
  @PrimaryKey()
  final String? bookSourceUrl;
  final String? detail;

  Source({this.bookSourceUrl, this.detail});
}