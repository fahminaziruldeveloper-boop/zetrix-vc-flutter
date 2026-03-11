// DCQL-specific exceptions thrown by [DcqlVpService].

/// Thrown when the wallet has no Verifiable Credential whose type list
/// satisfies all of the `vct_values` required by the presentation request.
class DcqlMatchException implements Exception {
  /// Human-readable description of why the match failed.
  final String message;

  const DcqlMatchException(this.message);

  @override
  String toString() => 'DcqlMatchException: $message';
}

/// Thrown when a required claim path is not found in the credential subject.
///
/// [path] is the dot-joined DCQL path that could not be resolved
/// (e.g. `"credentialSubject.identityCardMalaysia.icNo"`).
class ClaimNotFoundException implements Exception {
  /// Dot-joined path that was not present in the VC.
  final String path;

  const ClaimNotFoundException(this.path);

  @override
  String toString() =>
      'ClaimNotFoundException: required field "$path" not found in VC';
}

/// Thrown when BBS+ derived proof creation fails.
///
/// This wraps low-level FFI or library errors so callers can handle proof
/// generation failures uniformly without catching generic [Exception]s.
class ProofCreationException implements Exception {
  /// Developer-facing description of the failure.
  final String message;

  /// Optional underlying cause (native error, stack trace, etc.).
  final Object? cause;

  const ProofCreationException(this.message, {this.cause});

  @override
  String toString() =>
      'ProofCreationException: $message${cause != null ? ' (cause: $cause)' : ''}';
}

/// Thrown when a credential's computed value does not satisfy the filter range
/// in the presentation request (e.g. `age < minimum`).
///
/// Surface this to the user as: "You do not meet the requirements".
class RangeProofFailException implements Exception {
  /// Name of the field that failed the range check.
  final String fieldName;

  /// The computed numeric value.
  final num value;

  /// The minimum required (may be null if only a maximum was set).
  final num? minimum;

  /// The maximum allowed (may be null if only a minimum was set).
  final num? maximum;

  const RangeProofFailException({
    required this.fieldName,
    required this.value,
    this.minimum,
    this.maximum,
  });

  @override
  String toString() {
    final bounds = [
      if (minimum != null) 'min=$minimum',
      if (maximum != null) 'max=$maximum',
    ].join(', ');
    return 'RangeProofFailException: field "$fieldName" value=$value does not satisfy [$bounds]';
  }
}

/// Thrown when Ed25519 JWT signing fails.
class JwtSigningException implements Exception {
  /// Developer-facing description of the failure.
  final String message;

  /// Optional underlying cause.
  final Object? cause;

  const JwtSigningException(this.message, {this.cause});

  @override
  String toString() =>
      'JwtSigningException: $message${cause != null ? ' (cause: $cause)' : ''}';
}
