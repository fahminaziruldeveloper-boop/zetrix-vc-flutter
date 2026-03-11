// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'forward.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Forward _$ForwardFromJson(Map<String, dynamic> json) => Forward(
      id: json['id'] as String,
      typ: json['typ'] as String,
      type: json['type'] as String,
      from: json['from'] as String,
      to: (json['to'] as List<dynamic>).map((e) => e as String).toList(),
      created_time: (json['created_time'] as num).toInt(),
      body: ForwardBody.fromJson(json['body'] as Map<String, dynamic>),
      attachments: (json['attachments'] as List<dynamic>)
          .map((e) => ForwardAttachment.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ForwardToJson(Forward instance) => <String, dynamic>{
      'id': instance.id,
      'typ': instance.typ,
      'type': instance.type,
      'from': instance.from,
      'to': instance.to,
      'created_time': instance.created_time,
      'body': instance.body.toJson(),
      'attachments': instance.attachments.map((e) => e.toJson()).toList(),
    };

ForwardBody _$ForwardBodyFromJson(Map<String, dynamic> json) => ForwardBody(
      next: json['next'] as String,
    );

Map<String, dynamic> _$ForwardBodyToJson(ForwardBody instance) =>
    <String, dynamic>{
      'next': instance.next,
    };

ForwardAttachment _$ForwardAttachmentFromJson(Map<String, dynamic> json) =>
    ForwardAttachment(
      id: json['id'] as String,
      base64: json['base64'] as String,
    );

Map<String, dynamic> _$ForwardAttachmentToJson(ForwardAttachment instance) =>
    <String, dynamic>{
      'id': instance.id,
      'base64': instance.base64,
    };
