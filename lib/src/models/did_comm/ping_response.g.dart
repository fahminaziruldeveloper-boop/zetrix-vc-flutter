// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ping_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PingResponse _$PingResponseFromJson(Map<String, dynamic> json) => PingResponse(
      id: json['id'] as String,
      typ: json['typ'] as String,
      type: json['type'] as String,
      from: json['from'] as String,
      to: (json['to'] as List<dynamic>).map((e) => e as String).toList(),
      createdTime: (json['created_time'] as num).toInt(),
      thid: json['thid'] as String,
      body: json['body'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$PingResponseToJson(PingResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'typ': instance.typ,
      'type': instance.type,
      'from': instance.from,
      'to': instance.to,
      'created_time': instance.createdTime,
      'thid': instance.thid,
      'body': instance.body,
    };
