import 'package:flutter_test/flutter_test.dart';
import 'package:zetrix_vc_flutter/zetrix_vc_flutter.dart';

void main() {
  final ReportProblemProtocol reportProblemProtocol =
      ReportProblemProtocol();

  group('Report Problem module', () {
    test('should create a problem-report correctly', () {
      final createProblemReport =
          reportProblemProtocol.createProblemReport(
        "abcd1234",
         "e.m.msg",
         "Error unpacking message.",
      );

      final Map<String, dynamic> packAuthMsg = packAuthCrypt(
        senderPrivKeyStr:
            "privBve6bpkpdM4jHTkNnDRbVg8DYtizNubhzaYtD37GHsvFghckrNDm",
        recipientPubKeyBase58:
            "8Vo5BCHe41B4RdaFmYubxZLKo8oj6AwRsP3rK2bv63Bf",
        skid: "did:example:alice#key-2",
        kid: "did:example:bob#key-2",
        message: createProblemReport,
      );

      final Map<String, dynamic> unpackAuthMsg = unpackAuthCrypt(
        jwe: packAuthMsg,
        receiverPrivKeyStr:
            "privBtpaUECfDNku8K8RJgGptKRL24c365AbFHXEctRMDJGTntWkPmJD",
        senderPubKeyBase58:
            "CxSNscV5tJDhqAPoGaWz4ZVwaGxKyQPbbp4fwH67iDSH",
      );

      expect(unpackAuthMsg['body']['code'], equals("e.m.msg"));
      expect(unpackAuthMsg['body']['comment'],
          equals("Error unpacking message."));
      expect(
        unpackAuthMsg['type'],
        equals(
            "https://didcomm.org/report-problem/2.0/problem-report"),
      );
    });
  });
}
