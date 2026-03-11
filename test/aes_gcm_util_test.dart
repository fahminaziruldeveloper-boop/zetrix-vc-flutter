import 'dart:convert';
import 'dart:typed_data';
import 'package:cryptography/cryptography.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zetrix_vc_flutter/zetrix_vc_flutter.dart';

void main() {
  group('AesGcmUtil', () {
    late Uint8List sharedSecret;
    late SecretKey secretKey;

    setUpAll(() async {
      sharedSecret = Uint8List.fromList(utf8.encode('secret-key'));
      secretKey = await AesGcmUtil.deriveAesKey(sharedSecret);
    });

    test('deriveAesKey should produce a consistent 256-bit key', () async {

      final key1 = await AesGcmUtil.deriveAesKey(sharedSecret);
      final key2 = await AesGcmUtil.deriveAesKey(sharedSecret);

      final bytes1 = await key1.extractBytes();
      final bytes2 = await key2.extractBytes();

      expect(bytes1.length, 32);
      expect(bytes1, bytes2); // same input → same output
    });

    test('encrypt and decrypt should restore original message', () async {
      final originalText = 'hey';
      final plaintext = Uint8List.fromList(utf8.encode(originalText));

      final encrypted = await AesGcmUtil.encrypt(
        plaintext: plaintext,
        secretKey: secretKey,
      );

      expect(encrypted.length, greaterThan(plaintext.length));

      final decrypted = await AesGcmUtil.decrypt(
        ivCiphertextMac: encrypted,
        secretKey: secretKey,
      );

      expect(utf8.decode(decrypted), originalText);
    });

    test('decrypt should fail on tampered data', () async {
      final plaintext = Uint8List.fromList(utf8.encode('hello world'));
      final encrypted = await AesGcmUtil.encrypt(
        plaintext: plaintext,
        secretKey: secretKey,
      );

      // Modify 1 byte
      encrypted[15] ^= 0x01;

      expect(
        () async => await AesGcmUtil.decrypt(
          ivCiphertextMac: encrypted,
          secretKey: secretKey,
        ),
        throwsA(isA<SecretBoxAuthenticationError>()),
      );
    });

    test('decrypt should fail if IV length is wrong', () async {
      final plaintext = Uint8List.fromList(utf8.encode('hello world'));
      final encrypted = await AesGcmUtil.encrypt(
        plaintext: plaintext,
        secretKey: secretKey,
      );

      final corrupted = encrypted.sublist(1); // remove first byte (IV)

      expect(
        () async => await AesGcmUtil.decrypt(
          ivCiphertextMac: corrupted,
          secretKey: secretKey,
        ),
        throwsA(isA<SecretBoxAuthenticationError>()),
      );
    });
  });
}
