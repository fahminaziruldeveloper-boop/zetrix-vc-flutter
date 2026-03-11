// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ack.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Ack _$AckFromJson(Map<String, dynamic> json) => Ack(
      id: json['id'] as String,
      typ: json['typ'] as String,
      type: json['type'] as String,
      from: json['from'] as String,
      to: (json['to'] as List<dynamic>).map((e) => e as String).toList(),
      pthid: json['pthid'] as String,
      createdTime: (json['created_time'] as num).toInt(),
      body: AckBody.fromJson(json['body'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$AckToJson(Ack instance) => <String, dynamic>{
      'id': instance.id,
      'typ': instance.typ,
      'type': instance.type,
      'from': instance.from,
      'to': instance.to,
      'pthid': instance.pthid,
      'created_time': instance.createdTime,
      'body': instance.body.toJson(),
    };

AckBody _$AckBodyFromJson(Map<String, dynamic> json) => AckBody(
      status: json['status'] as String,
    );

Map<String, dynamic> _$AckBodyToJson(AckBody instance) => <String, dynamic>{
      'status': instance.status,
    };
