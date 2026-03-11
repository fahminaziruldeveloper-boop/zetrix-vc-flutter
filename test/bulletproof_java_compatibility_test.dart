import 'package:flutter_test/flutter_test.dart';
import 'package:zetrix_vc_flutter/zetrix_vc_flutter.dart';
import 'package:zetrix_vc_flutter/frb_generated.dart';

/// Tests matching Java BulletProofUtilTest exactly
/// Ensures Flutter/Rust implementation matches Java behavior
void main() {
  late BulletproofService service;

  setUpAll(() async {
    await RustLib.init();
    service = BulletproofService();
  });

  group('Java Compatibility Tests', () {
    test('testGenerateAndVerifySingleMinRangeProof', () async {
      // Java: long value = 25; long min = 18; int bitsize = 32;
      int value = 25;
      int min = 18;
      int bitSize = 32;
      String domain = 'test-domain';

      // Generate proof
      final proof = await service.generateSingleMinRangeProof(
        value: value,
        min: min,
        bitSize: bitSize,
        domain: domain,
      );

      // Java assertions:
      // - assertNotNull(proof)
      // - assertFalse(proof.getCommitments().isEmpty())
      // - assertEquals(1, proof.getCommitments().size())
      expect(proof.proofValue.isNotEmpty, true);
      expect(proof.commitments.isNotEmpty, true);
      expect(proof.commitments.length, 1,
          reason: 'Single min proof should have exactly 1 commitment');

      // Verify proof
      final isVerified = await service.verifyMultipleRangeProof(proof: proof);
      expect(isVerified, true, reason: 'Proof should be verified successfully');
    });

    test('testGenerateAndVerifyMultipleMinRangeProof', () async {
      // Java: long[] values = {25, 12121}; long[] mins = {18, 10000};
      List<int> values = [25, 12121];
      List<int> mins = [18, 10000];
      int bitSize = 32;
      String domain = 'test-domain';

      // Generate proof
      final proof = await service.generateMultipleMinRangeProof(
        values: values,
        mins: mins,
        bitSize: bitSize,
        domain: domain,
      );

      // Java assertions:
      // - assertEquals(values.length, proof.getCommitments().size())
      expect(proof.proofValue.isNotEmpty, true);
      expect(proof.commitments.isNotEmpty, true);
      expect(proof.commitments.length, values.length,
          reason:
              'Multiple min proof should have exactly ${values.length} commitments (2 is already power of 2, no padding)');

      // Verify proof
      final isVerified = await service.verifyMultipleRangeProof(proof: proof);
      expect(isVerified, true, reason: 'Proof should be verified successfully');
    });

    test('testGenerateAndVerifySingleMaxRangeProof', () async {
      // Java: long value = 25; long max = 100;
      int value = 25;
      int max = 100;
      int bitSize = 32;
      String domain = 'test-domain';

      // Generate proof
      final proof = await service.generateSingleMaxRangeProof(
        value: value,
        max: max,
        bitSize: bitSize,
        domain: domain,
      );

      // Java assertions:
      // - assertEquals(1, proof.getCommitments().size())
      expect(proof.proofValue.isNotEmpty, true);
      expect(proof.commitments.isNotEmpty, true);
      expect(proof.commitments.length, 1,
          reason: 'Single max proof should have exactly 1 commitment');

      // Verify proof
      final isVerified = await service.verifyMultipleRangeProof(proof: proof);
      expect(isVerified, true, reason: 'Proof should be verified successfully');
    });

    test('testGenerateAndVerifyMultipleMaxRangeProof', () async {
      // Java: long[] values = {25, 12121}; long[] maxs = {100, 50000};
      List<int> values = [25, 12121];
      List<int> maxs = [100, 50000];
      int bitSize = 32;
      String domain = 'test-domain';

      // Generate proof
      final proof = await service.generateMultipleMaxRangeProof(
        values: values,
        maxs: maxs,
        bitSize: bitSize,
        domain: domain,
      );

      // Java assertions:
      // - assertEquals(values.length, proof.getCommitments().size())
      expect(proof.proofValue.isNotEmpty, true);
      expect(proof.commitments.isNotEmpty, true);
      expect(proof.commitments.length, values.length,
          reason:
              'Multiple max proof should have exactly ${values.length} commitments (2 is already power of 2, no padding)');

      // Verify proof
      final isVerified = await service.verifyMultipleRangeProof(proof: proof);
      expect(isVerified, true, reason: 'Proof should be verified successfully');
    });

    test('testGenerateAndVerifySingleMinMaxRangeProof', () async {
      // Java: long value = 25; long min = 18; long max = 100;
      int value = 25;
      int min = 18;
      int max = 100;
      int bitSize = 32;
      String domain = 'test-domain';

      // Generate proof
      final proof = await service.generateSingleMinMaxRangeProof(
        value: value,
        min: min,
        max: max,
        bitSize: bitSize,
        domain: domain,
      );

      // Java assertions:
      // - assertEquals(2, proof.getCommitments().size())
      expect(proof.proofValue.isNotEmpty, true);
      expect(proof.commitments.isNotEmpty, true);
      expect(proof.commitments.length, 2,
          reason:
              'Single min-max proof should have exactly 2 commitments (1 for min, 1 for max)');

      // Verify proof
      final isVerified = await service.verifySingleMinMaxRangeProof(
        min: min,
        max: max,
        proof: proof,
      );
      expect(isVerified, true, reason: 'Proof should be verified successfully');
    });

    test('testGenerateAndVerifyMultipleMinMaxRangeProof', () async {
      // Java: long[] values = {25, 12121}; long[] mins = {18, 10000}; long[] maxs = {100, 50000};
      List<int> values = [25, 12121];
      List<int> mins = [18, 10000];
      List<int> maxs = [100, 50000];
      int bitSize = 32;
      String domain = 'test-domain';

      // Generate proof
      final proof = await service.generateMultipleMinMaxRangeProof(
        values: values,
        mins: mins,
        maxs: maxs,
        bitSize: bitSize,
        domain: domain,
      );

      // Java assertions:
      // - assertEquals(values.length * 2, proof.getCommitments().size())
      expect(proof.proofValue.isNotEmpty, true);
      expect(proof.commitments.isNotEmpty, true);
      expect(proof.commitments.length, values.length * 2,
          reason:
              'Multiple min-max proof should have exactly ${values.length * 2} commitments (2 values * 2 commitments each, 4 is already power of 2, no padding)');

      // Verify proof
      final isVerified = await service.verifyMultipleMinMaxRangeProof(
        mins: mins,
        maxs: maxs,
        proof: proof,
      );
      expect(isVerified, true, reason: 'Proof should be verified successfully');
    });
  });
}
