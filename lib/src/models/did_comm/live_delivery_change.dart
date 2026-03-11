import 'package:json_annotation/json_annotation.dart';

part 'live_delivery_change.g.dart';

@JsonSerializable(explicitToJson: true)
class LiveDeliveryChange {
  final String id;
  final String typ;
  final String type;
  final String from;
  final List<String> to;
  final int createdTime;
  final LiveDeliveryChangeBody body;

  LiveDeliveryChange({
    required this.id,
    required this.typ,
    required this.type,
    required this.from,
    required this.to,
    required this.createdTime,
    required this.body,
  });

  factory LiveDeliveryChange.fromJson(Map<String, dynamic> json) =>
      _$LiveDeliveryChangeFromJson(json);

  Map<String, dynamic> toJson() => _$LiveDeliveryChangeToJson(this);
}

@JsonSerializable()
class LiveDeliveryChangeBody {
  @JsonKey(name: 'live_delivery')
  final bool liveDelivery;

  LiveDeliveryChangeBody({
    required this.liveDelivery,
  });

  factory LiveDeliveryChangeBody.fromJson(Map<String, dynamic> json) =>
      _$LiveDeliveryChangeBodyFromJson(json);

  Map<String, dynamic> toJson() => _$LiveDeliveryChangeBodyToJson(this);
}
