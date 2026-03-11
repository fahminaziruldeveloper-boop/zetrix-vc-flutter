import 'package:json_annotation/json_annotation.dart';

part 'basic_message.g.dart';

@JsonSerializable()
class BasicMessage {
  final String id;
  final String typ;
  final String type;
  final String from;
  final String lang;
  final Map<String, String> body;
  final List<String> to;
  final int createdTime;

  BasicMessage({
    required this.id,
    required this.typ,
    required this.type,
    required this.from,
    required this.lang,
    required this.body,
    required this.to,
    required this.createdTime,
  });

   /// JSON serialization boilerplate:
  factory BasicMessage.fromJson(Map<String, dynamic> json) =>
      _$BasicMessageFromJson(json);

  Map<String, dynamic> toJson() => _$BasicMessageToJson(this);
}
