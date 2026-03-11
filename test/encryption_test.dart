import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import "package:hex/hex.dart";
import 'package:pinenacl/ed25519.dart' as nacl;
import 'package:zetrix_vc_flutter/src/utils/encoding_utils.dart';
import 'package:zetrix_vc_flutter/src/utils/tools.dart';
import 'package:zetrix_vc_flutter/zetrix_vc_flutter.dart';

void main() {
  EncryptionUtils encryption = EncryptionUtils();
  test('Generate keypair', () async {
    // final keyPair = EncryptionUtils();
    CreateAccount keypair = await encryption.generateKeyPair();

    assert(keypair.address is String);
    assert(keypair.address is String);
    assert(keypair.address is String);
  });

  test('EncryptionUtils from seed', () async {
    EncryptionUtils encryption = EncryptionUtils();
    String pubKey = await encryption.getEncPublicKey(
        'privBtnsbZV3Y3oG91QaeNhzNFpGbc9pmgdRnhKRs34ws2jg3gJqSMQo');

    Tools.logDebug(pubKey);

    expect(pubKey,
        'b0013333135690d479c3068a3a2ea495097e53ba32e900062e95cfbaf1ab06bc85848d689603');
  });

  test('Get address from public key', () async {
    EncryptionUtils encryption = EncryptionUtils();
    String address = encryption.getAddress(
        'b0013333135690d479c3068a3a2ea495097e53ba32e900062e95cfbaf1ab06bc85848d689603');

    expect(address, 'ZTX3Wk4JiwggfZquiTgj4KwY6wNRFNVTrbgxe');
  });

  test('Check address validation', () async {
    EncryptionUtils keypair = EncryptionUtils();
    bool valid = keypair.checkAddress('ZTX3Wk4JiwggfZquiTgj4KwY6wNRFNVTrbgxe');

    expect(valid, true);
  });

  test('Sign message', () async {
    SignMessage resp = await encryption.signMessage(
        "testABC", 'privBtnsbZV3Y3oG91QaeNhzNFpGbc9pmgdRnhKRs34ws2jg3gJqSMQo');

    expect(resp, isNot(null));
  });

  test('Sign blob', () async {
    SignBlob resp = await encryption.signBlob("43556C34",
        'privBtnsbZV3Y3oG91QaeNhzNFpGbc9pmgdRnhKRs34ws2jg3gJqSMQo');

    Tools.logDebug('signBlob: ${resp.signBlob}');
    expect(resp, isNot(null));
  });

  test('Verify message validation', () async {
    EncryptionUtils keypair = EncryptionUtils();

    List<int> signatureByte = HEX.decode(
        '6BF8535D178011A1F361AFDB21D43940010418CAEA83368AC48477C5C2302EDE0436CA90599237B3ADF02698B2F96348EA397E125909B9ED201D055AB241290D');
    Tools.logDebug(signatureByte);
    List<int> messageByte = utf8.encode('43556C34');
    bool valid = await keypair.verify(signatureByte, messageByte,
        'b0013333135690d479c3068a3a2ea495097e53ba32e900062e95cfbaf1ab06bc85848d689603');
    Tools.logDebug(valid);

    expect(valid, true);
  });

      test('Verify blob validation', () async {
    EncryptionUtils keypair = EncryptionUtils();

    List<int> signatureByte = HEX.decode(
        '693bd1b680baa91ff815acfbf6ad66f53bb7ded8c383e699ad91e8ca94979d795c23f8f089508f8dc93f637f3c12f8f2f1eca9bb951098f6fb6d85f60a138c0a');
    Tools.logDebug(signatureByte);
  
    List<int> messageByte = EncodingUtils.hexStringToBytes('43556C34');
  
    bool valid = await keypair.verify(signatureByte, messageByte,
        'b0013333135690d479c3068a3a2ea495097e53ba32e900062e95cfbaf1ab06bc85848d689603');
    Tools.logDebug(valid);

    expect(valid, true);
  });

  test('Pinenacl sign and verify', () {
    String message = 'abc123';

    Uint8List msgByte =
        utf8.encode(message);
    nacl.SignedMessage sig = encryption.naclSign(
        'privBtnsbZV3Y3oG91QaeNhzNFpGbc9pmgdRnhKRs34ws2jg3gJqSMQo', msgByte);

    Tools.logDebug('Signature Hex: ${HEX.encode(sig.signature)}');

    bool valid = encryption.naclVerify(sig.signature, msgByte,
        'b0013333135690d479c3068a3a2ea495097e53ba32e900062e95cfbaf1ab06bc85848d689603');

    expect(valid, true);
  });
}
