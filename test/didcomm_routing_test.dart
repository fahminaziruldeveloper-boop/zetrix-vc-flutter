import 'package:flutter_test/flutter_test.dart';
import 'package:zetrix_vc_flutter/zetrix_vc_flutter.dart';

void main() {
  final RoutingProtocol routingProtocol = RoutingProtocol();

  group('Routing module', () {
    test('should create a forward correctly', () {
      final jwe = {
        "protected":
            "eyJlcGsiOnsiY3J2IjoiWDI1NTE5Iiwia3R5IjoiT0tQIiwieCI6IlBrbW5BUUZrZHhiRlFqMlZ6dlNyLUZDZ3FxczEtQlVuNWtFZEZNZXctU3cifSwidHlwIjoiYXBwbGljYXRpb24vZGlkY29tbS1lbmNyeXB0ZWQranNvbiIsImFsZyI6IkVDREgtMVBVK0EyNTZLVyIsImVuYyI6IkEyNTZDQkMtSFM1MTIiLCJza2lkIjoiZGlkOmV4YW1wbGU6YWxpY2Uja2V5LTIiLCJhcHUiOiJaR2xrT21WNFlXMXdiR1U2WVd4cFkyVWphMlY1TFRJIiwiYXB2IjoiQkJnUmxKWkpHMk10SGg1SUV3dGRkdnVuV2o2QzhMblhNYUx5dk55NGNvMCJ9",
        "recipients": [
          {
            "encrypted_key":
                "AAAAAAEAAACKzmBnf3nsZAlXj0DtEXou6GdnL16kbnYSJNuDj6f77m_PFF9-tAR0koy86W5MB7iGzycCCiN2OqpXPVcC7CgtfC3ZWPbFSgZYO998x-b3Eg",
            "header": {}
          }
        ],
        "iv": "pFp7XxM8uTq87Sh8ZPgY7A",
        "ciphertext":
            "IsRx7imn-JkPipah8KgXLtYKaHm79Xvn_t29s2gA7tFTb9JGwUU57SDbG05QVcFmSgVwifTdPGuxVblKJaAEX4MMzMQP7nEvWlE1mmZOwJVfDWmbvEQQHwuIw9kopJoj4ADN8ZvjKqjbXSAytncmu-k4G3WyJIw-pVdHwdvU0O4wdwL3L5N-9tTwO2q8jwKfS0nUHh1MKifEkm1bJOx0z7DFEds5VN7VAtlivhjm3LZ9m_Zk6vv3_esJoM678gDKTKnTIfQqdPmTQdohai5JGEoBS1-ycpg79kIqB7vtmTiufdhPNwR6C41plkz-tGam3ZWXamKpwKE6Rgn7jS8xXnAOLJRt7JBKflfILbdQC1lHv82-8niu2crDijpRFDNA",
        "tag":
            "4CWHTxQY69mEjTr3aXLSYgtJwrAdCeJraRq4xskB4q97OhJHQ0tbhM0cBW-SdDuV1mj5r0_vdgnWS6A-Xjj5BA"
      };

      final createForward = routingProtocol.createForward(
        "did:example:alice",
        "did:example:bob",
        "did:example:mediator",
        jwe,
      );

      final Map<String, dynamic> packAnonMsg = packAnonCrypt(
        recipientPubKeyBase58: "8Vo5BCHe41B4RdaFmYubxZLKo8oj6AwRsP3rK2bv63Bf",
        kid: "did:example:mediator#key-2",
        message: createForward,
      );

      final Map<String, dynamic> unpackAnonMsg = unpackAnonCrypt(
        jwe: packAnonMsg,
        receiverPrivKeyStr:
            "privBtpaUECfDNku8K8RJgGptKRL24c365AbFHXEctRMDJGTntWkPmJD",
      );

      expect(unpackAnonMsg['from'], equals("did:example:alice"));
      expect(
          (unpackAnonMsg['to'] as List).first, equals("did:example:mediator"));
      expect(unpackAnonMsg['body']['next'], equals("did:example:bob"));
      expect(unpackAnonMsg['type'],
          equals("https://didcomm.org/routing/2.0/forward"));
    });
  });
}
