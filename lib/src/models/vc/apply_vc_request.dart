// File: src/models/vc/apply_vc_request.dart

import 'package:json_annotation/json_annotation.dart';

part 'apply_vc_request.g.dart';

@JsonSerializable(explicitToJson: true)
class ApplyVcRequest {
  final List<ApplyVcItem> data;
  final String signData;
  final String publicKey;
  String? x25519PublicKey;

  ApplyVcRequest({
    required this.data,
    required this.signData,
    required this.publicKey,
    this.x25519PublicKey,
  });

  factory ApplyVcRequest.fromJson(Map<String, dynamic> json) =>
      _$ApplyVcRequestFromJson(json);
  Map<String, dynamic> toJson() => _$ApplyVcRequestToJson(this);
}

@JsonSerializable()
class ApplyVcItem {
  final String templateId;
  final Map<String, dynamic> metadata;
  final String tds;

  ApplyVcItem({
    required this.templateId,
    required this.metadata,
    required this.tds,
  });

  factory ApplyVcItem.fromJson(Map<String, dynamic> json) =>
      _$ApplyVcItemFromJson(json);
  Map<String, dynamic> toJson() => _$ApplyVcItemToJson(this);
}
