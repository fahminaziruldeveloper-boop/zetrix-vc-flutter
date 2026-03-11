import 'package:json_annotation/json_annotation.dart';

part 'download_vc_request.g.dart';

@JsonSerializable()
class DownloadVcRequest {
  final String vcId;
  final bool isIssuer;
  final String signVcId;

  DownloadVcRequest({
    required this.vcId,
    required this.isIssuer,
    required this.signVcId,
  });

  factory DownloadVcRequest.fromJson(Map<String, dynamic> json) =>
      _$DownloadVcRequestFromJson(json);

  Map<String, dynamic> toJson() => _$DownloadVcRequestToJson(this);
}
