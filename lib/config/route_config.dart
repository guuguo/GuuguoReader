import 'package:get/get.dart';
import 'package:read_info/bean/book_item_bean.dart';
import 'package:read_info/page/bookread/binding.dart';
import 'package:read_info/page/bookread/view.dart';
import 'package:read_info/page/detailbook/view.dart';
import 'package:read_info/page/detailsms/binding.dart';
import 'package:read_info/page/detailsms/view.dart';
import 'package:read_info/page/explore/binding.dart';
import 'package:read_info/page/explore/view.dart';
import 'package:read_info/page/source/binding.dart';
import 'package:read_info/page/source/view.dart';

class RouteConfig {
  static const String explore = "/list";
  static const String detailsms = "/detail/sms";
  static const String detailbook = "/detail/book";
  static const String source = "/source";
  static const String bookcontent = "/bookcontent";

  static final List<GetPage> getPages = [
    GetPage(
      name: source,
      page: () => SourcePage(),
      binding: SourceBinding(),
    ),
    GetPage(
      name: explore,
      page: () => ExplorePage(),
      binding: ExploreBinding(),
    ),
    GetPage(
      name: detailsms,
      page: () => DetailSmsPage(),
      binding: DetailBinding(),
    ),
    GetPage(
      name: detailbook,
      page: () => DetailBookPage(),
      binding: DetailBinding(),
    ),
    GetPage(
      name: bookcontent,
      page: () => BookContentPage(),
      binding: ContentBinding(),
    ),
  ];
}
