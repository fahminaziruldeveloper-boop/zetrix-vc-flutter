import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated.dart';
import 'package:zetrix_vc_flutter/frb_generated.dart';
import 'package:zetrix_vc_flutter/src/models/bulletproof/bulletproof_proof.dart';
import 'package:flutter_rust_bridge/flutter_rust_bridge.dart' show Int64List;
/// Service for generating and verifying Bulletproof range proofs
/// 
/// Matches Java BulletProofUtil API for generating and verifying
/// zero-knowledge range proofs using the Rust bulletproofs library.
/// 
/// Example:
/// ```dart
/// // Initialize once at app startup
/// await RustLib.init();
/// 
/// final service = BulletproofService();
/// 
/// // Prove age >= 18 without revealing actual age
/// final proof = await service.generateSingleMinRangeProof(
///   value: 25,
///   min: 18,
/// );
/// 
/// // Verify the proof
/// final isValid = await service.verifyMultipleRangeProof(proof: proof);
/// ```
class BulletproofService {
  static const int defaultBitSize = 32;
  static const String defaultDomain = 'zetrix-vc';
  
  /// Get the Rust bridge API instance
  RustLibApi get _api => RustLib.instance.api;

  /// Generate single minimum range proof: value >= min
  Future<BulletproofProof> generateSingleMinRangeProof({
    required int value,
    required int min,
    int bitSize = defaultBitSize,
    String domain = defaultDomain,
  }) async {
    final result = await _api.crateApiGenerateSingleMinRangeProof(
      value: value,
      min: min,
      bitSize: bitSize,
      domain: domain,
    );
    
    if (!result.success) {
      throw Exception('Failed to generate proof: ${result.errorMessage}');
    }
    
    return BulletproofProof(
      proofValue: result.proofValue,
      commitments: result.commitments,
      bitSize: bitSize,
      domain: domain,
    );
  }

  /// Generate single maximum range proof: value <= max
  Future<BulletproofProof> generateSingleMaxRangeProof({
    required int value,
    required int max,
    int bitSize = defaultBitSize,
    String domain = defaultDomain,
  }) async {
    final result = await _api.crateApiGenerateSingleMaxRangeProof(
      value: value,
      max: max,
      bitSize: bitSize,
      domain: domain,
    );
    
    if (!result.success) {
      throw Exception('Failed to generate proof: ${result.errorMessage}');
    }
    
    return BulletproofProof(
      proofValue: result.proofValue,
      commitments: result.commitments,
      bitSize: bitSize,
      domain: domain,
    );
  }

  /// Generate single min-max range proof: min <= value <= max
  Future<BulletproofProof> generateSingleMinMaxRangeProof({
    required int value,
    required int min,
    required int max,
    int bitSize = defaultBitSize,
    String domain = defaultDomain,
  }) async {
    final result = await _api.crateApiGenerateSingleMinMaxRangeProof(
      value: value,
      min: min,
      max: max,
      bitSize: bitSize,
      domain: domain,
    );
    
    if (!result.success) {
      throw Exception('Failed to generate proof: ${result.errorMessage}');
    }
    
    return BulletproofProof(
      proofValue: result.proofValue,
      commitments: result.commitments,
      bitSize: bitSize,
      domain: domain,
    );
  }

  /// Generate multiple minimum range proofs: values[i] >= mins[i]
  Future<BulletproofProof> generateMultipleMinRangeProof({
    required List<int> values,
    required List<int> mins,
    int bitSize = defaultBitSize,
    String domain = defaultDomain,
  }) async {
    if (values.length != mins.length) {
      throw ArgumentError('Values and mins must have the same length');
    }
    
    final result = await _api.crateApiGenerateMultipleMinRangeProof(
      values: Int64List.fromList(values),
      mins: Int64List.fromList(mins),
      bitSize: bitSize,
      domain: domain,
    );
    
    if (!result.success) {
      throw Exception('Failed to generate proof: ${result.errorMessage}');
    }
    
    return BulletproofProof(
      proofValue: result.proofValue,
      commitments: result.commitments,
      bitSize: bitSize,
      domain: domain,
    );
  }

  /// Generate multiple maximum range proofs: values[i] <= maxs[i]
  Future<BulletproofProof> generateMultipleMaxRangeProof({
    required List<int> values,
    required List<int> maxs,
    int bitSize = defaultBitSize,
    String domain = defaultDomain,
  }) async {
    if (values.length != maxs.length) {
      throw ArgumentError('Values and maxs must have the same length');
    }
    
    final result = await _api.crateApiGenerateMultipleMaxRangeProof(
      values: Int64List.fromList(values),
      maxs: Int64List.fromList(maxs),
      bitSize: bitSize,
      domain: domain,
    );
    
    if (!result.success) {
      throw Exception('Failed to generate proof: ${result.errorMessage}');
    }
    
    return BulletproofProof(
      proofValue: result.proofValue,
      commitments: result.commitments,
      bitSize: bitSize,
      domain: domain,
    );
  }

  /// Generate multiple min-max range proofs: mins[i] <= values[i] <= maxs[i]
  /// Use max=0 to indicate no maximum constraint (only minimum)
  Future<BulletproofProof> generateMultipleMinMaxRangeProof({
    required List<int> values,
    required List<int> mins,
    required List<int> maxs,
    int bitSize = defaultBitSize,
    String domain = defaultDomain,
  }) async {
    if (values.length != mins.length || values.length != maxs.length) {
      throw ArgumentError('Values, mins, and maxs must have the same length');
    }
    
    final result = await _api.crateApiGenerateMultipleMinMaxRangeProof(
      values: Int64List.fromList(values),
      mins: Int64List.fromList(mins),
      maxs: Int64List.fromList(maxs),
      bitSize: bitSize,
      domain: domain,
    );
    
    if (!result.success) {
      throw Exception('Failed to generate proof: ${result.errorMessage}');
    }
    
    return BulletproofProof(
      proofValue: result.proofValue,
      commitments: result.commitments,
      bitSize: bitSize,
      domain: domain,
    );
  }

  /// Verify a bulletproof range proof
  Future<bool> verifyMultipleRangeProof({
    required BulletproofProof proof,
  }) async {
    final result = await _api.crateApiVerifyMultipleRangeProof(
      bitSize: proof.bitSize,
      proofValue: proof.proofValue,
      commitments: proof.commitments,
      domain: proof.domain,
    );
    
    return result.isValid;
  }

  /// Verify a single min-max range proof
  Future<bool> verifySingleMinMaxRangeProof({
    required int min,
    required int max,
    required BulletproofProof proof,
  }) async {
    final result = await _api.crateApiVerifySingleMinMaxRangeProof(
      min: min,
      max: max,
      bitSize: proof.bitSize,
      proofValue: proof.proofValue,
      commitments: proof.commitments,
      domain: proof.domain,
    );
    
    return result.isValid;
  }

  /// Verify multiple min-max range proofs
  Future<bool> verifyMultipleMinMaxRangeProof({
    required List<int> mins,
    required List<int> maxs,
    required BulletproofProof proof,
  }) async {
    if (mins.length != maxs.length) {
      throw ArgumentError('Mins and maxs must have the same length');
    }
    
    final result = await _api.crateApiVerifyMultipleMinMaxRangeProof(
      mins: Int64List.fromList(mins),
      maxs: Int64List.fromList(maxs),
      bitSize: proof.bitSize,
      proofValue: proof.proofValue,
      commitments: proof.commitments,
      domain: proof.domain,
    );
    
    return result.isValid;
  }
}
