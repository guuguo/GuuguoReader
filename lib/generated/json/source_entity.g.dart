import 'package:read_info/generated/json/base/json_convert_content.dart';
import 'package:read_info/bean/entity/source_entity.dart';
import 'package:collection/collection.dart';

import 'package:floor/floor.dart';

import 'package:read_info/bean/db/source_db.dart';

import 'package:read_info/generated/json/base/json_convert_content.dart';

import 'package:read_info/utils/ext/list_ext.dart';


SourceEntity $SourceEntityFromJson(Map<String, dynamic> json) {
	final SourceEntity sourceEntity = SourceEntity();
	final String? bookSourceComment = jsonConvert.convert<String>(json['bookSourceComment']);
	if (bookSourceComment != null) {
		sourceEntity.bookSourceComment = bookSourceComment;
	}
	final String? bookSourceName = jsonConvert.convert<String>(json['bookSourceName']);
	if (bookSourceName != null) {
		sourceEntity.bookSourceName = bookSourceName;
	}
	final int? bookSourceType = jsonConvert.convert<int>(json['bookSourceType']);
	if (bookSourceType != null) {
		sourceEntity.bookSourceType = bookSourceType;
	}
	final String? bookSourceUrl = jsonConvert.convert<String>(json['bookSourceUrl']);
	if (bookSourceUrl != null) {
		sourceEntity.bookSourceUrl = bookSourceUrl;
	}
	final String? bookSourceCoverUrl = jsonConvert.convert<String>(json['bookSourceCoverUrl']);
	if (bookSourceCoverUrl != null) {
		sourceEntity.bookSourceCoverUrl = bookSourceCoverUrl;
	}
	final String? header = jsonConvert.convert<String>(json['header']);
	if (header != null) {
		sourceEntity.header = header;
	}
	final int? customOrder = jsonConvert.convert<int>(json['customOrder']);
	if (customOrder != null) {
		sourceEntity.customOrder = customOrder;
	}
	final int? from = jsonConvert.convert<int>(json['from']);
	if (from != null) {
		sourceEntity.from = from;
	}
	final bool? enabled = jsonConvert.convert<bool>(json['enabled']);
	if (enabled != null) {
		sourceEntity.enabled = enabled;
	}
	final bool? enabledCookieJar = jsonConvert.convert<bool>(json['enabledCookieJar']);
	if (enabledCookieJar != null) {
		sourceEntity.enabledCookieJar = enabledCookieJar;
	}
	final bool? enabledExplore = jsonConvert.convert<bool>(json['enabledExplore']);
	if (enabledExplore != null) {
		sourceEntity.enabledExplore = enabledExplore;
	}
	final bool? enabledReview = jsonConvert.convert<bool>(json['enabledReview']);
	if (enabledReview != null) {
		sourceEntity.enabledReview = enabledReview;
	}
	final dynamic? exploreUrl = jsonConvert.convert<dynamic>(json['exploreUrl']);
	if (exploreUrl != null) {
		sourceEntity.exploreUrl = exploreUrl;
	}
	final int? lastUpdateTime = jsonConvert.convert<int>(json['lastUpdateTime']);
	if (lastUpdateTime != null) {
		sourceEntity.lastUpdateTime = lastUpdateTime;
	}
	final int? respondTime = jsonConvert.convert<int>(json['respondTime']);
	if (respondTime != null) {
		sourceEntity.respondTime = respondTime;
	}
	final SourceRuleBookInfo? ruleBookInfo = jsonConvert.convert<SourceRuleBookInfo>(json['ruleBookInfo']);
	if (ruleBookInfo != null) {
		sourceEntity.ruleBookInfo = ruleBookInfo;
	}
	final SourceRuleContent? ruleContent = jsonConvert.convert<SourceRuleContent>(json['ruleContent']);
	if (ruleContent != null) {
		sourceEntity.ruleContent = ruleContent;
	}
	final SourceRuleExplore? ruleExplore = jsonConvert.convert<SourceRuleExplore>(json['ruleExplore']);
	if (ruleExplore != null) {
		sourceEntity.ruleExplore = ruleExplore;
	}
	final SourceRuleReview? ruleReview = jsonConvert.convert<SourceRuleReview>(json['ruleReview']);
	if (ruleReview != null) {
		sourceEntity.ruleReview = ruleReview;
	}
	final SourceRuleExplore? ruleSearch = jsonConvert.convert<SourceRuleExplore>(json['ruleSearch']);
	if (ruleSearch != null) {
		sourceEntity.ruleSearch = ruleSearch;
	}
	final SourceRuleToc? ruleToc = jsonConvert.convert<SourceRuleToc>(json['ruleToc']);
	if (ruleToc != null) {
		sourceEntity.ruleToc = ruleToc;
	}
	final String? searchUrl = jsonConvert.convert<String>(json['searchUrl']);
	if (searchUrl != null) {
		sourceEntity.searchUrl = searchUrl;
	}
	final int? weight = jsonConvert.convert<int>(json['weight']);
	if (weight != null) {
		sourceEntity.weight = weight;
	}
	return sourceEntity;
}

