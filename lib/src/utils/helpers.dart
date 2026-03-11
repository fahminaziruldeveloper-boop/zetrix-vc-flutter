import 'dart:math';
import 'dart:convert';
import 'tools.dart';

/// A utility class that provides helper methods for various SDK-related operations.
///
/// The `Helpers` class includes methods for conversions between gas and micro-gas (ugas),
/// handling numbers with decimal places, and extracting minimal verifiable presentations.
///
class Helpers {
  /// Converts a gas amount represented as a [String] to its equivalent micro-gas (ugas) value.
  static String gasToUGas(String gas) {
    if (!Tools.isAvailableZTX(gas)) {
      return '';
    }
    num oneMo = pow(10, 6);
    return (num.parse(gas) * oneMo).toString();
  }

  /// Converts a micro-gas (ugas) value represented as a [String] to its equivalent gas value.
  static String ugasToGas(String ugas) {
    if (!Tools.isAvailableValue(ugas)) {
      return '';
    }
    num oneMo = pow(10, 6);
    return (num.parse(ugas) / oneMo).toString();
  }

  /// Multiplies the given [amount] with 10 raised to the power of [decimal].
  static String unitWithDecimals(String amount, String decimal) {
    final regex = RegExp(r"^[0-9]+$");

    if (!regex.hasMatch(amount) || !regex.hasMatch(decimal)) {
      return '';
    }
    num oneMo = pow(10, int.parse(decimal));
    num amountWithDecimals = num.parse(amount) * oneMo;
    if (amountWithDecimals >= 0 && amountWithDecimals <= double.maxFinite) {
      return amountWithDecimals.toString();
    }
    return '';
  }

  /// Extracts a minimal verifiable presentation (VP) from the given [vpJson].
  static String extractMinimalVp(String vpJson) {
    final fullVp = jsonDecode(vpJson) as Map<String, dynamic>;

    final context = fullVp['@context'];
    final holder = fullVp['holder'];
    final rangeProof = fullVp['rangeProof'];
    final vcList = fullVp['verifiableCredential'] as List<dynamic>;
    final originalVc = vcList.first as Map<String, dynamic>;

    final minimalProof = (originalVc['proof'] as List)
        .where((p) => p['type'] == 'BbsBlsSignatureProof2020')
        .map((p) => {
              'type': p['type'],
              'proofValue': p['proofValue'],
              'verificationMethod': p['verificationMethod'],
              'nonce': p['nonce'],
            })
        .toList();

    final minimalVc = {
      'id': originalVc['id'],
      'type': originalVc['type'],
      'issuer': originalVc['issuer'],
      'issuanceDate': originalVc['issuanceDate'],
      'expirationDate': originalVc['expirationDate'],
      'validFrom': originalVc['validFrom'],
      'validUntil': originalVc['validUntil'],
      'credentialSubject': originalVc['credentialSubject'],
      'proof': minimalProof,
      '@context': originalVc['@context'],
    };

    final minimalVp = {
      '@context': context,
      'type': fullVp['type'],
      'holder': holder,
      'proof': fullVp['proof'],
      'rangeProof': rangeProof,
      'verifiableCredential': [minimalVc],
    };

    return jsonEncode(minimalVp);
  }

  /// Canonicalizes a JSON string per JCS spec.
  static String canonicalizeJson(String jsonStr) {
    final decoded = jsonDecode(jsonStr);
    final canonicalized = _sortJson(decoded);
    return jsonEncode(canonicalized);
  }

  static dynamic _sortJson(dynamic value) {
    if (value is Map<String, dynamic>) {
      final sorted = Map<String, dynamic>.fromEntries(
        value.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
      );
      return sorted.map((k, v) => MapEntry(k, _sortJson(v)));
    } else if (value is List) {
      return value.map(_sortJson).toList();
    } else {
      return value;
    }
  }

  /// Base64url encodes a UTF-8 string
  static String base64UrlEncodeString(String input) {
    return base64UrlEncode(utf8.encode(input)).replaceAll('=', '');
  }

  /// Equivalent of formatJwsStr in Java
  static String formatJwsStr(String jsonStr) {
    final canonicalized = canonicalizeJson(jsonStr);
    return base64UrlEncodeString(canonicalized);
  }

  /// Create JWS token
  static String createJwsToken({
    required String header,
    required String payload,
    required String signature,
  }) {
    return '${formatJwsStr(header)}.'
        '${formatJwsStr(payload)}.'
        '${base64UrlEncodeString(signature)}';
  }

  static String formatJwsSignData(String header, String payload) {
    return '$header.$payload';
  }

  /// Decodes a base64url string back into the original UTF-8 string.
  static String base64UrlDecodeString(String input) {
    // Restore padding if needed
    String normalized = input;
    switch (input.length % 4) {
      case 0:
        break;
      case 2:
        normalized += '==';
        break;
      case 3:
        normalized += '=';
        break;
      default:
        throw FormatException('Invalid Base64URL string length');
    }

    final decodedBytes = base64Url.decode(normalized);
    return utf8.decode(decodedBytes);
  }
}
