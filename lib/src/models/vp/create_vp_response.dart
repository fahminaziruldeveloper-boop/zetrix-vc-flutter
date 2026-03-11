
import 'package:json_annotation/json_annotation.dart';

part 'create_vp_response.g.dart';


/// Represents the response received after creating a Verifiable Presentation (VP) blob.
/// 
/// This class is typically returned by the API endpoint responsible for VP blob creation.
/// It contains the unique identifier for the created blob and the blob data itself.
///
/// Example usage:
/// ```dart
/// final response = CreateVpResponse.fromJson(json);
/// print(response.blobId); // Access the blob identifier
/// print(response.blob);   // Access the blob data (usually a base64 or JSON string)
/// ```
@JsonSerializable(explicitToJson: true)
class CreateVpResponse {
  /// The unique identifier assigned to the created VP blob.
  final String blobId;
  /// The actual data of the VP blob, typically as a base64-encoded or JSON string.
  final String blob;

  /// Creates a [CreateVpResponse] instance.
  ///
  /// [blobId]: The unique identifier for the blob.
  /// [blob]: The blob data.
  CreateVpResponse({required this.blobId, required this.blob});

  /// Creates a [CreateVpResponse] instance from a JSON map.
  factory CreateVpResponse.fromJson(Map<String, dynamic> json) =>
      _$CreateVpResponseFromJson(json);

  /// Converts this [CreateVpResponse] instance to a JSON map.
  Map<String, dynamic> toJson() => _$CreateVpResponseToJson(this);
}