Map<String, dynamic> $SourceEntityToJson(SourceEntity entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['bookSourceComment'] = entity.bookSourceComment;
	data['bookSourceName'] = entity.bookSourceName;
	data['bookSourceType'] = entity.bookSourceType;
	data['bookSourceUrl'] = entity.bookSourceUrl;
	data['bookSourceCoverUrl'] = entity.bookSourceCoverUrl;
	data['header'] = entity.header;
	data['customOrder'] = entity.customOrder;
	data['from'] = entity.from;
	data['enabled'] = entity.enabled;
	data['enabledCookieJar'] = entity.enabledCookieJar;
	data['enabledExplore'] = entity.enabledExplore;
	data['enabledReview'] = entity.enabledReview;
	data['exploreUrl'] = entity.exploreUrl;
	data['lastUpdateTime'] = entity.lastUpdateTime;
	data['respondTime'] = entity.respondTime;
	data['ruleBookInfo'] = entity.ruleBookInfo?.toJson();
	data['ruleContent'] = entity.ruleContent?.toJson();
	data['ruleExplore'] = entity.ruleExplore?.toJson();
	data['ruleReview'] = entity.ruleReview?.toJson();
	data['ruleSearch'] = entity.ruleSearch?.toJson();
	data['ruleToc'] = entity.ruleToc?.toJson();
	data['searchUrl'] = entity.searchUrl;
	data['weight'] = entity.weight;
	return data;
}

SourceExploreUrl $SourceExploreUrlFromJson(Map<String, dynamic> json) {
	final SourceExploreUrl sourceExploreUrl = SourceExploreUrl();
	final String? title = jsonConvert.convert<String>(json['title']);
	if (title != null) {
		sourceExploreUrl.title = title;
	}
	final String? url = jsonConvert.convert<String>(json['url']);
	if (url != null) {
		sourceExploreUrl.url = url;
	}
	final SourceExploreUrlStyle? style = jsonConvert.convert<SourceExploreUrlStyle>(json['style']);
	if (style != null) {
		sourceExploreUrl.style = style;
	}
	return sourceExploreUrl;
}

Map<String, dynamic> $SourceExploreUrlToJson(SourceExploreUrl entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['title'] = entity.title;
	data['url'] = entity.url;
	data['style'] = entity.style?.toJson();
	return data;
}

SourceExploreUrlStyle $SourceExploreUrlStyleFromJson(Map<String, dynamic> json) {
	final SourceExploreUrlStyle sourceExploreUrlStyle = SourceExploreUrlStyle();
	final double? layoutFlexbasispercent = jsonConvert.convert<double>(json['layout_flexBasisPercent']);
	if (layoutFlexbasispercent != null) {
		sourceExploreUrlStyle.layoutFlexbasispercent = layoutFlexbasispercent;
	}
	return sourceExploreUrlStyle;
}

Map<String, dynamic> $SourceExploreUrlStyleToJson(SourceExploreUrlStyle entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['layout_flexBasisPercent'] = entity.layoutFlexbasispercent;
	return data;
}

SourceRuleBookInfo $SourceRuleBookInfoFromJson(Map<String, dynamic> json) {
	final SourceRuleBookInfo sourceRuleBookInfo = SourceRuleBookInfo();
	final String? author = jsonConvert.convert<String>(json['author']);
	if (author != null) {
		sourceRuleBookInfo.author = author;
	}
	final String? coverUrl = jsonConvert.convert<String>(json['coverUrl']);
	if (coverUrl != null) {
		sourceRuleBookInfo.coverUrl = coverUrl;
	}
	final String? intro = jsonConvert.convert<String>(json['intro']);
	if (intro != null) {
		sourceRuleBookInfo.intro = intro;
	}
	final String? kind = jsonConvert.convert<String>(json['kind']);
	if (kind != null) {
		sourceRuleBookInfo.kind = kind;
	}
	final String? lastChapter = jsonConvert.convert<String>(json['lastChapter']);
	if (lastChapter != null) {
		sourceRuleBookInfo.lastChapter = lastChapter;
	}
	final String? name = jsonConvert.convert<String>(json['name']);
	if (name != null) {
		sourceRuleBookInfo.name = name;
	}
	final String? tocUrl = jsonConvert.convert<String>(json['tocUrl']);
	if (tocUrl != null) {
		sourceRuleBookInfo.tocUrl = tocUrl;
	}
	return sourceRuleBookInfo;
}

Map<String, dynamic> $SourceRuleBookInfoToJson(SourceRuleBookInfo entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['author'] = entity.author;
	data['coverUrl'] = entity.coverUrl;
	data['intro'] = entity.intro;
	data['kind'] = entity.kind;
	data['lastChapter'] = entity.lastChapter;
	data['name'] = entity.name;
	data['tocUrl'] = entity.tocUrl;
	return data;
}

