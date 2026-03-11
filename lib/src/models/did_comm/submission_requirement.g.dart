// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'submission_requirement.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SubmissionRequirement _$SubmissionRequirementFromJson(
        Map<String, dynamic> json) =>
    SubmissionRequirement(
      name: json['name'] as String,
      purpose: json['purpose'] as String,
      rule: json['rule'] as String,
      from: json['from'] as String,
      count: (json['count'] as num?)?.toInt(),
    );

Map<String, dynamic> _$SubmissionRequirementToJson(
        SubmissionRequirement instance) =>
    <String, dynamic>{
      'name': instance.name,
      'purpose': instance.purpose,
      'rule': instance.rule,
      'from': instance.from,
      'count': instance.count,
    };
