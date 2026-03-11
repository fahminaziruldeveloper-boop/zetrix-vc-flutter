import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:zetrix_vc_flutter/src/models/did/verification_method.dart';
import 'package:zetrix_vc_flutter/src/models/did/zid_resolver_response.dart';
import 'package:zetrix_vc_flutter/src/utils/tools.dart';
import 'package:zetrix_vc_flutter/zetrix_vc_flutter.dart';

///Class for DID Resolve
class DidResolverService {
  final String resolverUrl;

  DidResolverService({required this.resolverUrl});

  Future<ZidResolverResponse> resolveZid(String zid) async {
    final int maxRetries = 5;
    int attempt = 0;

    final String url = '$resolverUrl/$zid';

    while (attempt < maxRetries) {
      try {
        final response = await http.get(Uri.parse(url));

        if (response.statusCode == 200) {
          final json = jsonDecode(response.body);
          final result = ZidResolverResponse.fromJson(json);

          if (result.didDocument != null) {
            return result;
          } else {
            Tools.logDebug(
                'ZID resolution returned null DID Document (attempt ${attempt + 1} of $maxRetries)');
          }
        } else {
          Tools.logDebug(
              'Error resolving ZID on attempt ${attempt + 1} of $maxRetries. Status code: ${response.statusCode}');
        }
      } catch (e) {
        Tools.logDebug(
            'Error resolving ZID on attempt ${attempt + 1} of $maxRetries: $e');
      }

      attempt++;

      if (attempt < maxRetries) {
        await Future.delayed(const Duration(milliseconds: 500));
      }
    }

    throw Exception('INVALID_ZID');
  }

  /// Extract ZETRIX ED25519 public key from resolver response
  String getEd25519PublicKey({
    required String verificationMethodId,
    required ZidResolverResponse resolverResponse,
  }) {
    final verificationMethodsJson =
        resolverResponse.didDocument?['verificationMethod'] as List<dynamic>?;

    final List<VerificationMethod> verificationMethods =
        verificationMethodsJson?.map((item) {
              return VerificationMethod.fromJson(item as Map<String, dynamic>);
            }).toList() ??
            [];

    final vm = verificationMethods.firstWhere(
      (vm) =>
          vm.type == 'Ed25519VerificationKey2020' &&
          vm.id == verificationMethodId,
      orElse: () => throw ZetrixSDKExceptions.ResolverError('ED25519_KEY_NOT_EXIST'),
    );

    final publicKeyHex = vm.additionalFields['publicKeyHex'] as String?;

    if (publicKeyHex == null) {
      throw ZetrixSDKExceptions.ResolverError('ED25519_KEY_NOT_EXIST');
    }

    return publicKeyHex;
  }
}
