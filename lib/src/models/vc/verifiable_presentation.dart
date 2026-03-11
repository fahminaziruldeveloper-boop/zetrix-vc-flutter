import 'package:json_annotation/json_annotation.dart';
import 'package:zetrix_vc_flutter/src/models/vc/proof.dart';
import 'package:zetrix_vc_flutter/src/models/vc/range_proof.dart';
import 'package:zetrix_vc_flutter/src/models/vc/verifiable_credential.dart';

part 'verifiable_presentation.g.dart';

/// A model representing a Verifiable Presentation (VP) as defined by the W3C Verifiable Credentials standard.
///
/// A Verifiable Presentation (VP) is a structured format for presenting one or more Verifiable Credentials (VC)
/// along with cryptographic proofs. It is typically used to allow a credential holder to share selected
/// credential attributes while preserving privacy.
///
/// **Key Properties:**
/// - [context]: Defines the JSON-LD context for the presentation, a required component for semantic interoperability.
/// - [type]: A list of types that describe the presentation. Typically includes "VerifiablePresentation".
/// - [holder]: The DID (Decentralized Identifier) or identifier of the entity presenting the VP.
/// - [verifiableCredential]: A list of [VerifiableCredential] objects contained in the presentation.
/// - [proof]: Cryptographic proof ensuring the validity of the presentation and its components.
@JsonSerializable(explicitToJson: true, includeIfNull: false)
class VerifiablePresentation {
  /// The JSON-LD context of the presentation, defining namespaces and terms.
  ///
  /// This field is represented using the `@context` key in the JSON-LD serialization.
  @JsonKey(name: '@context')
  final List<String>? context;

  /// The list of types associated with the presentation.
  ///
  /// Commonly includes "VerifiablePresentation". It helps in understanding the role
  /// and format of the entity. Each value in the list refers to a specific semantic type.
  final List<String>? type;

  /// The identifier or DID of the entity presenting the Verifiable Presentation.
  ///
  /// Represents the holder of the VP and allows for associating the presentation
  /// with the entity responsible for creating it.
  final String? holder;

  /// The list of verifiable credentials contained within the presentation.
  ///
  /// These credentials can optionally include proofs and other attributes, enabling
  /// selective disclosure of credential details.
  List<VerifiableCredential>? verifiableCredential;

  /// A cryptographic proof that ensures the authenticity and integrity of the presentation.
  ///
  /// The proof ensures the verifiability of the [context], [type], and the contained
  /// [verifiableCredential] using digital signatures.
  Proof? proof;

  /// Optional bulletproof range proof for privacy-preserving attribute verification.
  ///
  /// When included, allows proving that certain credential attributes fall within
  /// specified ranges without revealing the actual values. Useful for scenarios like
  /// proving age > 18, income within a bracket, or academic scores above threshold.
  RangeProof? rangeProof;

  /// Constructs a new instance of [VerifiablePresentation].
  ///
  /// **Parameters:**
  /// - [context]: The JSON-LD context defining the semantic structure of the presentation.
  /// - [type]: The list of semantic types associated with the presentation.
  /// - [holder]: The identifier or DID of the holder of the Verifiable Presentation.
  /// - [verifiableCredential]: A list of [VerifiableCredential] objects contained in the presentation.
  /// - [proof]: A cryptographic proof validating the authenticity of the presentation.
  /// - [rangeProof]: Optional bulletproof range proof for privacy-preserving verification.
  VerifiablePresentation({
    this.context,
    this.type,
    this.holder,
    this.verifiableCredential,
    this.proof,
    this.rangeProof,
  });

  /// Creates a [VerifiablePresentation] object from a JSON structure.
  factory VerifiablePresentation.fromJson(Map<String, dynamic> json) =>
      _$VerifiablePresentationFromJson(json);

  /// Converts the [VerifiablePresentation] object into a JSON structure.
  Map<String, dynamic> toJson() => _$VerifiablePresentationToJson(this);
}
