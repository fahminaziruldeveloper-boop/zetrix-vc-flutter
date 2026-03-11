// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'basic_message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BasicMessage _$BasicMessageFromJson(Map<String, dynamic> json) => BasicMessage(
      id: json['id'] as String,
      typ: json['typ'] as String,
      type: json['type'] as String,
      from: json['from'] as String,
      lang: json['lang'] as String,
      body: Map<String, String>.from(json['body'] as Map),
      to: (json['to'] as List<dynamic>).map((e) => e as String).toList(),
      createdTime: (json['createdTime'] as num).toInt(),
    );

Map<String, dynamic> _$BasicMessageToJson(BasicMessage instance) =>
    <String, dynamic>{
      'id': instance.id,
      'typ': instance.typ,
      'type': instance.type,
      'from': instance.from,
      'lang': instance.lang,
      'body': instance.body,
      'to': instance.to,
      'createdTime': instance.createdTime,
    };
