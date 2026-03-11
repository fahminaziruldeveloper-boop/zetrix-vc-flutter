import 'package:json_annotation/json_annotation.dart';

part 'submission_requirement.g.dart';

@JsonSerializable()
class SubmissionRequirement {
  final String name;
  final String purpose;
  final String rule;
  final String from;
  final int? count;

  SubmissionRequirement({
    required this.name,
    required this.purpose,
    required this.rule,
    required this.from,
    this.count,
  });

  factory SubmissionRequirement.fromJson(Map<String, dynamic> json) =>
      _$SubmissionRequirementFromJson(json);

  Map<String, dynamic> toJson() => _$SubmissionRequirementToJson(this);
}
