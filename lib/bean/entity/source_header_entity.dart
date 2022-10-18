import 'package:read_info/generated/json/base/json_field.dart';
import 'package:read_info/generated/json/source_header_entity.g.dart';
import 'dart:convert';

@JsonSerializable()
class SourceHeaderEntity {

	@JSONField(name: "User-Agent")
	String? userAgent;
  
  SourceHeaderEntity();

  factory SourceHeaderEntity.fromJson(Map<String, dynamic> json) => $SourceHeaderEntityFromJson(json);

  Map<String, dynamic> toJson() => $SourceHeaderEntityToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}