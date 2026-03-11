import 'package:json_annotation/json_annotation.dart';

part 'disclose.g.dart';

@JsonSerializable(explicitToJson: true)
class Disclose {
  final String id;
  final String typ;
  final String type;
  final String from;
  final DiscloseBody body;
  final List<String> to;
  final String thid;
  @JsonKey(name: 'created_time')
  final int createdTime;

  Disclose({
    required this.id,
    required this.typ,
    required this.type,
    required this.from,
    required this.body,
    required this.to,
    required this.thid,
    required this.createdTime,
  });

  factory Disclose.fromJson(Map<String, dynamic> json) =>
      _$DiscloseFromJson(json);

  Map<String, dynamic> toJson() => _$DiscloseToJson(this);
}

@JsonSerializable()
class DiscloseBody {
  final List<DisclosureItem> disclosures;

  DiscloseBody({
    required this.disclosures,
  });

  factory DiscloseBody.fromJson(Map<String, dynamic> json) =>
      _$DiscloseBodyFromJson(json);

  Map<String, dynamic> toJson() => _$DiscloseBodyToJson(this);
}

@JsonSerializable()
class DisclosureItem {
  @JsonKey(name: 'feature-type')
  final String featureType;
  final String id;

  DisclosureItem({
    required this.featureType,
    required this.id,
  });

  factory DisclosureItem.fromJson(Map<String, dynamic> json) =>
      _$DisclosureItemFromJson(json);

  Map<String, dynamic> toJson() => _$DisclosureItemToJson(this);
}
