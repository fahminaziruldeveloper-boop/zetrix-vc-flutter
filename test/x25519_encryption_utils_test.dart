import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:crypto/crypto.dart';
import 'package:pinenacl/tweetnacl.dart';

import 'package:zetrix_vc_flutter/src/utils/x25519encryption_utils.dart';

void main() {
  group('computeApv', () {
    test('computes APV for single kid', () {
      final apv = computeApv(['abc']);
      final expected = base64Url.encode(
        sha256.convert(utf8.encode('abc')).bytes,
      ).replaceAll('=', '');
      expect(apv, expected);
    });

    test('computes APV for multiple kids sorted', () {
      final apv = computeApv(['kid2', 'kid1']);
      final concat = 'kid1.kid2';
      final expected = base64Url.encode(
        sha256.convert(utf8.encode(concat)).bytes,
      ).replaceAll('=', '');
      expect(apv, expected);
    });

    test('throws on empty kid list', () {
      expect(() => computeApv([]), throwsArgumentError);
    });
  });

  group('performECDH', () {
    test('computes shared secret matching tweetnacl.scalarMult', () {
      final alicePrivate = TweetNaCl.randombytes(32);
      final bobPrivate = TweetNaCl.randombytes(32);

      final alicePublic = Uint8List(32);
      TweetNaCl.crypto_scalarmult_base(alicePublic, alicePrivate);

      final bobPublic = Uint8List(32);
      TweetNaCl.crypto_scalarmult_base(bobPublic, bobPrivate);

      final shared1 = performECDH(alicePrivate, bobPublic);
      final shared2 = performECDH(bobPrivate, alicePublic);

      expect(shared1, equals(shared2));
      expect(shared1.length, equals(32));
    });
  });

  group('concatenate', () {
    test('concatenates two byte arrays', () {
      final a = Uint8List.fromList([1, 2, 3]);
      final b = Uint8List.fromList([4, 5, 6]);
      final result = concatenate(a, b);
      expect(result, equals([1, 2, 3, 4, 5, 6]));
    });
  });

  group('deriveKey', () {
    test('derives a 64-byte key', () {
      final sharedSecret = Uint8List(32);
      final enc = 'A256CBC-HS512';
      final apv = 'apv';
      final apu = 'apu';
      final derivedKey = deriveKey(sharedSecret, enc, apu, apv);
      expect(derivedKey.length, equals(64));
    });
  });

  group('generateIV', () {
    test('generates random 16-byte IV', () {
      final iv = generateIV();
      expect(iv.length, equals(16));
    });
  });

  group('encryptAES_CBC_HMAC_SHA512', () {
    test('encrypts plaintext and returns ciphertext + MAC', () {
      final plaintext = 'hello world';
      final derivedKey = Uint8List(64);
      for (var i = 0; i < 64; i++) {
        derivedKey[i] = i;
      }
      final iv = generateIV();

      final result = encryptAES_CBC_HMAC_SHA512(plaintext, derivedKey, iv);

      expect(result.length, greaterThan(64)); // Ciphertext + HMAC
    });
  });

  group('base64UrlEncodeNoPadding', () {
    test('encodes without padding', () {
      final bytes = utf8.encode('hello');
      final encoded = base64UrlEncodeNoPadding(Uint8List.fromList(bytes));
      expect(encoded.contains('='), isFalse);
    });
  });

  group('createAuthProtectedHeader', () {
    test('creates JSON header with auth fields', () {
      final header = createAuthProtectedHeader(
        'X25519',
        'OKP',
        'apuVal',
        'apvVal',
        Uint8List(32),
        'skidVal',
        'typVal',
        'algVal',
        'encVal',
      );

      final map = json.decode(header);
      expect(map['apu'], equals('apuVal'));
      expect(map['apv'], equals('apvVal'));
      expect(map['skid'], equals('skidVal'));
      expect(map['epk'], isA<Map>());
    });
  });

  group('createAnonProtectedHeader', () {
    test('creates JSON header without APU or skid', () {
      final header = createAnonProtectedHeader(
        'X25519',
        'OKP',
        'apvVal',
        Uint8List(32),
        'typVal',
        'algVal',
        'encVal',
      );

      final map = json.decode(header);
      expect(map['apv'], equals('apvVal'));
      expect(map.containsKey('apu'), isFalse);
      expect(map.containsKey('skid'), isFalse);
    });
  });

  group('aesKeyWrap', () {
    test('wraps CEK with KEK (simplified AES-ECB)', () {
      final kek = Uint8List(32);
      final cek = Uint8List(32);
      for (var i = 0; i < 32; i++) {
        kek[i] = i;
        cek[i] = 255 - i;
      }
      final wrapped = aesKeyWrap(kek, cek);
      expect(wrapped.length, equals(32));
    });

    test('throws if KEK length is invalid', () {
      expect(
        () => aesKeyWrap(Uint8List(16), Uint8List(32)),
        throwsArgumentError,
      );
    });

    test('throws if CEK length is invalid', () {
      expect(
        () => aesKeyWrap(Uint8List(32), Uint8List(16)),
        throwsArgumentError,
      );
    });
  });
}
