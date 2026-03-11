import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:bs58/bs58.dart';
import 'package:zetrix_vc_flutter/src/models/encryption/x25519_key_pair.dart';
import 'package:zetrix_vc_flutter/src/utils/tools.dart';
import 'package:zetrix_vc_flutter/zetrix_vc_flutter.dart';

void main() {
  EncryptionUtils encryptionUtils = EncryptionUtils();
  group('packAuthCrypt', () {
    test('should produce a valid JWE structure', () {
      final senderPrivateKeyBase58 = 'privBwvjqYDzWJcmcLCeJkcPPyKeepSNzZNzJQGsNr8shi9cLpenM5nc';
      final X25519KeyPair sender = generateX25519KeypairFromPrivKey(encryptionUtils.parsePrivateKey(senderPrivateKeyBase58));

      // Generate dummy X25519 public key for recipient (32 bytes)
      final X25519KeyPair receiver = generateX25519KeypairFromPrivKey(encryptionUtils.parsePrivateKey('privBtD17dp9sY1NC3LsTtiLY7kfmG2AofozJEVCxNtmNEk2aaTs9Rkf'));
      final recipientPublicKeyBase58 =
          base58.encode(Uint8List.fromList(receiver.publicKey));

      const skid = 'did:example:sender';
      const kid = 'did:example:recipient#key-1';
      const message = 'Hello, DIDComm!';

      // Run the function
      final result = packAuthCrypt(
        senderPrivKeyStr: senderPrivateKeyBase58,
        recipientPubKeyBase58: recipientPublicKeyBase58,
        skid: skid,
        kid: kid,
        message: message,
      );

      Tools.logDebug(result);

      // Top-level keys
      expect(result, contains('protected'));
      expect(result, contains('recipients'));
      expect(result, contains('iv'));
      expect(result, contains('ciphertext'));
      expect(result, contains('tag'));

      // Protected header should be a base64url string
      final protected = result['protected'];
      expect(protected, isA<String>());

      // Recipients array
      final recipients = result['recipients'];
      expect(recipients, isA<List>());
      expect(recipients.length, greaterThan(0));

      final recipient = recipients.first;
      expect(recipient, isA<Map>());
      expect(recipient, contains('encrypted_key'));
      expect(recipient['header'], contains('kid'));

      // Encrypted values should be base64url strings
      expect(result['iv'], isA<String>());
      expect(result['ciphertext'], isA<String>());
      expect(result['tag'], isA<String>());
    });
  });
}
