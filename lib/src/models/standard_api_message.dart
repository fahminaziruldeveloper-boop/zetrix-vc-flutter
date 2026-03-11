import 'package:json_annotation/json_annotation.dart';

part 'standard_api_message.g.dart';

@JsonSerializable()
class StandardApiMessage {
  final String type;
  final int errorCode;
  final String message;

  StandardApiMessage({
    required this.type,
    required this.errorCode,
    required this.message,
  });

  factory StandardApiMessage.fromJson(Map<String, dynamic> json) =>
      _$StandardApiMessageFromJson(json);

  Map<String, dynamic> toJson() => _$StandardApiMessageToJson(this);

  bool get isError => type.toUpperCase() == 'ERROR';
}
