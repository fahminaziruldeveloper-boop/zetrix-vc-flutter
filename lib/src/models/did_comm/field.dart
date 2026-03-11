
import 'package:json_annotation/json_annotation.dart';

part 'field.g.dart';

@JsonSerializable()
class Field {
  final List<String> path;
  final String purpose;
  final dynamic filter;

  Field({
    required this.path,
    required this.purpose,
    this.filter,
  });
  factory Field.fromJson(Map<String, dynamic> json) =>
      _$FieldFromJson(json);

  Map<String, dynamic> toJson() => _$FieldToJson(this);
}