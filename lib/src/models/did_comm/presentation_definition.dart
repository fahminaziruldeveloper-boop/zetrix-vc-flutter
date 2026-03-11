import 'package:json_annotation/json_annotation.dart';

part 'presentation_definition.g.dart';

@JsonSerializable(explicitToJson: true)
class PresentationDefinition {
  final String id;

  @JsonKey(name: 'input_descriptors')
  final dynamic inputDescriptors;

  @JsonKey(name: 'submission_requirements')
  final dynamic submissionRequirements;

  final String? name;
  final String? purpose;
  final dynamic format;

  PresentationDefinition({
    required this.id,
    required this.inputDescriptors,
    this.submissionRequirements,
    this.name,
    this.purpose,
    this.format,
  });

  factory PresentationDefinition.fromJson(Map<String, dynamic> json) =>
      _$PresentationDefinitionFromJson(json);

  Map<String, dynamic> toJson() => _$PresentationDefinitionToJson(this);
}
