import 'package:json_annotation/json_annotation.dart';
import 'package:zetrix_vc_flutter/src/models/did_comm/constraints.dart';
import 'package:zetrix_vc_flutter/src/models/did_comm/schema.dart';

part 'input_descriptor.g.dart';

@JsonSerializable(explicitToJson: true)
class InputDescriptor {
  final String id;
  final List<Schema> schema;
  final Constraints constraints;
  final List<String>? group;
  final String? name;
  final String? purpose;

  InputDescriptor({
    required this.id,
    required this.schema,
    required this.constraints,
    this.group,
    this.name,
    this.purpose,
  });

  factory InputDescriptor.fromJson(Map<String, dynamic> json) =>
      _$InputDescriptorFromJson(json);

  Map<String, dynamic> toJson() => _$InputDescriptorToJson(this);
}