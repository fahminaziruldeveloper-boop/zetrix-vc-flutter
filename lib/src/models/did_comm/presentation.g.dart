// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'presentation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Presentation _$PresentationFromJson(Map<String, dynamic> json) => Presentation(
      id: json['id'] as String,
      typ: json['typ'] as String,
      type: json['type'] as String,
      from: json['from'] as String,
      to: (json['to'] as List<dynamic>).map((e) => e as String).toList(),
      thid: json['thid'] as String,
      createdTime: (json['created_time'] as num).toInt(),
      body: json['body'] as Map<String, dynamic>,
      attachments: (json['attachments'] as List<dynamic>)
          .map(
              (e) => PresentationAttachment.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$PresentationToJson(Presentation instance) =>
    <String, dynamic>{
      'id': instance.id,
      'typ': instance.typ,
      'type': instance.type,
      'from': instance.from,
      'to': instance.to,
      'thid': instance.thid,
      'created_time': instance.createdTime,
      'body': instance.body,
      'attachments': instance.attachments.map((e) => e.toJson()).toList(),
    };

PresentationAttachment _$PresentationAttachmentFromJson(
        Map<String, dynamic> json) =>
    PresentationAttachment(
      id: json['id'] as String,
      mediaType: json['media_type'] as String,
      data: PresentationAttachmentData.fromJson(
          json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$PresentationAttachmentToJson(
        PresentationAttachment instance) =>
    <String, dynamic>{
      'id': instance.id,
      'media_type': instance.mediaType,
      'data': instance.data.toJson(),
    };

PresentationAttachmentData _$PresentationAttachmentDataFromJson(
        Map<String, dynamic> json) =>
    PresentationAttachmentData(
      json: json['json'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$PresentationAttachmentDataToJson(
        PresentationAttachmentData instance) =>
    <String, dynamic>{
      'json': instance.json,
    };
