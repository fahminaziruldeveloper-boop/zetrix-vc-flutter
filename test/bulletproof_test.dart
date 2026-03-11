import 'package:flutter_test/flutter_test.dart';
import 'package:zetrix_vc_flutter/zetrix_vc_flutter.dart';
import 'package:zetrix_vc_flutter/frb_generated.dart';

/// Tests for Bulletproof range proofs
/// Matches Java BulletProofUtil test cases
void main() {
  late BulletproofService service;

  setUpAll(() async {
    // Initialize Rust bridge
    await RustLib.init();
    // Initialize service
    service = BulletproofService();
  });

  group('Bulletproof Utility Tests', () {
    test('scaleDecimal should match Java implementation', () {
      expect(BulletproofUtil.scaleDecimal(3.45, 2), 345);
      expect(BulletproofUtil.scaleDecimal(4.0, 2), 400);
      expect(BulletproofUtil.scaleDecimal(2.9, 2), 290);
      expect(BulletproofUtil.scaleDecimal(0.0, 2), 0);
    });

    test('unscaleDecimal should reverse scaleDecimal', () {
      expect(BulletproofUtil.unscaleDecimal(345, 2), 3.45);
      expect(BulletproofUtil.unscaleDecimal(400, 2), 4.0);
      expect(BulletproofUtil.unscaleDecimal(290, 2), 2.9);
    });

    test('calculateBitSize should return correct bit length', () {
      expect(BulletproofUtil.calculateBitSize(255), 8);
      expect(BulletproofUtil.calculateBitSize(256), 9);
      expect(BulletproofUtil.calculateBitSize(65535), 16);
    });

    test('recommendBitSize should return standard sizes', () {
      expect(BulletproofUtil.recommendBitSize(255), 8);
      expect(BulletproofUtil.recommendBitSize(256), 16);
      expect(BulletproofUtil.recommendBitSize(65536), 32);
    });

    test('calculateExpectedCommitments should match Java logic', () {
      // For min-max: 1 lower + 1 upper (if max != 0)
      expect(BulletproofUtil.calculateExpectedCommitments([0]), 1); // Only min
      expect(BulletproofUtil.calculateExpectedCommitments([100]), 2); // Min + max
      expect(BulletproofUtil.calculateExpectedCommitments([0, 100]), 3); // 1 + 2
    });
  });

  group('Single Range Proofs', () {
    test('generateSingleMinRangeProof - age >= 18', () async {
      final proof = await service.generateSingleMinRangeProof(
        value: 22,
        min: 18,
        bitSize: 32,
        domain: 'test-min-proof',
      );

      expect(proof.proofValue.startsWith('u'), true);
      expect(proof.commitments.length, greaterThan(0));
      expect(proof.bitSize, 32);

      final isValid = await service.verifyMultipleRangeProof(proof: proof);
      expect(isValid, true);
    });

    test('generateSingleMaxRangeProof - age <= 65', () async {
      final proof = await service.generateSingleMaxRangeProof(
        value: 22,
        max: 65,
        bitSize: 32,
        domain: 'test-max-proof',
      );

      expect(proof.proofValue.startsWith('u'), true);
      expect(proof.commitments.length, greaterThan(0));

      final isValid = await service.verifyMultipleRangeProof(proof: proof);
      expect(isValid, true);
    });

    test('generateSingleMinMaxRangeProof - 18 <= age <= 65', () async {
      final proof = await service.generateSingleMinMaxRangeProof(
        value: 25,
        min: 18,
        max: 65,
        bitSize: 32,
        domain: 'test-min-max-proof',
      );

      expect(proof.proofValue.startsWith('u'), true);
      expect(proof.commitments.length, 2); // Lower and upper bounds

      final isValid = await service.verifySingleMinMaxRangeProof(
        min: 18,
        max: 65,
        proof: proof,
      );
      expect(isValid, true);
    });

    test('should fail to generate proof for value below minimum', () async {
      expect(
        () => service.generateSingleMinRangeProof(value: 15, min: 18),
        throwsException,
      );
    });

    test('should fail to generate proof for value above maximum', () async {
      expect(
        () => service.generateSingleMaxRangeProof(value: 70, max: 65),
        throwsException,
      );
    });
  });

  group('Multiple Range Proofs - Matching Java Example', () {
    test('combined range proof for age and CGPA', () async {
      // Match Java example
      int decimalPlaces = 2;
      int cgpa = BulletproofUtil.scaleDecimal(3.45, decimalPlaces);
      int maxCgpa = BulletproofUtil.scaleDecimal(4.0, decimalPlaces);
      int minCgpa = BulletproofUtil.scaleDecimal(2.9, decimalPlaces);

      List<int> values = [22, cgpa]; // Age, CGPA
      List<int> mins = [18, minCgpa];
      List<int> maxs = [0, maxCgpa]; // 0 = no max for age

      final combinedProof = await service.generateMultipleMinMaxRangeProof(
        values: values,
        mins: mins,
        maxs: maxs,
        bitSize: 32,
        domain: 'combined-range-proof',
      );

      expect(combinedProof.proofValue.startsWith('u'), true);
      // 1 for age lower + 2 for CGPA (lower+upper) = 3 values, padded to 4
      expect(combinedProof.commitments.length, 4);

      for (final commitment in combinedProof.commitments) {
        expect(commitment.startsWith('u'), true);
      }

      final isValid = await service.verifyMultipleMinMaxRangeProof(
        mins: mins,
        maxs: maxs,
        proof: combinedProof,
      );
      expect(isValid, true);
    });

    test('generateMultipleMinRangeProof', () async {
      final proof = await service.generateMultipleMinRangeProof(
        values: [22, 30, 25],
        mins: [18, 18, 18],
        bitSize: 32,
        domain: 'multi-min-proof',
      );

      // Commitments are padded to power of 2 (3 -> 4)
      expect(proof.commitments.length, 4);

      final isValid = await service.verifyMultipleRangeProof(proof: proof);
      expect(isValid, true);
    });

    test('generateMultipleMaxRangeProof', () async {
      final proof = await service.generateMultipleMaxRangeProof(
        values: [22, 30, 25],
        maxs: [65, 65, 65],
        bitSize: 32,
        domain: 'multi-max-proof',
      );

      // Commitments are padded to power of 2 (3 -> 4)
      expect(proof.commitments.length, 4);

      final isValid = await service.verifyMultipleRangeProof(proof: proof);
      expect(isValid, true);
    });

    test('should fail with mismatched array lengths', () async {
      expect(
        () => service.generateMultipleMinMaxRangeProof(
          values: [22, 30],
          mins: [18],
          maxs: [65, 65],
        ),
        throwsArgumentError,
      );
    });
  });

  group('Proof Serialization', () {
    test('proof should serialize and deserialize', () async {
      final originalProof = await service.generateSingleMinMaxRangeProof(
        value: 25,
        min: 18,
        max: 65,
      );

      // Convert to JSON
      final json = originalProof.toJson();

      // Convert back from JSON
      final deserializedProof = BulletproofProof.fromJson(json);

      expect(deserializedProof.proofValue, originalProof.proofValue);
      expect(deserializedProof.commitments, originalProof.commitments);
      expect(deserializedProof.bitSize, originalProof.bitSize);
      expect(deserializedProof.domain, originalProof.domain);
    });
  });

  group('Edge Cases', () {
    test('proof with value at exact minimum', () async {
      final proof = await service.generateSingleMinRangeProof(
        value: 18,
        min: 18,
      );

      final isValid = await service.verifyMultipleRangeProof(proof: proof);
      expect(isValid, true);
    });

    test('proof with value at exact maximum', () async {
      final proof = await service.generateSingleMaxRangeProof(
        value: 65,
        max: 65,
      );

      final isValid = await service.verifyMultipleRangeProof(proof: proof);
      expect(isValid, true);
    });

    test('proof with only minimum constraint (max = 0)', () async {
      final proof = await service.generateSingleMinMaxRangeProof(
        value: 100,
        min: 18,
        max: 0, // No maximum
      );

      expect(proof.commitments.length, 1); // Only lower bound

      final isValid = await service.verifySingleMinMaxRangeProof(
        min: 18,
        max: 0,
        proof: proof,
      );
      expect(isValid, true);
    });
  });
}
