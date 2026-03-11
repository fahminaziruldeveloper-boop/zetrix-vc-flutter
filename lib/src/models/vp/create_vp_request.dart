import 'package:json_annotation/json_annotation.dart';
import 'package:zetrix_vc_flutter/src/models/vc/verifiable_credential.dart';

part 'create_vp_request.g.dart';

@JsonSerializable(explicitToJson: true)
class CreateVpRequest {
  final VerifiableCredential vc;
  final List<String>? revealAttribute;

  CreateVpRequest({
    required this.vc,
    this.revealAttribute,
  });


  factory CreateVpRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateVpRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CreateVpRequestToJson(this);
}
