// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mediate_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MediateRequest _$MediateRequestFromJson(Map<String, dynamic> json) =>
    MediateRequest(
      id: json['id'] as String,
      typ: json['typ'] as String,
      type: json['type'] as String,
      body: json['body'] as Map<String, dynamic>,
      from: json['from'] as String,
      to: (json['to'] as List<dynamic>).map((e) => e as String).toList(),
      createdTime: (json['created_time'] as num).toInt(),
    );

Map<String, dynamic> _$MediateRequestToJson(MediateRequest instance) =>
    <String, dynamic>{
      'id': instance.id,
      'typ': instance.typ,
      'type': instance.type,
      'body': instance.body,
      'from': instance.from,
      'to': instance.to,
      'created_time': instance.createdTime,
    };
