// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'input_descriptor.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

InputDescriptor _$InputDescriptorFromJson(Map<String, dynamic> json) =>
    InputDescriptor(
      id: json['id'] as String,
      schema: (json['schema'] as List<dynamic>)
          .map((e) => Schema.fromJson(e as Map<String, dynamic>))
          .toList(),
      constraints:
          Constraints.fromJson(json['constraints'] as Map<String, dynamic>),
      group:
          (json['group'] as List<dynamic>?)?.map((e) => e as String).toList(),
      name: json['name'] as String?,
      purpose: json['purpose'] as String?,
    );

Map<String, dynamic> _$InputDescriptorToJson(InputDescriptor instance) =>
    <String, dynamic>{
      'id': instance.id,
      'schema': instance.schema.map((e) => e.toJson()).toList(),
      'constraints': instance.constraints.toJson(),
      'group': instance.group,
      'name': instance.name,
      'purpose': instance.purpose,
    };
