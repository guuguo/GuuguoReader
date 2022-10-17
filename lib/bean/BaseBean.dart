
import 'DateTimeParser.dart';

const _transformer0 = DateTimeParser();

///leancloud 实体基类
class BaseBean {
  /// Creates a copy of this object but with the given fields replaced with the
  /// new values.
  BaseBean({this.objectId, this.createdAt, this.updatedAt});

  ///json -> bean
  BaseBean.fromJson(Map<String, dynamic> json) {
    objectId = json['objectId'];
    createdAt = _transformer0.decode(json['createdAt'] as String?);
    updatedAt = _transformer0.decode(json['updatedAt'] as String?);
  }

  ///bean -> json
  void fromJson(Map<String, dynamic> json) {
    objectId = json['objectId'];
    createdAt = _transformer0.decode(json['createdAt'] as String?);
    updatedAt = _transformer0.decode(json['updatedAt'] as String?);
  }

  ///转成 json 字符串
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    toJsonThis(data);
    return data;
  }

  ///copyWith
  BaseBean copyWith({
    String? objectId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BaseBean(
      objectId: objectId ?? this.objectId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  ///实体id
  String? objectId;

  ///创建时间
  DateTime? createdAt;

  ///更新时间
  DateTime? updatedAt;

  ///toJsonThis
  Map<String, dynamic> toJsonThis(Map<String, dynamic> data) {
    data['objectId'] = objectId;
    data['createdAt'] = _transformer0.encode(createdAt);
    data['updatedAt'] = _transformer0.encode(updatedAt);
    return data;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BaseBean &&
          runtimeType == other.runtimeType &&
          objectId == other.objectId;

  @override
  int get hashCode => objectId.hashCode;
  @override
  String toString() {
    return 'BaseBean{objectId: $objectId, createdAt: $createdAt, updatedAt: $updatedAt}';
  }
}
