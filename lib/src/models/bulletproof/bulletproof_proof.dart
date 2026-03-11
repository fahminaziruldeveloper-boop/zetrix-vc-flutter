import 'package:collection/collection.dart';

/// Bulletproof range proof data
/// Matches Java Proof class structure
class BulletproofProof {
  /// Base64URL encoded proof with 'u' prefix
  final String proofValue;

  /// List of Base64URL encoded commitments with 'u' prefix
  final List<String> commitments;

  /// Number of bits used in the range proof (typically 32 or 64)
  final int bitSize;

  /// Domain separator used in the proof
  final String domain;

  const BulletproofProof({
    required this.proofValue,
    required this.commitments,
    required this.bitSize,
    required this.domain,
  });

  /// Convert to JSON for storage/transmission
  Map<String, dynamic> toJson() => {
        'proofValue': proofValue,
        'commitments': commitments,
        'bitSize': bitSize,
        'domain': domain,
      };

  /// Create from JSON
  factory BulletproofProof.fromJson(Map<String, dynamic> json) {
    return BulletproofProof(
      proofValue: json['proofValue'] as String,
      commitments: (json['commitments'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      bitSize: json['bitSize'] as int,
      domain: json['domain'] as String,
    );
  }

  @override
  String toString() {
    return 'BulletproofProof('
        'proofValue: ${proofValue.substring(0, proofValue.length.clamp(0, 20))}..., '
        'commitments: ${commitments.length} items, '
        'bitSize: $bitSize, '
        'domain: $domain)';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BulletproofProof &&
          runtimeType == other.runtimeType &&
          proofValue == other.proofValue &&
          const ListEquality().equals(commitments, other.commitments) &&
          bitSize == other.bitSize &&
          domain == other.domain;

  @override
  int get hashCode =>
      proofValue.hashCode ^
      commitments.hashCode ^
      bitSize.hashCode ^
      domain.hashCode;
}
