import 'package:json_annotation/json_annotation.dart';

part 'propose_presentation.g.dart';

@JsonSerializable(explicitToJson: true)
class ProposePresentation {
  final String id;
  final String pthid;
  final String typ;
  final String type;
  final String from;
  final List<String> to;
  @JsonKey(name: 'created_time')
  final int createdTime;
  final ProposePresentationBody body;
  final List<ProposePresentationAttachment> attachments;

  ProposePresentation({
    required this.id,
    required this.pthid,
    required this.typ,
    required this.type,
    required this.from,
    required this.to,
    required this.createdTime,
    required this.body,
    required this.attachments,
  });

  factory ProposePresentation.fromJson(Map<String, dynamic> json) =>
      _$ProposePresentationFromJson(json);

  Map<String, dynamic> toJson() =>
      _$ProposePresentationToJson(this);
}

@JsonSerializable(explicitToJson: true)
class ProposePresentationBody {
  @JsonKey(name: 'goal_code')
  final String goalCode;
  final String comment;

  ProposePresentationBody({
    required this.goalCode,
    required this.comment,
  });

  factory ProposePresentationBody.fromJson(Map<String, dynamic> json) =>
      _$ProposePresentationBodyFromJson(json);

  Map<String, dynamic> toJson() => _$ProposePresentationBodyToJson(this);
}

@JsonSerializable(explicitToJson: true)
class ProposePresentationAttachment {
  final String id;
  @JsonKey(name: 'media_type')
  final String mediaType;
  final ProposePresentationData data;

  ProposePresentationAttachment({
    required this.id,
    required this.mediaType,
    required this.data,
  });

  factory ProposePresentationAttachment.fromJson(Map<String, dynamic> json) =>
      _$ProposePresentationAttachmentFromJson(json);

  Map<String, dynamic> toJson() =>
      _$ProposePresentationAttachmentToJson(this);
}

@JsonSerializable(explicitToJson: true)
class ProposePresentationData {
  final Map<String, dynamic> json;

  ProposePresentationData({
    required this.json,
  });

  factory ProposePresentationData.fromJson(Map<String, dynamic> json) =>
      _$ProposePresentationDataFromJson(json);

  Map<String, dynamic> toJson() => _$ProposePresentationDataToJson(this);
}
