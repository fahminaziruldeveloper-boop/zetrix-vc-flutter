import 'package:json_annotation/json_annotation.dart';

part 'schema.g.dart';

@JsonSerializable()
class Schema {
  final String uri;
  final bool? required;

  Schema({required this.uri, this.required});

  factory Schema.fromJson(Map<String, dynamic> json) =>
      _$SchemaFromJson(json);

  Map<String, dynamic> toJson() => _$SchemaToJson(this);
}
