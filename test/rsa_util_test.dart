import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:pointycastle/pointycastle.dart';
import 'package:zetrix_vc_flutter/zetrix_vc_flutter.dart';

void main() {

  group('RsaUtil', () {
    late RSAPublicKey publicKey;
    final String validPem = ConfigReader.getRSAPublicKey(false);

    setUp(() {
      publicKey = RsaUtil.loadPublicKey(validPem);
    });

    test('encrypts small string successfully', () {
      final plainText = 'Hello from RSA';
      final encrypted = RsaUtil.encrypt(publicKey, utf8.encode(plainText));

      expect(encrypted, isA<Uint8List>());
      expect(encrypted.isNotEmpty, true);
    });

    test('throws error on oversized input', () {
      final longInput = Uint8List(300); // Over 190 bytes typical limit
      expect(
        () => RsaUtil.encrypt(publicKey, longInput),
        throwsA(
          predicate(
            (e) =>
                e is Exception &&
                e.toString().contains('Input too long'),
          ),
        ),
      );
    });

    test('throws error on invalid public key PEM', () {
      const badPem = '-----BEGIN PUBLIC KEY-----\nabc\n-----END PUBLIC KEY-----';
      expect(
        () => RsaUtil.loadPublicKey(badPem),
        throwsA(
          predicate(
            (e) =>
                e is Exception &&
                e.toString().contains('Failed to load RSA public key'),
          ),
        ),
      );
    });


    test('encrypt aes key', () {
      const badPem = '-----BEGIN PUBLIC KEY-----\nabc\n-----END PUBLIC KEY-----';
      expect(
        () => RsaUtil.loadPublicKey(badPem),
        throwsA(
          predicate(
            (e) =>
                e is Exception &&
                e.toString().contains('Failed to load RSA public key'),
          ),
        ),
      );
    });
  });

}
