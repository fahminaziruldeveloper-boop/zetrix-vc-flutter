// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'standard_api_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StandardApiResponse<T> _$StandardApiResponseFromJson<T>(
  Map<String, dynamic> json,
  T Function(Object? json) fromJsonT,
) =>
    StandardApiResponse<T>(
      object: _$nullableGenericFromJson(json['object'], fromJsonT),
      messages: (json['messages'] as List<dynamic>?)
          ?.map((e) => StandardApiMessage.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$StandardApiResponseToJson<T>(
  StandardApiResponse<T> instance,
  Object? Function(T value) toJsonT,
) =>
    <String, dynamic>{
      'object': _$nullableGenericToJson(instance.object, toJsonT),
      'messages': instance.messages,
    };

T? _$nullableGenericFromJson<T>(
  Object? input,
  T Function(Object? json) fromJson,
) =>
    input == null ? null : fromJson(input);

Object? _$nullableGenericToJson<T>(
  T? input,
  Object? Function(T value) toJson,
) =>
    input == null ? null : toJson(input);
