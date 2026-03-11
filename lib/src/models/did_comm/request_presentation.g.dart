// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'request_presentation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RequestPresentation _$RequestPresentationFromJson(Map<String, dynamic> json) =>
    RequestPresentation(
      id: json['id'] as String,
      thid: json['thid'] as String,
      typ: json['typ'] as String,
      type: json['type'] as String,
      from: json['from'] as String,
      to: (json['to'] as List<dynamic>).map((e) => e as String).toList(),
      createdTime: (json['created_time'] as num).toInt(),
      body: RequestPresentationBody.fromJson(
          json['body'] as Map<String, dynamic>),
      attachments: (json['attachments'] as List<dynamic>)
          .map((e) =>
              RequestPresentationAttachment.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$RequestPresentationToJson(
        RequestPresentation instance) =>
    <String, dynamic>{
      'id': instance.id,
      'thid': instance.thid,
      'typ': instance.typ,
      'type': instance.type,
      'from': instance.from,
      'to': instance.to,
      'created_time': instance.createdTime,
      'body': instance.body.toJson(),
      'attachments': instance.attachments.map((e) => e.toJson()).toList(),
    };

RequestPresentationBody _$RequestPresentationBodyFromJson(
        Map<String, dynamic> json) =>
    RequestPresentationBody(
      goalCode: json['goal_code'] as String,
      comment: json['comment'] as String,
      willConfirm: json['will_confirm'] as bool,
    );

Map<String, dynamic> _$RequestPresentationBodyToJson(
        RequestPresentationBody instance) =>
    <String, dynamic>{
      'goal_code': instance.goalCode,
      'comment': instance.comment,
      'will_confirm': instance.willConfirm,
    };

RequestPresentationAttachment _$RequestPresentationAttachmentFromJson(
        Map<String, dynamic> json) =>
    RequestPresentationAttachment(
      id: json['id'] as String,
      mediaType: json['media_type'] as String,
      format: json['format'] as String,
      data: RequestPresentationData.fromJson(
          json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$RequestPresentationAttachmentToJson(
        RequestPresentationAttachment instance) =>
    <String, dynamic>{
      'id': instance.id,
      'media_type': instance.mediaType,
      'format': instance.format,
      'data': instance.data.toJson(),
    };

RequestPresentationData _$RequestPresentationDataFromJson(
        Map<String, dynamic> json) =>
    RequestPresentationData(
      json: json['json'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$RequestPresentationDataToJson(
        RequestPresentationData instance) =>
    <String, dynamic>{
      'json': instance.json,
    };
