import 'package:floor/floor.dart';
import 'package:read_info/generated/json/base/json_field.dart';
import 'package:read_info/generated/json/source_entity.g.dart';
import 'dart:convert';

@JsonSerializable()
class SourceEntity {
	String? bookSourceComment;
	String? bookSourceName;
	int? bookSourceType;
	String? bookSourceUrl;
	String? bookSourceCoverUrl;
	String? header;
	int? customOrder;
	int? from;
	bool? enabled;
	bool? enabledCookieJar;
	bool? enabledExplore;
	bool? enabledReview;
	List<SourceExploreUrl>? exploreUrl;
	int? lastUpdateTime;
	int? respondTime;
	SourceRuleBookInfo? ruleBookInfo;
	SourceRuleContent? ruleContent;
	SourceRuleExplore? ruleExplore;
	SourceRuleReview? ruleReview;
	SourceRuleSearch? ruleSearch;
	SourceRuleToc? ruleToc;
	String? searchUrl;
	int? weight;
  
  SourceEntity();

  factory SourceEntity.fromJson(Map<String, dynamic> json) => $SourceEntityFromJson(json);

  Map<String, dynamic> toJson() => $SourceEntityToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

@JsonSerializable()
class SourceExploreUrl {

	String? title;
	String? url;
	SourceExploreUrlStyle? style;
  
  SourceExploreUrl();

  factory SourceExploreUrl.fromJson(Map<String, dynamic> json) => $SourceExploreUrlFromJson(json);

  Map<String, dynamic> toJson() => $SourceExploreUrlToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

@JsonSerializable()
class SourceExploreUrlStyle {

	@JSONField(name: "layout_flexBasisPercent")
	double? layoutFlexbasispercent;
  
  SourceExploreUrlStyle();

  factory SourceExploreUrlStyle.fromJson(Map<String, dynamic> json) => $SourceExploreUrlStyleFromJson(json);

  Map<String, dynamic> toJson() => $SourceExploreUrlStyleToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

@JsonSerializable()
class SourceRuleBookInfo {

	String? author;
	String? coverUrl;
	String? intro;
	String? kind;
	String? lastChapter;
	String? name;
	String? tocUrl;
  
  SourceRuleBookInfo();

  factory SourceRuleBookInfo.fromJson(Map<String, dynamic> json) => $SourceRuleBookInfoFromJson(json);

  Map<String, dynamic> toJson() => $SourceRuleBookInfoToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

@JsonSerializable()
class SourceRuleContent {

	String? content;
	String? replaceRegex;
  
  SourceRuleContent();

  factory SourceRuleContent.fromJson(Map<String, dynamic> json) => $SourceRuleContentFromJson(json);

  Map<String, dynamic> toJson() => $SourceRuleContentToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

@JsonSerializable()
class SourceRuleExplore {

	String? author;
	String? bookList;
	String? bookUrl;
	String? coverUrl;
	String? intro;
	String? name;
  
  SourceRuleExplore();

  factory SourceRuleExplore.fromJson(Map<String, dynamic> json) => $SourceRuleExploreFromJson(json);

  Map<String, dynamic> toJson() => $SourceRuleExploreToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

@JsonSerializable()
class SourceRuleReview {


  
  SourceRuleReview();

  factory SourceRuleReview.fromJson(Map<String, dynamic> json) => $SourceRuleReviewFromJson(json);

  Map<String, dynamic> toJson() => $SourceRuleReviewToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

@JsonSerializable()
class SourceRuleSearch {

	String? author;
	String? bookList;
	String? bookUrl;
	String? kind;
	String? lastChapter;
	String? name;
  
  SourceRuleSearch();

  factory SourceRuleSearch.fromJson(Map<String, dynamic> json) => $SourceRuleSearchFromJson(json);

  Map<String, dynamic> toJson() => $SourceRuleSearchToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

@JsonSerializable()
class SourceRuleToc {

	String? chapterList;
	String? chapterName;
	String? chapterUrl;
  
  SourceRuleToc();

  factory SourceRuleToc.fromJson(Map<String, dynamic> json) => $SourceRuleTocFromJson(json);

  Map<String, dynamic> toJson() => $SourceRuleTocToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}