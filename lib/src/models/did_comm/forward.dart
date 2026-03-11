import 'package:json_annotation/json_annotation.dart';

part 'forward.g.dart';

@JsonSerializable(explicitToJson: true)
class Forward {
  final String id;
  final String typ;
  final String type;
  final String from;
  final List<String> to;
  final int created_time;
  final ForwardBody body;
  final List<ForwardAttachment> attachments;

  Forward({
    required this.id,
    required this.typ,
    required this.type,
    required this.from,
    required this.to,
    required this.created_time,
    required this.body,
    required this.attachments,
  });

  factory Forward.fromJson(Map<String, dynamic> json) =>
      _$ForwardFromJson(json);

  Map<String, dynamic> toJson() => _$ForwardToJson(this);
}

@JsonSerializable(explicitToJson: true)
class ForwardBody {
  final String next;

  ForwardBody({
    required this.next,
  });

  factory ForwardBody.fromJson(Map<String, dynamic> json) =>
      _$ForwardBodyFromJson(json);

  Map<String, dynamic> toJson() => _$ForwardBodyToJson(this);
}

@JsonSerializable(explicitToJson: true)
class ForwardAttachment {
  final String id;
  final String base64;

  ForwardAttachment({
    required this.id,
    required this.base64,
  });

  factory ForwardAttachment.fromJson(Map<String, dynamic> json) =>
      _$ForwardAttachmentFromJson(json);

  Map<String, dynamic> toJson() => _$ForwardAttachmentToJson(this);
}
