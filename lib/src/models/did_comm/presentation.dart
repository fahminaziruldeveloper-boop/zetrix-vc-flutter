import 'package:json_annotation/json_annotation.dart';

part 'presentation.g.dart';

@JsonSerializable(explicitToJson: true)
class Presentation {
  final String id;
  final String typ;
  final String type;
  final String from;
  final List<String> to;
  final String thid;
  @JsonKey(name: 'created_time')
  final int createdTime;
  final Map<String, dynamic> body;
  final List<PresentationAttachment> attachments;

  Presentation({
    required this.id,
    required this.typ,
    required this.type,
    required this.from,
    required this.to,
    required this.thid,
    required this.createdTime,
    required this.body,
    required this.attachments,
  });

  factory Presentation.fromJson(Map<String, dynamic> json) =>
      _$PresentationFromJson(json);

  Map<String, dynamic> toJson() =>
      _$PresentationToJson(this);
}

@JsonSerializable(explicitToJson: true)
class PresentationAttachment {
  final String id;
  @JsonKey(name: 'media_type')
  final String mediaType;
  final PresentationAttachmentData data;

  PresentationAttachment({
    required this.id,
    required this.mediaType,
    required this.data,
  });

  factory PresentationAttachment.fromJson(Map<String, dynamic> json) =>
      _$PresentationAttachmentFromJson(json);

  Map<String, dynamic> toJson() =>
      _$PresentationAttachmentToJson(this);
}

@JsonSerializable()
class PresentationAttachmentData {
  final Map<String, dynamic> json;

  PresentationAttachmentData({
    required this.json,
  });

  factory PresentationAttachmentData.fromJson(Map<String, dynamic> json) =>
      _$PresentationAttachmentDataFromJson(json);

  Map<String, dynamic> toJson() => _$PresentationAttachmentDataToJson(this);
}
