import 'package:json_annotation/json_annotation.dart';

part 'ping_response.g.dart';

@JsonSerializable()
class PingResponse {
  final String id;
  final String typ;
  final String type;
  final String from;
  final List<String> to;
  @JsonKey(name: 'created_time')
  final int createdTime;
  final String thid;
  final Map<String, dynamic> body;

  PingResponse({
    required this.id,
    required this.typ,
    required this.type,
    required this.from,
    required this.to,
    required this.createdTime,
    required this.thid,
    required this.body,
  });

  factory PingResponse.fromJson(Map<String, dynamic> json) =>
      _$PingResponseFromJson(json);

  Map<String, dynamic> toJson() => _$PingResponseToJson(this);
}
