// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'propose_presentation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProposePresentation _$ProposePresentationFromJson(Map<String, dynamic> json) =>
    ProposePresentation(
      id: json['id'] as String,
      pthid: json['pthid'] as String,
      typ: json['typ'] as String,
      type: json['type'] as String,
      from: json['from'] as String,
      to: (json['to'] as List<dynamic>).map((e) => e as String).toList(),
      createdTime: (json['created_time'] as num).toInt(),
      body: ProposePresentationBody.fromJson(
          json['body'] as Map<String, dynamic>),
      attachments: (json['attachments'] as List<dynamic>)
          .map((e) =>
              ProposePresentationAttachment.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ProposePresentationToJson(
        ProposePresentation instance) =>
    <String, dynamic>{
      'id': instance.id,
      'pthid': instance.pthid,
      'typ': instance.typ,
      'type': instance.type,
      'from': instance.from,
      'to': instance.to,
      'created_time': instance.createdTime,
      'body': instance.body.toJson(),
      'attachments': instance.attachments.map((e) => e.toJson()).toList(),
    };

ProposePresentationBody _$ProposePresentationBodyFromJson(
        Map<String, dynamic> json) =>
    ProposePresentationBody(
      goalCode: json['goal_code'] as String,
      comment: json['comment'] as String,
    );

Map<String, dynamic> _$ProposePresentationBodyToJson(
        ProposePresentationBody instance) =>
    <String, dynamic>{
      'goal_code': instance.goalCode,
      'comment': instance.comment,
    };

ProposePresentationAttachment _$ProposePresentationAttachmentFromJson(
        Map<String, dynamic> json) =>
    ProposePresentationAttachment(
      id: json['id'] as String,
      mediaType: json['media_type'] as String,
      data: ProposePresentationData.fromJson(
          json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ProposePresentationAttachmentToJson(
        ProposePresentationAttachment instance) =>
    <String, dynamic>{
      'id': instance.id,
      'media_type': instance.mediaType,
      'data': instance.data.toJson(),
    };

ProposePresentationData _$ProposePresentationDataFromJson(
        Map<String, dynamic> json) =>
    ProposePresentationData(
      json: json['json'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$ProposePresentationDataToJson(
        ProposePresentationData instance) =>
    <String, dynamic>{
      'json': instance.json,
    };
