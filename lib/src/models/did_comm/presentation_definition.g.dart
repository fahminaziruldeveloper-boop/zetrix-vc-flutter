// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'presentation_definition.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PresentationDefinition _$PresentationDefinitionFromJson(
        Map<String, dynamic> json) =>
    PresentationDefinition(
      id: json['id'] as String,
      inputDescriptors: json['input_descriptors'],
      submissionRequirements: json['submission_requirements'],
      name: json['name'] as String?,
      purpose: json['purpose'] as String?,
      format: json['format'],
    );

Map<String, dynamic> _$PresentationDefinitionToJson(
        PresentationDefinition instance) =>
    <String, dynamic>{
      'id': instance.id,
      'input_descriptors': instance.inputDescriptors,
      'submission_requirements': instance.submissionRequirements,
      'name': instance.name,
      'purpose': instance.purpose,
      'format': instance.format,
    };
