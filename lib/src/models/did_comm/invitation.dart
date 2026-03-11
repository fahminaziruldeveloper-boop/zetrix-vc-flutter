import 'package:json_annotation/json_annotation.dart';

part 'invitation.g.dart';

@JsonSerializable()
class Invitation {
  final String id;
  final String type;
  final String from;
  final InvitationBody body;
  final List<InvitationAttachment>? attachments;

  Invitation({
    required this.id,
    required this.type,
    required this.from,
    required this.body,
    this.attachments,
  });

  factory Invitation.fromJson(Map<String, dynamic> json) =>
      _$InvitationFromJson(json);

  Map<String, dynamic> toJson() => _$InvitationToJson(this);
}

@JsonSerializable()
class InvitationBody {
  @JsonKey(name: 'goal_code')
  final String goalCode;

  final String goal;

  final List<String> accept;

  InvitationBody({
    required this.goalCode,
    required this.goal,
    required this.accept,
  });

  factory InvitationBody.fromJson(Map<String, dynamic> json) =>
      _$InvitationBodyFromJson(json);

  Map<String, dynamic> toJson() => _$InvitationBodyToJson(this);
}

@JsonSerializable()
class InvitationAttachment {
  final String id;
  @JsonKey(name: 'media_type')
  final String mediaType;
  final dynamic data;

  InvitationAttachment({
    required this.id,
    required this.mediaType,
    required this.data,
  });

  factory InvitationAttachment.fromJson(Map<String, dynamic> json) =>
      _$InvitationAttachmentFromJson(json);

  Map<String, dynamic> toJson() => _$InvitationAttachmentToJson(this);
}
