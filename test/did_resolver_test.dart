import 'package:collection/collection.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zetrix_vc_flutter/src/models/did/verification_method.dart';
import 'package:zetrix_vc_flutter/src/models/did/zid_resolver_response.dart';
import 'package:zetrix_vc_flutter/src/services/did_resolver_service.dart';
import 'package:zetrix_vc_flutter/zetrix_vc_flutter.dart';

void main() {
  final BasicMessageProtocol basicMessageProtocol = BasicMessageProtocol();
  group('Basic Message module', () {
    test('should create, pack, and unpack  a basicmessage correctly', () async {
      final ZidResolverResponse result = await DidResolverService(
              resolverUrl: 'https://zid-resolver.myegdev.com/1.0/identifiers')
          .resolveZid(
              'did:zid:f28d6476a55ce9198c6531df9a36149894ea6b1df075c77ec3784f7c838cebfc');

      final verificationMethodsJson =
          result.didDocument?['verificationMethod'] as List<dynamic>?;

      final List<VerificationMethod> verificationMethods =
          verificationMethodsJson?.map((item) {
                return VerificationMethod.fromJson(
                    item as Map<String, dynamic>);
              }).toList() ??
              [];

      if (verificationMethods == null || verificationMethods.isEmpty) {
        throw Exception('No verification methods found in DID Document.');
      }

      final matchingVm = verificationMethods.firstWhereOrNull(
        (VerificationMethod vm) =>
            vm.type == 'Ed25519VerificationKey2020' &&
            vm.additionalFields['publicKeyHex'] ==
                'b001f28d6476a55ce9198c6531df9a36149894ea6b1df075c77ec3784f7c838cebfccbe0c3f4',
      );

      if (matchingVm == null) {
        throw Exception('ED25519_KEY_NOT_MATCH');
      }

      // return matchingVm.id;

      final createBasicMessage = basicMessageProtocol.createBasicMessage(
        from: "did:example:alice",
        to: "did:example:bob",
        content: "Hi Bob! How are you?",
      );

      final Map<String, dynamic> packAuthMsg = packAuthCrypt(
        senderPrivKeyStr:
            "privBve6bpkpdM4jHTkNnDRbVg8DYtizNubhzaYtD37GHsvFghckrNDm",
        recipientPubKeyBase58: "8Vo5BCHe41B4RdaFmYubxZLKo8oj6AwRsP3rK2bv63Bf",
        skid: "did:example:alice#key-2",
        kid: "did:example:bob#key-2",
        message: createBasicMessage,
      );

      final Map<String, dynamic> unpackAuthMsg = unpackAuthCrypt(
        jwe: packAuthMsg,
        receiverPrivKeyStr:
            "privBtpaUECfDNku8K8RJgGptKRL24c365AbFHXEctRMDJGTntWkPmJD",
        senderPubKeyBase58: "CxSNscV5tJDhqAPoGaWz4ZVwaGxKyQPbbp4fwH67iDSH",
      );

      expect(unpackAuthMsg['from'], equals("did:example:alice"));
      expect((unpackAuthMsg['to'] as List).first, equals("did:example:bob"));
      expect(unpackAuthMsg['body']['content'], equals("Hi Bob! How are you?"));
      expect(unpackAuthMsg['type'],
          equals("https://didcomm.org/basicmessage/2.0/message"));
    });
  });
}
