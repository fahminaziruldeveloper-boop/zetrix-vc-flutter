// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'invitation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Invitation _$InvitationFromJson(Map<String, dynamic> json) => Invitation(
      id: json['id'] as String,
      type: json['type'] as String,
      from: json['from'] as String,
      body: InvitationBody.fromJson(json['body'] as Map<String, dynamic>),
      attachments: (json['attachments'] as List<dynamic>?)
          ?.map((e) => InvitationAttachment.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$InvitationToJson(Invitation instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'from': instance.from,
      'body': instance.body,
      'attachments': instance.attachments,
    };

InvitationBody _$InvitationBodyFromJson(Map<String, dynamic> json) =>
    InvitationBody(
      goalCode: json['goal_code'] as String,
      goal: json['goal'] as String,
      accept:
          (json['accept'] as List<dynamic>).map((e) => e as String).toList(),
    );

Map<String, dynamic> _$InvitationBodyToJson(InvitationBody instance) =>
    <String, dynamic>{
      'goal_code': instance.goalCode,
      'goal': instance.goal,
      'accept': instance.accept,
    };

InvitationAttachment _$InvitationAttachmentFromJson(
        Map<String, dynamic> json) =>
    InvitationAttachment(
      id: json['id'] as String,
      mediaType: json['media_type'] as String,
      data: json['data'],
    );

Map<String, dynamic> _$InvitationAttachmentToJson(
        InvitationAttachment instance) =>
    <String, dynamic>{
      'id': instance.id,
      'media_type': instance.mediaType,
      'data': instance.data,
    };
