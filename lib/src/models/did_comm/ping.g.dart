// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ping.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Ping _$PingFromJson(Map<String, dynamic> json) => Ping(
      id: json['id'] as String,
      typ: json['typ'] as String,
      type: json['type'] as String,
      from: json['from'] as String,
      to: (json['to'] as List<dynamic>).map((e) => e as String).toList(),
      createdTime: (json['created_time'] as num).toInt(),
      body: PingBody.fromJson(json['body'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$PingToJson(Ping instance) => <String, dynamic>{
      'id': instance.id,
      'typ': instance.typ,
      'type': instance.type,
      'from': instance.from,
      'to': instance.to,
      'created_time': instance.createdTime,
      'body': instance.body.toJson(),
    };

PingBody _$PingBodyFromJson(Map<String, dynamic> json) => PingBody(
      responseRequested: json['response_requested'] as bool,
    );

Map<String, dynamic> _$PingBodyToJson(PingBody instance) => <String, dynamic>{
      'response_requested': instance.responseRequested,
    };
