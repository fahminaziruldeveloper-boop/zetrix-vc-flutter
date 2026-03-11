import 'package:json_annotation/json_annotation.dart';

part 'apply_vc_response.g.dart';

@JsonSerializable()
class ApplyVcResponse {
  final String vcId;
  final String status;

  ApplyVcResponse({
    required this.vcId,
    required this.status,
  });

  factory ApplyVcResponse.fromJson(Map<String, dynamic> json) =>
      _$ApplyVcResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ApplyVcResponseToJson(this);
}
