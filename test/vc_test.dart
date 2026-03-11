import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zetrix_vc_flutter/src/utils/auth_interceptor.dart';
import 'package:zetrix_vc_flutter/src/utils/tools.dart';
import 'package:zetrix_vc_flutter/zetrix_vc_flutter.dart';

void main() async {
  // ZetrixVcFlutter().init();
  late final Dio dio;
  late final AuthCredentialService credentialService;
  dio = Dio();

  credentialService = AuthCredentialService(dio);
  dio.interceptors.add(AuthInterceptor(credentialService));

  ZetrixVcService zetrixVcService = ZetrixVcService(dio, false);
  EncryptionUtils encryptionUtils = EncryptionUtils();

  test('should return success apply VC', () async {
    //Sign data object
    final applyItem = [ApplyVcItem(
              templateId:
                  "did:zid:9aa7ecefc0765fe939236b4477cb5262205bd43a4281d51fca2cd7e43c29c838",
              metadata: {
                "name": "John Michael",
                "dob": "1990-01-01",
                "gender": "Male",
                "nationality": "Myanmarese",
                "identityNo": "A123456789",
                "passportNo": "P987654321",
                "citizenType": "Permanent Resident",
                "dateOfExpiry": "2030-12-31",
                "countryIssue": "Malaysia",
                "photo": "test.com"
              },
              tds: 'ZTX3JszqPgRUx743SAp7q7zURfjvkWuH2FMEz')];

    final signData = await encryptionUtils.signBlob(jsonEncode(applyItem), 'privBuxkhHNotabnfMP927frfMGANNqS78F8265zDnqNj411mDyFPwSQ');
    final reqDto = ApplyVcRequest(
        data: [
          ApplyVcItem(
              templateId:
                  "did:zid:9aa7ecefc0765fe939236b4477cb5262205bd43a4281d51fca2cd7e43c29c838",
              metadata: {
                "name": "John Michael",
                "dob": "1990-01-01",
                "gender": "Male",
                "nationality": "Myanmarese",
                "identityNo": "A123456789",
                "passportNo": "P987654321",
                "citizenType": "Permanent Resident",
                "dateOfExpiry": "2030-12-31",
                "countryIssue": "Malaysia",
                "photo": "test.com"
              },
              tds: 'ZTX3JszqPgRUx743SAp7q7zURfjvkWuH2FMEz')
        ],
        publicKey:
            'b001e7362f7ec66f888c7c24f26bbf1df92564bd86f1b69064529c4799e752d3cf5c22df1964',
        signData:
            signData.signBlob!);
    // expect(vp, isNotNull);
    final result = await zetrixVcService.applyVc(reqDto);
    if (result is Success<ApplyVcResponse>) {
      Tools.logDebug(result.data?.toJson());
    } else if (result is Failure) {
      Tools.logDebug(result);
    }
  });

  test('should return success download VC', () async {
    //Sign vc id
    final signData = await encryptionUtils.signBlob('did:zid:5fb15d29b50e9ab346942b5264888c80e2c9a646c6b718e2fa8f892f8b595688', 'privBuxkhHNotabnfMP927frfMGANNqS78F8265zDnqNj411mDyFPwSQ');
    final reqDto = DownloadVcRequest(
        vcId:
            'did:zid:5fb15d29b50e9ab346942b5264888c80e2c9a646c6b718e2fa8f892f8b595688',
        isIssuer: false,
        signVcId:
            signData.signBlob!);
    // expect(vp, isNotNull);
    final result = await zetrixVcService.downloadVc(reqDto);
    if (result is Success<VerifiableCredential>) {
      Tools.logDebug(result.data?.toJson());
    } else if (result is Failure) {
      Tools.logDebug(result);
    }
  });
}
