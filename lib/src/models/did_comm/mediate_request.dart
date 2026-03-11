import 'package:json_annotation/json_annotation.dart';

part 'mediate_request.g.dart';

@JsonSerializable()
class MediateRequest {
  final String id;
  final String typ;
  final String type;
  final Map<String, dynamic> body;
  final String from;
  final List<String> to;
  @JsonKey(name: 'created_time')
  final int createdTime;

  MediateRequest({
    required this.id,
    required this.typ,
    required this.type,
    required this.body,
    required this.from,
    required this.to,
    required this.createdTime,
  });

  factory MediateRequest.fromJson(Map<String, dynamic> json) =>
      _$MediateRequestFromJson(json);

  Map<String, dynamic> toJson() => _$MediateRequestToJson(this);
}
