import 'package:json_annotation/json_annotation.dart';
import 'package:zetrix_vc_flutter/src/models/did_comm/field.dart';

part 'constraints.g.dart';

@JsonSerializable(explicitToJson: true)
class Constraints {
  final List<Field> fields;

  @JsonKey(name: 'limit_disclosure')
  final String? limitDisclosure;

  Constraints({
    required this.fields,
    this.limitDisclosure,
  });

  factory Constraints.fromJson(Map<String, dynamic> json) =>
      _$ConstraintsFromJson(json);

  Map<String, dynamic> toJson() => _$ConstraintsToJson(this);
}