import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:example/main.dart';
import 'package:zetrix_vc_flutter/zetrix_vc_flutter.dart';


class VcService {
  final Dio _dio;
  final bool isMainnet;
  final EncryptionUtils encryptionUtils = EncryptionUtils();

  late final ZetrixVcService zetrixVcService;
  late final ZetrixVcEncryptedService zetrixVcEncryptedService;

  VcService(this._dio, this.isMainnet) {
    zetrixVcService = ZetrixVcService(_dio, isMainnet);
    zetrixVcEncryptedService = ZetrixVcEncryptedService(_dio, isMainnet);
  }

  final _templateId = "did:zid:739b000e6a896178e3386a2ed848d01a873b833d3c0248d28e5c7d2bbde4606e";
  final _tds = 'ZTX3JszqPgRUx743SAp7q7zURfjvkWuH2FMEz';
  final _privateKey = 'privBuxkhHNotabnfMP927frfMGANNqS78F8265zDnqNj411mDyFPwSQ';
  final _publicKey = 'b001e7362f7ec66f888c7c24f26bbf1df92564bd86f1b69064529c4799e752d3cf5c22df1964';

  Map<String, String> _metadata() => {
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
      };

  ApplyVcItem _createItem() => ApplyVcItem(templateId: _templateId, metadata: _metadata(), tds: _tds);

  Future<String> applyVc() async {
    final items = [_createItem()];
    final sign = await encryptionUtils.signBlob(jsonEncode(items), _privateKey);
    final req = ApplyVcRequest(data: items, publicKey: _publicKey, signData: sign.signBlob!);

    final result = await zetrixVcService.applyVc(req);
    return _handleApplyResult(result);
  }

  Future<String> applyVcEnc() async {
    final items = [_createItem()];
    final sign = await encryptionUtils.signBlob(jsonEncode(items), _privateKey);
    final req = ApplyVcRequest(data: items, publicKey: _publicKey, signData: sign.signBlob!);

    final result = await zetrixVcEncryptedService.applyVcEnc(req, _privateKey, _getIssuerPublicKey());
    return _handleApplyResult(result);
  }

  Future<void> downloadVc() async {
    final vcId = 'did:zid:529008aab6ba4f1acbbb312ec65188a52928590fb8aab25d79de4c71e0c44507';
    final sign = await encryptionUtils.signBlob(vcId, 'privBxpL2meqP4CHanp4KRzRrabwCEnTgJx8DAddWkveUoZWiYmuHFZx');
    final req = DownloadVcRequest(vcId: vcId, isIssuer: false, signVcId: sign.signBlob!);

    final result = await zetrixVcService.downloadVc(req);
    _logResult(result);
  }

  Future<void> downloadVcEnc() async {
    final vcId = 'did:zid:7f9637354e9a352cb1971274a1e7104e46029ebeebee769a60b01ff5029922bb';
    final sign = await encryptionUtils.signBlob(vcId, _privateKey);
    final req = DownloadVcRequest(vcId: vcId, isIssuer: false, signVcId: sign.signBlob!);

    final result = await zetrixVcEncryptedService.downloadVcEnc(req, _privateKey, _getIssuerPublicKey());
    _logResult(result);
  }

  Future<String> _handleApplyResult(ZetrixSDKResult<ApplyVcResponse> result) {
    if (result is Success<ApplyVcResponse>) {
      logger.i(result.data?.toJson());
      return Future.value(result.data!.vcId);
    } else {
      logger.e(result);
      throw 'VC Application failed';
    }
  }

  void _logResult(ZetrixSDKResult result) {
    if (result is Success) {
      logger.i((result.data as dynamic).toJson());
    } else {
      logger.e(result);
    }
  }

  String _getIssuerPublicKey() => 'CxSNscV5tJDhqAPoGaWz4ZVwaGxKyQPbbp4fwH67iDSH';
}
