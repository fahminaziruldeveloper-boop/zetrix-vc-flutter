import 'package:json_annotation/json_annotation.dart';

part 'ack.g.dart';

@JsonSerializable(explicitToJson: true)
class Ack {
  final String id;
  final String typ;
  final String type;
  final String from;
  final List<String> to;
  final String pthid;
  @JsonKey(name: 'created_time')
  final int createdTime;
  final AckBody body;

  Ack({
    required this.id,
    required this.typ,
    required this.type,
    required this.from,
    required this.to,
    required this.pthid,
    required this.createdTime,
    required this.body,
  });

  factory Ack.fromJson(Map<String, dynamic> json) =>
      _$AckFromJson(json);

  Map<String, dynamic> toJson() => _$AckToJson(this);
}

@JsonSerializable()
class AckBody {
  final String status;

  AckBody({
    required this.status,
  });

  factory AckBody.fromJson(Map<String, dynamic> json) =>
      _$AckBodyFromJson(json);

  Map<String, dynamic> toJson() => _$AckBodyToJson(this);
}
