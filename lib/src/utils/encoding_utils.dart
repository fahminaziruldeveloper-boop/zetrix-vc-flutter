import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:convert/convert.dart';
import 'package:zetrix_vc_flutter/src/utils/tools.dart';

/// A utility class for encoding, decoding, and compressing string data.
///
/// Includes functions for converting between UTF-8 and hexadecimal representations,
/// and compressing JSON strings using GZIP.
class EncodingUtils {
  /// Converts a UTF-8 encoded string to its hexadecimal representation.
  static String utfToHex(String str) {
    if (Tools.isEmptyString(str)) {
      return '';
    }

    var encoded = utf8.encode(str);
    return encoded.map((e) => e.toRadixString(16)).join();
  }

  /// Converts a hexadecimal string to its UTF-8 representation.
  static String hexToUtf(String str) {
    final regex = RegExp(r"^[0-9a-fA-F]+$");
    if (Tools.isEmptyString(str) || !regex.hasMatch(str)) {
      return '';
    }

    var encoded = hex.decode(str);
    return utf8.decode(encoded);
  }

  /// Converts a hexadecimal [String] to a [Uint8List] of bytes.
  ///
  /// This function parses the given [hex] string, which must contain only valid hexadecimal
  /// characters (`0-9`, `a-f`, or `A-F`) and must have an even length.
  ///
  /// It converts each pair of hexadecimal characters into a single byte and returns the resulting
  /// [Uint8List] representing the decoded binary data.
  ///
  /// Example:
  /// ```dart
  /// final bytes = hexStringToBytes("48656C6C6F"); // [72, 101, 108, 108, 111] => "Hello"
  /// ```
  ///
  /// [hex]: A string containing only valid hexadecimal characters.
  /// 
  /// Returns: A [Uint8List] of decoded bytes from the input hex string.
  /// 
  /// Throws: May produce incorrect results or unexpected behavior if the string contains
  /// invalid hex characters or has an odd length (no explicit error handling is included).
  static Uint8List hexStringToBytes(String hex) {
    hex = hex.toUpperCase();
    final hexChars = hex.split('');
    final length = hex.length ~/ 2;
    final result = Uint8List(length);

    for (int i = 0; i < length; i++) {
      int pos = i * 2;
      int hi = _charToByte(hexChars[pos]);
      int lo = _charToByte(hexChars[pos + 1]);
      result[i] = ((hi << 4) | lo) & 0xFF;
    }

    return result;
  }

  static int _charToByte(String c) {
    const hexDigits = "0123456789ABCDEF";
    return hexDigits.indexOf(c); // returns -1 for invalid chars
  }

  /// Compresses a JSON string [jsonStr] using GZIP and returns the compressed bytes as a [Uint8List].
  ///
  /// This method encodes the input JSON string as UTF-8 and then compresses it
  /// using the GZIP algorithm. This is useful for minimizing data size for transmission
  /// or storage.
  ///
  /// Returns: A [Uint8List] containing the GZIP-compressed data.
  static Uint8List compressJsonGzip(String jsonStr) {
    final jsonString = json.encode(jsonStr);
    final inputBytes = utf8.encode(jsonString);

    final compressed = GZipEncoder().encode(inputBytes);
    return Uint8List.fromList(compressed);
  }
}