SourceRuleContent $SourceRuleContentFromJson(Map<String, dynamic> json) {
	final SourceRuleContent sourceRuleContent = SourceRuleContent();
	final String? content = jsonConvert.convert<String>(json['content']);
	if (content != null) {
		sourceRuleContent.content = content;
	}
	final String? replaceRegex = jsonConvert.convert<String>(json['replaceRegex']);
	if (replaceRegex != null) {
		sourceRuleContent.replaceRegex = replaceRegex;
	}
	final String? nextContentUrl = jsonConvert.convert<String>(json['nextContentUrl']);
	if (nextContentUrl != null) {
		sourceRuleContent.nextContentUrl = nextContentUrl;
	}
	return sourceRuleContent;
}

Map<String, dynamic> $SourceRuleContentToJson(SourceRuleContent entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['content'] = entity.content;
	data['replaceRegex'] = entity.replaceRegex;
	data['nextContentUrl'] = entity.nextContentUrl;
	return data;
}

SourceRuleExplore $SourceRuleExploreFromJson(Map<String, dynamic> json) {
	final SourceRuleExplore sourceRuleExplore = SourceRuleExplore();
	final String? jsonContent = jsonConvert.convert<String>(json['jsonContent']);
	if (jsonContent != null) {
		sourceRuleExplore.jsonContent = jsonContent;
	}
	final String? author = jsonConvert.convert<String>(json['author']);
	if (author != null) {
		sourceRuleExplore.author = author;
	}
	final String? bookList = jsonConvert.convert<String>(json['bookList']);
	if (bookList != null) {
		sourceRuleExplore.bookList = bookList;
	}
	final String? bookUrl = jsonConvert.convert<String>(json['bookUrl']);
	if (bookUrl != null) {
		sourceRuleExplore.bookUrl = bookUrl;
	}
	final String? coverUrl = jsonConvert.convert<String>(json['coverUrl']);
	if (coverUrl != null) {
		sourceRuleExplore.coverUrl = coverUrl;
	}
	final String? intro = jsonConvert.convert<String>(json['intro']);
	if (intro != null) {
		sourceRuleExplore.intro = intro;
	}
	final String? name = jsonConvert.convert<String>(json['name']);
	if (name != null) {
		sourceRuleExplore.name = name;
	}
	final String? lastChapter = jsonConvert.convert<String>(json['lastChapter']);
	if (lastChapter != null) {
		sourceRuleExplore.lastChapter = lastChapter;
	}
	final String? kind = jsonConvert.convert<String>(json['kind']);
	if (kind != null) {
		sourceRuleExplore.kind = kind;
	}
	return sourceRuleExplore;
}

Map<String, dynamic> $SourceRuleExploreToJson(SourceRuleExplore entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['jsonContent'] = entity.jsonContent;
	data['author'] = entity.author;
	data['bookList'] = entity.bookList;
	data['bookUrl'] = entity.bookUrl;
	data['coverUrl'] = entity.coverUrl;
	data['intro'] = entity.intro;
	data['name'] = entity.name;
	data['lastChapter'] = entity.lastChapter;
	data['kind'] = entity.kind;
	return data;
}

SourceRuleReview $SourceRuleReviewFromJson(Map<String, dynamic> json) {
	final SourceRuleReview sourceRuleReview = SourceRuleReview();
	return sourceRuleReview;
}

Map<String, dynamic> $SourceRuleReviewToJson(SourceRuleReview entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	return data;
}

SourceRuleToc $SourceRuleTocFromJson(Map<String, dynamic> json) {
	final SourceRuleToc sourceRuleToc = SourceRuleToc();
	final String? jsonContent = jsonConvert.convert<String>(json['jsonContent']);
	if (jsonContent != null) {
		sourceRuleToc.jsonContent = jsonContent;
	}
	final String? chapterList = jsonConvert.convert<String>(json['chapterList']);
	if (chapterList != null) {
		sourceRuleToc.chapterList = chapterList;
	}
	final String? chapterName = jsonConvert.convert<String>(json['chapterName']);
	if (chapterName != null) {
		sourceRuleToc.chapterName = chapterName;
	}
	final String? chapterUrl = jsonConvert.convert<String>(json['chapterUrl']);
	if (chapterUrl != null) {
		sourceRuleToc.chapterUrl = chapterUrl;
	}
	final String? nextTocUrl = jsonConvert.convert<String>(json['nextTocUrl']);
	if (nextTocUrl != null) {
		sourceRuleToc.nextTocUrl = nextTocUrl;
	}
	return sourceRuleToc;
}

Map<String, dynamic> $SourceRuleTocToJson(SourceRuleToc entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['jsonContent'] = entity.jsonContent;
	data['chapterList'] = entity.chapterList;
	data['chapterName'] = entity.chapterName;
	data['chapterUrl'] = entity.chapterUrl;
	data['nextTocUrl'] = entity.nextTocUrl;
	return data;
}