import 'package:json_annotation/json_annotation.dart';
import 'package:zetrix_vc_flutter/src/models/vc/proof.dart';

part 'verifiable_credential.g.dart';

/// A model representing a Verifiable Credential (VC) as defined by the W3C Verifiable Credentials standard.
///
/// A Verifiable Credential is a tamper-evident, cryptographically secure document containing claims
/// about a subject. It allows entities to present trusted information, issued by a credential issuer,
/// to verifiers.
///
/// **Key Properties:**
/// - [context]: JSON-LD context defining namespaces and terms used in the credential.
/// - [id]: A unique identifier for the credential.
/// - [type]: A list of semantic types describing the credential. Typically includes "VerifiableCredential".
/// - [issuer]: The identifier or DID of the entity that issued the credential.
/// - [issuanceDate]: The date and time when the credential was issued (in ISO 8601 format).
/// - [expirationDate]: The date and time when the credential expires (if applicable, in ISO 8601 format).
/// - [credentialSubject]: The subject of the credential, containing claims about the entity.
/// - [proof]: Cryptographic proof ensuring the validity and authenticity of the credential.
@JsonSerializable(explicitToJson: true, includeIfNull: false)
class VerifiableCredential {
  /// The JSON-LD context defining the semantic structure and terms of the credential.
  ///
  /// This field is represented using the `@context` key in the JSON-LD serialization.
  @JsonKey(name: '@context')
  final List<String>? context;

  /// A unique identifier for the credential.
  ///
  /// This identifier is used to uniquely identify a specific instance of a Verifiable Credential.
  final String? id;

  /// A list of semantic types describing the credential.
  ///
  /// The type list usually includes the term "VerifiableCredential" along with other
  /// context-specific terms that define the nature of the credential.
  final List<String>? type;

  /// The identifier or DID of the entity that issued the credential.
  ///
  /// The issuer plays a central role in establishing the credibility and trustworthiness of the credential.
  final String? issuer;

  /// The date and time when the credential was issued, in ISO 8601 format.
  ///
  /// Represents the point in time when the credential became valid.
  final String? validFrom;

  /// The date and time when the credential expires, in ISO 8601 format.
  ///
  /// If specified, the credential is considered invalid after this date.
  final String? validUntil;

  /// The subject of the credential containing claims about the entity being described.
  ///
  /// It includes key-value pairs representing attributes, such as a person's name or an organization's data.
  Map<String, dynamic>? credentialSubject;

  /// A cryptographic proof that ensures the validity and authenticity of the credential.
  ///
  /// The proof verifies the claims, proving they haven't been tampered with and are issued by a trusted entity.
  List<Proof>? proof;

  /// Constructs a new instance of [VerifiableCredential].
  ///
  /// **Parameters:**
  /// - [context]: The JSON-LD context for the credential.
  /// - [id]: A unique identifier for the credential.
  /// - [type]: The list of semantic types describing the credential.
  /// - [issuer]: The issuer identifier or DID.
  /// - [issuanceDate]: The issuance date of the credential in ISO 8601 format.
  /// - [expirationDate]: The expiration date of the credential in ISO 8601 format.
  /// - [credentialSubject]: The subject (claims) described in the credential.
  /// - [proof]: One or more cryptographic proofs validating the credential.
  VerifiableCredential({
    this.context,
    this.id,
    this.type,
    this.issuer,
    this.validFrom,
    this.validUntil,
    this.credentialSubject,
    this.proof,
  });

  /// Creates a [VerifiableCredential] object from a JSON structure.
  factory VerifiableCredential.fromJson(Map<String, dynamic> json) =>
      _$VerifiableCredentialFromJson(json);

  /// Converts the [VerifiableCredential] object into a JSON structure.
  Map<String, dynamic> toJson() => _$VerifiableCredentialToJson(this);
}
