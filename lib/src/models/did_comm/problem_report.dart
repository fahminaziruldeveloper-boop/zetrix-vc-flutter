import 'package:json_annotation/json_annotation.dart';

part 'problem_report.g.dart';

@JsonSerializable(explicitToJson: true)
class ProblemReport {
  final String id;
  final String type;
  final String pthid;
  final ProblemReportBody body;

  ProblemReport({
    required this.id,
    required this.type,
    required this.pthid,
    required this.body,
  });

  factory ProblemReport.fromJson(Map<String, dynamic> json) =>
      _$ProblemReportFromJson(json);

  Map<String, dynamic> toJson() => _$ProblemReportToJson(this);
}

@JsonSerializable(explicitToJson: true)
class ProblemReportBody {
  final String code;
  final String comment;

  ProblemReportBody({
    required this.code,
    required this.comment,
  });

  factory ProblemReportBody.fromJson(Map<String, dynamic> json) =>
      _$ProblemReportBodyFromJson(json);

  Map<String, dynamic> toJson() => _$ProblemReportBodyToJson(this);
}
