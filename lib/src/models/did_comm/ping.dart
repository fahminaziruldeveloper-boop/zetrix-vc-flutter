import 'package:json_annotation/json_annotation.dart';

part 'ping.g.dart';

@JsonSerializable(explicitToJson: true)
class Ping {
  final String id;
  final String typ;
  final String type;
  final String from;
  final List<String> to;
  @JsonKey(name: 'created_time')
  final int createdTime;
  final PingBody body;

  Ping({
    required this.id,
    required this.typ,
    required this.type,
    required this.from,
    required this.to,
    required this.createdTime,
    required this.body,
  });

  factory Ping.fromJson(Map<String, dynamic> json) =>
      _$PingFromJson(json);

  Map<String, dynamic> toJson() => _$PingToJson(this);
}

@JsonSerializable(explicitToJson: true)
class PingBody {
  @JsonKey(name: 'response_requested')
  final bool responseRequested;

  PingBody({
    required this.responseRequested,
  });

  factory PingBody.fromJson(Map<String, dynamic> json) =>
      _$PingBodyFromJson(json);

  Map<String, dynamic> toJson() => _$PingBodyToJson(this);
}
