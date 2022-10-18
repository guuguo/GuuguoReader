import 'package:read_info/generated/json/base/json_convert_content.dart';
import 'package:read_info/bean/entity/source_header_entity.dart';

SourceHeaderEntity $SourceHeaderEntityFromJson(Map<String, dynamic> json) {
	final SourceHeaderEntity sourceHeaderEntity = SourceHeaderEntity();
	final String? userAgent = jsonConvert.convert<String>(json['User-Agent']);
	if (userAgent != null) {
		sourceHeaderEntity.userAgent = userAgent;
	}
	return sourceHeaderEntity;
}

Map<String, dynamic> $SourceHeaderEntityToJson(SourceHeaderEntity entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['User-Agent'] = entity.userAgent;
	return data;
}