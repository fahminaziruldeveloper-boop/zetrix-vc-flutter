import 'package:json_annotation/json_annotation.dart';
import 'standard_api_message.dart';

part 'standard_api_response.g.dart';

@JsonSerializable(genericArgumentFactories: true)
class StandardApiResponse<T> {
  final T? object;
  final List<StandardApiMessage>? messages;

  StandardApiResponse({
    required this.object,
    this.messages,
  });

  factory StandardApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) =>
      _$StandardApiResponseFromJson(json, fromJsonT);

  Map<String, dynamic> toJson(Object Function(T value) toJsonT) =>
      _$StandardApiResponseToJson(this, toJsonT);
}
