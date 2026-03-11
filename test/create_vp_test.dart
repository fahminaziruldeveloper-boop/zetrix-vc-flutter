import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:zetrix_vc_flutter/zetrix_vc_flutter.dart';

void main() {
  test('createVp returns VP JSON without range proof', () async {
    final vpService = ZetrixVpService(isMainnet: false);

    final vc = VerifiableCredential(
      context: ['https://www.w3.org/2018/credentials/v1'],
      type: ['VerifiableCredential', 'TestCredential'],
      issuer: 'did:example:issuer',
      credentialSubject: {
        'id': 'did:example:holder',
        'name': 'Alice',
        'age': 30,
      },
      proof: [],
    );

    final result = await vpService.createVp(
      vc,
      null, // revealAttribute
      'uBLS_PUBLIC_KEY', // blsPublicKey
      'HOLDER_PUB_KEY', // holderPublicKey
      'HOLDER_PRIV_KEY', // holderPrivateKey
      null, // rangeProofRequest
    );

    // Assert result is success and contains VP JSON
    result.when(
      success: (data) {
        expect(data, isNotNull);
        final vpJson = jsonDecode(data!);
        expect(vpJson['holder'], 'did:example:holder');
        expect(vpJson['verifiableCredential'], isNotNull);
        expect(vpJson['@context'], isNotNull);
      },
      failure: (error) => fail('createVp failed: $error'),
    );
  });
}
