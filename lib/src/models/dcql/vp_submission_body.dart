import 'dart:convert';

/// The complete body ready to POST to `response_uri` (Step 3 of the wallet flow).
///
/// JSON serialization uses snake_case keys to match the verifier's API contract.
///
/// Example:
/// ```dart
/// final body = await DcqlVpService().createVPFromDCQL(...);
/// await dio.post(responseUri, data: body.toJson());
/// ```
class VpSubmissionBody {
  /// JWT-encoded Verifiable Presentation.
  ///
  /// Format: `base64url(header).base64url(payload).base64url(signature)`
  /// where `header = {"alg":"EdDSA"}` and `payload` is the VP JSON object.
  final String vpToken;

  /// Presentation ID echoed from the verifier request (`presentation_id`).
  // ignore: non_constant_identifier_names
  final String presentation_id;

  /// Presentation submission descriptor that maps the VP contents to the
  /// verifier's input descriptor requirements.
  final PresentationSubmission presentationSubmission;

  /// Base58-encoded Ed25519 public key of the holder wallet.
  final String ed25519PublicKey;

  /// Base58-encoded BBS+ (BLS12-381) public key of the holder wallet.
  final String bbsPublicKey;

  const VpSubmissionBody({
    required this.vpToken,
    // ignore: non_constant_identifier_names
    required this.presentation_id,
    required this.presentationSubmission,
    required this.ed25519PublicKey,
    required this.bbsPublicKey,
  });

  /// Serializes to the JSON map posted to the verifier.
  Map<String, dynamic> toJson() => {
        'vp_token': vpToken,
        'presentation_submission': presentationSubmission.toJson(),
        'presentation_id': presentation_id,
        'ed25519_public_key': ed25519PublicKey,
        'bbs_public_key': bbsPublicKey,
      };

  /// Pretty-prints the JSON body (useful for debugging / logging).
  @override
  String toString() =>
      const JsonEncoder.withIndent('  ').convert(toJson());
}

/// Describes how the VP contents map to the verifier's input descriptor.
///
/// Follows the Presentation Exchange specification:
/// https://identity.foundation/presentation-exchange/
class PresentationSubmission {
  /// UUID v4 uniquely identifying this submission.
  final String id;

  /// The `id` from the matching [CredentialRequirement] in the presentation
  /// request (e.g. `"did:zid:ba4f1fcf68831a5c..."`).
  final String definitionId;

  /// One entry per Verifiable Credential included in the VP.
  final List<DescriptorMap> descriptorMap;

  const PresentationSubmission({
    required this.id,
    required this.definitionId,
    required this.descriptorMap,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'definition_id': definitionId,
        'descriptor_map': descriptorMap.map((d) => d.toJson()).toList(),
      };
}

/// Maps a single Verifiable Credential in the VP to an input descriptor.
class DescriptorMap {
  /// The `id` field of the Verifiable Credential (`vc['id']`).
  final String id;

  /// Credential format, e.g. `"ldp_vc"`. Copied from the credential
  /// requirement's `format` field.
  final String format;

  /// JSONPath to the credential within the VP.
  ///
  /// `"$.verifiableCredential[0]"` for the first (and currently only) VC.
  final String path;

  const DescriptorMap({
    required this.id,
    required this.format,
    required this.path,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'format': format,
        'path': path,
      };
}
