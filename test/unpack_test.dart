import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:pinenacl/tweetnacl.dart';
import 'package:zetrix_vc_flutter/zetrix_vc_flutter.dart';
import 'package:bs58/bs58.dart';

void main() {
  group('unpackAuthCrypt', () {
    test('decrypts packed message successfully', () {
      final encryptionUtils = EncryptionUtils();

      // Generate Ed25519 key pair sender
      final senderseed = encryptionUtils.parsePrivateKey(
          'privBve6bpkpdM4jHTkNnDRbVg8DYtizNubhzaYtD37GHsvFghckrNDm');
      final sendpk = Uint8List(32);
      final sendsk = Uint8List(64);
      TweetNaCl.crypto_sign_keypair(sendpk, sendsk, senderseed);
      final senderX25519PrivKey = sendsk.sublist(0, 32);
      final senderX25519PubKey = TweetNaCl.crypto_scalarmult_base(
        Uint8List(32), // output buffer
        senderX25519PrivKey, // secret scalar
      );

      final senderPubKeyBase58 = base58.encode(senderX25519PubKey);

      // Derive X25519 keypair receiver
      final recseed = encryptionUtils.parsePrivateKey(
          'privBtpaUECfDNku8K8RJgGptKRL24c365AbFHXEctRMDJGTntWkPmJD');
      final recpk = Uint8List(32);
      final recsk = Uint8List(64);
      TweetNaCl.crypto_sign_keypair(recpk, recsk, recseed);
      final recpX25519PrivKey = recsk.sublist(0, 32);
      final recpX25519PubKey = TweetNaCl.crypto_scalarmult_base(
        Uint8List(32), // output buffer
        recpX25519PrivKey, // secret scalar
      );

      final receiverPubKeyBase58 = base58.encode(recpX25519PubKey);

      // Create a sample message
      final payload = {
        'foo': 'bar',
        'count': 123,
      };

      // Now pack it
      final packed = packAuthCrypt(
        senderPrivKeyStr:
            'privBve6bpkpdM4jHTkNnDRbVg8DYtizNubhzaYtD37GHsvFghckrNDm',
        recipientPubKeyBase58: receiverPubKeyBase58,
        skid: 'did:example:sender',
        kid: 'did:example:receiver#key-1',
        message: jsonEncode(payload),
      );

      // Now unpack it
      final decrypted = unpackAuthCrypt(
        jwe: packed,
        receiverPrivKeyStr:
            'privBtpaUECfDNku8K8RJgGptKRL24c365AbFHXEctRMDJGTntWkPmJD',
        senderPubKeyBase58: senderPubKeyBase58,
      );

      expect(decrypted, isA<Map<String, dynamic>>());
      expect(decrypted['foo'], equals('bar'));
      expect(decrypted['count'], equals(123));
    });
  });

  test('unpackAuthCrypt works', () {
    const senderPrivKeyStr =
        'privBve6bpkpdM4jHTkNnDRbVg8DYtizNubhzaYtD37GHsvFghckrNDm';
    const recipientPubKeyBase58 =
        '8Vo5BCHe41B4RdaFmYubxZLKo8oj6AwRsP3rK2bv63Bf';
    const skid = 'did:example:alice#key-2';
    const kid = 'did:example:bob#key-2';

    final message = {
      "from": "did:example:alice",
      "to": ["did:example:bob"],
      "body": {"content": "Hi Bob! How are you?"},
      "type": "https://didcomm.org/basicmessage/2.0/message"
    };

    final jwe = packAuthCrypt(
      senderPrivKeyStr: senderPrivKeyStr,
      recipientPubKeyBase58: recipientPubKeyBase58,
      skid: skid,
      kid: kid,
      message: jsonEncode(message),
    );

    const receiverPrivKeyStr =
        'privBtpaUECfDNku8K8RJgGptKRL24c365AbFHXEctRMDJGTntWkPmJD';
    const senderPubKeyBase58 = 'CxSNscV5tJDhqAPoGaWz4ZVwaGxKyQPbbp4fwH67iDSH';

    final unpacked = unpackAuthCrypt(
      jwe: jwe,
      receiverPrivKeyStr: receiverPrivKeyStr,
      senderPubKeyBase58: senderPubKeyBase58,
    );

    expect(unpacked['from'], equals('did:example:alice'));
    expect(unpacked['to'][0], equals('did:example:bob'));
    expect(unpacked['body']['content'], equals('Hi Bob! How are you?'));
    expect(unpacked['type'],
        equals('https://didcomm.org/basicmessage/2.0/message'));
  });

  group('unpackAnonCrypt', () {
    test('decrypts packed anon message successfully', () {
      final encryptionUtils = EncryptionUtils();

      // Generate Ed25519 key pair for recipient
      final recSeed = encryptionUtils.parsePrivateKey(
          'privBtpaUECfDNku8K8RJgGptKRL24c365AbFHXEctRMDJGTntWkPmJD');

      final recPk = Uint8List(32);
      final recSk = Uint8List(64);
      TweetNaCl.crypto_sign_keypair(recPk, recSk, recSeed);

      final recpX25519PrivKey = recSk.sublist(0, 32);
      final recpX25519PubKey = TweetNaCl.crypto_scalarmult_base(
        Uint8List(32), // output buffer
        recpX25519PrivKey, // secret scalar
      );

      final receiverPubKeyBase58 = base58.encode(recpX25519PubKey);

      // Create message payload
      final message = {
        "from": "did:example:alice",
        "to": ["did:example:bob"],
        "body": {"content": "This is a secret message!"},
        "type": "https://didcomm.org/basicmessage/2.0/message"
      };

      // Pack anonymously
      final jwe = packAnonCrypt(
        recipientPubKeyBase58: receiverPubKeyBase58,
        kid: 'did:example:bob#key-2',
        message: jsonEncode(message),
      );

      // Now unpack
      final unpacked = unpackAnonCrypt(
        jwe: jwe,
        receiverPrivKeyStr:
            'privBtpaUECfDNku8K8RJgGptKRL24c365AbFHXEctRMDJGTntWkPmJD',
      );

      // Assertions
      expect(unpacked['from'], equals('did:example:alice'));
      expect(unpacked['to'][0], equals('did:example:bob'));
      expect(unpacked['body']['content'], equals('This is a secret message!'));
      expect(unpacked['type'],
          equals('https://didcomm.org/basicmessage/2.0/message'));
    });
  });
}
