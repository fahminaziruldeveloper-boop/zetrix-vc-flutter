import 'package:json_annotation/json_annotation.dart';

part 'range_proof.g.dart';

/// A model representing a Bulletproof Range Proof for Verifiable Presentations.
///
/// Range proofs enable proving that certain credential attributes fall within
/// specific ranges without revealing the actual values. This is useful for
/// privacy-preserving verification scenarios like proving age > 18 without
/// revealing the exact age.
///
/// **Key Properties:**
/// - [type]: The proof type, typically "BulletproofRangeProof2021".
/// - [proofValue]: Base64-encoded bulletproof proving values are within ranges.
/// - [bits]: The bit size used for range proofs (typically 8, 16, 32, or 64).
/// - [domain]: Domain separator for proof binding to specific context.
/// - [commitments]: List of base64-encoded Pedersen commitments to the values.
@JsonSerializable(explicitToJson: true, includeIfNull: false)
class RangeProof {
  /// The type of the range proof.
  ///
  /// Should be "BulletproofRangeProof2021" for bulletproof-based proofs.
  final String? type;

  /// Base64-encoded proof value.
  ///
  /// Contains the serialized bulletproof that proves all committed values
  /// fall within their specified ranges without revealing the actual values.
  final String proof;

  /// The bit size used for the range proof.
  ///
  /// Determines the maximum range that can be proven. Common values:
  /// - 8 bits: range [0, 255]
  /// - 16 bits: range [0, 65535]
  /// - 32 bits: range [0, 4294967295]
  /// - 64 bits: range [0, 2^64-1]
  final int bits;

  /// Domain separator for binding the proof to a specific context.
  ///
  /// Prevents proof reuse across different domains or applications.
  /// Should be unique per use case (e.g., "age-verification", "income-proof").
  final String domain;

  /// List of base64-encoded Pedersen commitments.
  ///
  /// Each commitment corresponds to one attribute value being proven.
  /// Commitments are cryptographically binding but hiding, preserving privacy.
  final List<String> commitments;

  /// Constructs a new [RangeProof] instance.
  ///
  /// **Parameters:**
  /// - [type]: The proof type identifier.
  /// - [proof]: The serialized proof in base64 format.
  /// - [bits]: Bit size for the range proof.
  /// - [domain]: Domain binding string.
  /// - [commitments]: List of commitment values in base64 format.
  RangeProof({
    this.type,
    required this.proof,
    required this.bits,
    required this.domain,
    required this.commitments,
  });

  /// Creates a [RangeProof] from JSON.
  factory RangeProof.fromJson(Map<String, dynamic> json) =>
      _$RangeProofFromJson(json);

  /// Converts this [RangeProof] to JSON.
  Map<String, dynamic> toJson() => _$RangeProofToJson(this);
}
