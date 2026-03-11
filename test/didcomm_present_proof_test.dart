import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:zetrix_vc_flutter/zetrix_vc_flutter.dart';

void main() {
  final PresentProofProtocol presentProofProtocol = PresentProofProtocol();

  group('Present Proof module', () {
    test('should create a request-presentation correctly', () {
      // 1a. Create fields
      final field1 = presentProofProtocol.createField(
        ["\$.credentialSubject.drivingLicense.idNo"],
        "The driving license ID number must be provided.",
        null,
      );

      final field2 = presentProofProtocol.createField(
        ["\$.credentialSubject.drivingLicense.age"],
        "Prove that the individual is above 18 without disclosing the exact age.",
        {
          "type": "number",
          "minimum": 18,
        },
      );

      // 1b. Create schemas
      final schema1 = presentProofProtocol.createSchema(
        "https://www.w3.org/2018/credentials/v1",
        null,
      );

      final schema2 = presentProofProtocol.createSchema(
        "https://example.com/schemas/drivingLicense.json",
        true,
      );

      // 2a. Create input descriptor
      final descriptor = presentProofProtocol.createInputDescriptor(
        "driving-license-credential",
        null,
        null,
        "A",
        [schema1, schema2],
        "required",
        [field1, field2],
      );

      // 2b. Submission requirements (OPTIONAL)
      final submissionRequirements =
          presentProofProtocol.createSubmissionRequirement(
        "driving-license-submission-requirement",
        "The driving license must be provided.",
        "all",
        null,
        "A",
      );

      // 2c. Create format
      final format = presentProofProtocol.createFormat(
        "ldp_vp",
        ["Ed25519Signature2020", "BbsBlsSignatureProof2020"],
        null,
      );

      // 3. Create presentation definition
      final definition = presentProofProtocol.createPresentationDefinition(
        "driving-license-presentation-definition",
        descriptor,
        submissionRequirements,
        "Driving License Presentation Definition",
        "This presentation definition is used to verify the driving license.",
        format,
      );

      // 4. Create request presentation
      final request = presentProofProtocol.createRequestPresentation(
        "did:example:verifier",
        "did:example:prover",
        "abc123456",
        "verify_identity",
        "Requesting a presentation for verification.",
        true,
        definition,
      );

      // 5. Pack
      final packAuthMsg = packAuthCrypt(
        senderPrivKeyStr:
            "privBve6bpkpdM4jHTkNnDRbVg8DYtizNubhzaYtD37GHsvFghckrNDm",
        recipientPubKeyBase58: "8Vo5BCHe41B4RdaFmYubxZLKo8oj6AwRsP3rK2bv63Bf",
        skid: "did:example:verifier#key-2",
        kid: "did:example:prover#key-2",
        message: request,
      );

      // 6. Unpack
      final unpackAuthMsg = unpackAuthCrypt(
        jwe: packAuthMsg,
        receiverPrivKeyStr:
            "privBtpaUECfDNku8K8RJgGptKRL24c365AbFHXEctRMDJGTntWkPmJD",
        senderPubKeyBase58: "CxSNscV5tJDhqAPoGaWz4ZVwaGxKyQPbbp4fwH67iDSH",
      );

      expect(unpackAuthMsg['from'], equals("did:example:verifier"));
      expect((unpackAuthMsg['to'] as List).first, equals("did:example:prover"));
      expect(unpackAuthMsg['type'],
          equals("https://didcomm.org/present-proof/3.0/request-presentation"));
    });

    test('should create a propose-presentation correctly', () {
      final propose = presentProofProtocol.createProposePresentation(
        "did:example:prover",
        "did:example:verifier",
        "abc123456",
        "verify_identity",
        "Proposing a presentation for verification.",
        null,
      );

      final packAuthMsg = packAuthCrypt(
        senderPrivKeyStr:
            "privBtpaUECfDNku8K8RJgGptKRL24c365AbFHXEctRMDJGTntWkPmJD",
        recipientPubKeyBase58: "CxSNscV5tJDhqAPoGaWz4ZVwaGxKyQPbbp4fwH67iDSH",
        skid: "did:example:prover#key-2",
        kid: "did:example:verifier#key-2",
        message: propose,
      );

      final unpackAuthMsg = unpackAuthCrypt(
        jwe: packAuthMsg,
        receiverPrivKeyStr:
            "privBve6bpkpdM4jHTkNnDRbVg8DYtizNubhzaYtD37GHsvFghckrNDm",
        senderPubKeyBase58: "8Vo5BCHe41B4RdaFmYubxZLKo8oj6AwRsP3rK2bv63Bf",
      );

      expect(unpackAuthMsg['from'], equals("did:example:prover"));
      expect(
          (unpackAuthMsg['to'] as List).first, equals("did:example:verifier"));
      expect(unpackAuthMsg['type'],
          equals("https://didcomm.org/present-proof/3.0/propose-presentation"));
    });

    test('should create a presentation correctly', () {
      final vp = {
        "type": [
          "VerifiablePresentation",
        ],
        "holder":
            "did:zid:2c8c214c958e0f28e8e3aac60a38abd161e3135efa33bb1c4233e0c6a4518a17",
        "verifiableCredential": [], // simplify for this test
        "proof": {
          "type": "Ed25519Signature2020",
          "created": "2025-02-27T02:17:22.606197800Z",
          "proofPurpose": "assertionMethod",
          "verificationMethod":
              "did:zid:2c8c214c958e0f28e8e3aac60a38abd161e3135efa33bb1c4233e0c6a4518a17#controllerKey",
          "jws": "eyJhbGciOiJFZERTQSJ9..."
        }
      };

      final format = presentProofProtocol.createFormat(
        "ldp_vp",
        ["Ed25519Signature2020", "BbsBlsSignatureProof2020"],
        null,
      );

      final createVpSubmission = presentProofProtocol.createVpSubmission(
        vp,
        "presentation-submission-id",
        "driving-license-presentation-definition",
        "driving-license-credential",
        format,
        "\$.verifiableCredential[0]",
      );

      final createPresentation = presentProofProtocol.createPresentation(
        "did:example:prover",
        "did:example:verifier",
        "abc123456",
        createVpSubmission,
      );

      final packAuthMsg = packAuthCrypt(
        senderPrivKeyStr:
            "privBtpaUECfDNku8K8RJgGptKRL24c365AbFHXEctRMDJGTntWkPmJD",
        recipientPubKeyBase58: "CxSNscV5tJDhqAPoGaWz4ZVwaGxKyQPbbp4fwH67iDSH",
        skid: "did:example:prover#key-2",
        kid: "did:example:verifier#key-2",
        message: createPresentation,
      );

      final unpackAuthMsg = unpackAuthCrypt(
        jwe: packAuthMsg,
        receiverPrivKeyStr:
            "privBve6bpkpdM4jHTkNnDRbVg8DYtizNubhzaYtD37GHsvFghckrNDm",
        senderPubKeyBase58: "8Vo5BCHe41B4RdaFmYubxZLKo8oj6AwRsP3rK2bv63Bf",
      );

      expect(unpackAuthMsg['from'], equals("did:example:prover"));
      expect(
          (unpackAuthMsg['to'] as List).first, equals("did:example:verifier"));
      expect(jsonEncode(unpackAuthMsg['attachments'][0]['data']['json']),
          equals(jsonEncode(createVpSubmission)));
      expect(unpackAuthMsg['type'],
          equals("https://didcomm.org/present-proof/3.0/presentation"));
    });

    test('should create an ack correctly', () {
      final createAck = presentProofProtocol.createAck(
        "did:example:verifier",
        "did:example:prover",
        "abc123456",
        "OK",
      );

      final packAuthMsg = packAuthCrypt(
        senderPrivKeyStr:
            "privBve6bpkpdM4jHTkNnDRbVg8DYtizNubhzaYtD37GHsvFghckrNDm",
        recipientPubKeyBase58: "8Vo5BCHe41B4RdaFmYubxZLKo8oj6AwRsP3rK2bv63Bf",
        skid: "did:example:verifier#key-2",
        kid: "did:example:prover#key-2",
        message: createAck,
      );

      final unpackAuthMsg = unpackAuthCrypt(
        jwe: packAuthMsg,
        receiverPrivKeyStr:
            "privBtpaUECfDNku8K8RJgGptKRL24c365AbFHXEctRMDJGTntWkPmJD",
        senderPubKeyBase58: "CxSNscV5tJDhqAPoGaWz4ZVwaGxKyQPbbp4fwH67iDSH",
      );

      expect(unpackAuthMsg['from'], equals("did:example:verifier"));
      expect((unpackAuthMsg['to'] as List).first, equals("did:example:prover"));
      expect(unpackAuthMsg['body']['status'], equals("OK"));
      expect(unpackAuthMsg['type'],
          equals("https://didcomm.org/present-proof/3.0/ack"));
    });
  });
}
