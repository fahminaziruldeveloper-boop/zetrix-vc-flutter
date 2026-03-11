import 'package:json_annotation/json_annotation.dart';

// part 'verification_method.g.dart';

@JsonSerializable(explicitToJson: true)
class VerificationMethod {
  final String id;
  final String type;
  final String? controller;

  /// Flexible storage for any additional fields
  final Map<String, dynamic> additionalFields;

  VerificationMethod({
    required this.id,
    required this.type,
    this.controller,
    this.additionalFields = const {},
  });



  factory VerificationMethod.fromJson(Map<String, dynamic> json) {
    // Extract known fields:
    final id = json['id'] as String;
    final type = json['type'] as String;
    final controller = json['controller'] as String?;

    // Remove known fields to keep only unknowns:
    final remaining = Map<String, dynamic>.from(json)
      ..remove('id')
      ..remove('type')
      ..remove('controller');

    return VerificationMethod(
      id: id,
      type: type,
      controller: controller,
      additionalFields: remaining,
    );
  }

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'id': id,
      'type': type,
    };

    if (controller != null) {
      json['controller'] = controller;
    }

    json.addAll(additionalFields);

    return json;
  }
}
