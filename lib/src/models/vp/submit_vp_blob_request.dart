
import 'package:json_annotation/json_annotation.dart';

part 'submit_vp_blob_request.g.dart';

/// A data transfer object representing a request to submit a Verifiable Presentation (VP) blob.
/// 
/// Contains the required information for submitting a VP blob, including:
/// - [blobId]: The unique identifier of the VP blob.
/// - [ed25519SignData]: The Ed25519 signature data for the VP.
/// - [ed25519PubKey]: The Ed25519 public key associated with the signature.
/// 
/// This class supports JSON serialization and deserialization.
@JsonSerializable(explicitToJson: true)
class SubmitVpRequest {
  @JsonKey(name: 'blobId')
  /// The unique identifier for the blob associated with the request.
  final String blobId;

  @JsonKey(name: 'ed25519SignData')
  /// The hex-encoded signature data generated using the Ed25519 algorithm.
  /// This string represents the cryptographic signature of the data to be submitted.
  final String ed25519SignData;

  @JsonKey(name: 'ed25519PubKey')
  /// The public key in Ed25519 format, used for verifying signatures or encrypting data.
  final String ed25519PubKey;

  /// Creates a new instance of [SubmitVpRequest].
  ///
  /// This constructor is used to initialize the request data transfer object
  /// for submitting a Verifiable Presentation (VP) blob.
  ///
  /// Provide the required parameters to construct the request object.
  SubmitVpRequest({
    required this.blobId,
    required this.ed25519SignData,
    required this.ed25519PubKey,
  });

  /// Creates a new instance of [SubmitVpRequest] from a JSON map.
  ///
  /// Parses the provided [json] map and returns a [SubmitVpRequest] object
  /// with the corresponding data.
  factory SubmitVpRequest.fromJson(Map<String, dynamic> json) =>
      _$SubmitVpRequestFromJson(json);

  /// Converts this [SubmitVpRequest] instance into a JSON-compatible [Map].
  ///
  /// Returns a [Map] representation of the current object, suitable for
  /// serialization or network transmission.
  Map<String, dynamic> toJson() => _$SubmitVpRequestToJson(this);
}

