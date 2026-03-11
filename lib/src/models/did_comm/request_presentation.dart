import 'package:json_annotation/json_annotation.dart';

part 'request_presentation.g.dart';

@JsonSerializable(explicitToJson: true)
class RequestPresentation {
  final String id;
  final String thid;
  final String typ;
  final String type;
  final String from;
  final List<String> to;
  @JsonKey(name: 'created_time')
  final int createdTime;
  final RequestPresentationBody body;
  final List<RequestPresentationAttachment> attachments;

  RequestPresentation({
    required this.id,
    required this.thid,
    required this.typ,
    required this.type,
    required this.from,
    required this.to,
    required this.createdTime,
    required this.body,
    required this.attachments,
  });

  factory RequestPresentation.fromJson(Map<String, dynamic> json) =>
      _$RequestPresentationFromJson(json);

  Map<String, dynamic> toJson() =>
      _$RequestPresentationToJson(this);
}

@JsonSerializable(explicitToJson: true)
class RequestPresentationBody {
  @JsonKey(name: 'goal_code')
  final String goalCode;
  final String comment;
  @JsonKey(name: 'will_confirm')
  final bool willConfirm;

  RequestPresentationBody({
    required this.goalCode,
    required this.comment,
    required this.willConfirm,
  });

  factory RequestPresentationBody.fromJson(Map<String, dynamic> json) =>
      _$RequestPresentationBodyFromJson(json);

  Map<String, dynamic> toJson() => _$RequestPresentationBodyToJson(this);
}

@JsonSerializable(explicitToJson: true)
class RequestPresentationAttachment {
  final String id;
  @JsonKey(name: 'media_type')
  final String mediaType;
  final String format;
  final RequestPresentationData data;

  RequestPresentationAttachment({
    required this.id,
    required this.mediaType,
    required this.format,
    required this.data,
  });

  factory RequestPresentationAttachment.fromJson(Map<String, dynamic> json) =>
      _$RequestPresentationAttachmentFromJson(json);

  Map<String, dynamic> toJson() =>
      _$RequestPresentationAttachmentToJson(this);
}

@JsonSerializable(explicitToJson: true)
class RequestPresentationData {
  final Map<String, dynamic> json;

  RequestPresentationData({
    required this.json,
  });

  factory RequestPresentationData.fromJson(Map<String, dynamic> json) =>
      _$RequestPresentationDataFromJson(json);

  Map<String, dynamic> toJson() => _$RequestPresentationDataToJson(this);
}
