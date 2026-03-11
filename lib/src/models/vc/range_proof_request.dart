/// A request model for generating bulletproof range proofs for VP creation.
///
/// This class encapsulates the parameters needed to generate a bulletproof
/// range proof that proves credential attributes fall within specified ranges
/// without revealing their actual values.
///
/// **Example Usage:**
/// ```dart
/// final request = RangeProofRequest(
///   attributes: ['age', 'balance'],
///   minValues: [18, 1000],
///   maxValues: [150, 1000000],
///   bits: 32,
///   domain: 'financial-verification',
/// );
/// ```
class RangeProofRequest {
  /// List of attribute names from the credential to include in the range proof.
  ///
  /// These attributes must exist in the credential and have numeric values.
  /// The order of attributes corresponds to the order in [minValues] and [maxValues].
  final List<String> attributes;

  /// Minimum values for each attribute.
  ///
  /// The proof will demonstrate that each attribute value >= corresponding min value.
  /// Must have the same length as [attributes].
  final List<int> minValues;

  /// Maximum values for each attribute.
  ///
  /// The proof will demonstrate that each attribute value <= corresponding max value.
  /// Must have the same length as [attributes].
  final List<int> maxValues;

  /// Bit size for the range proof (8, 16, 32, or 64).
  ///
  /// Determines the maximum range that can be proven:
  /// - 8 bits: [0, 255]
  /// - 16 bits: [0, 65535]
  /// - 32 bits: [0, 4294967295]
  /// - 64 bits: [0, 2^64-1]
  ///
  /// Defaults to 32 if not specified.
  final int bits;

  /// Domain separator for binding the proof to a specific context.
  ///
  /// Prevents proof reuse across different applications or contexts.
  /// Should be a unique string identifying the verification scenario.
  final String domain;

  /// Constructs a new [RangeProofRequest].
  ///
  /// **Parameters:**
  /// - [attributes]: List of credential attribute names to prove.
  /// - [minValues]: Minimum allowed values for each attribute.
  /// - [maxValues]: Maximum allowed values for each attribute.
  /// - [bits]: Bit size for range proof (default: 32).
  /// - [domain]: Domain binding string for proof context.
  ///
  /// **Throws:**
  /// - [ArgumentError] if attributes, minValues, and maxValues have different lengths.
  RangeProofRequest({
    required this.attributes,
    required this.minValues,
    required this.maxValues,
    this.bits = 32,
    required this.domain,
  }) {
    if (attributes.length != minValues.length ||
        attributes.length != maxValues.length) {
      throw ArgumentError(
        'attributes, minValues, and maxValues must have the same length',
      );
    }
    for (int i = 0; i < attributes.length; i++) {
      // maxValues[i] == 0 is the sentinel for "no upper bound"
      if (maxValues[i] != 0 && minValues[i] > maxValues[i]) {
        throw ArgumentError(
          'minValues[$i] (${minValues[i]}) must be <= maxValues[$i] (${maxValues[i]})',
        );
      }
    }
  }
}
