import 'dart:math' as math;

/// Utility functions for Bulletproof operations
/// Matches Java BulletProofUtil helper methods
class BulletproofUtil {
  /// Base64URL prefix (matches Java)
  static const String base64UrlPrefix = 'u';

  /// Special value indicating no maximum constraint (matches Java)
  static const int noMaxValue = 0;

  /// Scale a decimal value to an integer by multiplying by 10^decimalPlaces
  ///
  /// Example matching Java:
  /// ```dart
  /// int cgpa = BulletproofUtil.scaleDecimal(3.45, 2);  // 345
  /// int maxCgpa = BulletproofUtil.scaleDecimal(4.0, 2);  // 400
  /// int minCgpa = BulletproofUtil.scaleDecimal(2.9, 2);  // 290
  /// ```
  static int scaleDecimal(double value, int decimalPlaces) {
    if (decimalPlaces < 0) {
      throw ArgumentError('decimalPlaces must be non-negative');
    }

    double scaleFactor = math.pow(10, decimalPlaces).toDouble();
    return (value * scaleFactor).round();
  }

  /// Unscale an integer back to a decimal
  ///
  /// Example:
  /// ```dart
  /// double cgpa = BulletproofUtil.unscaleDecimal(345, 2);  // 3.45
  /// ```
  static double unscaleDecimal(int value, int decimalPlaces) {
    if (decimalPlaces < 0) {
      throw ArgumentError('decimalPlaces must be non-negative');
    }

    double scaleFactor = math.pow(10, decimalPlaces).toDouble();
    return value / scaleFactor;
  }

  /// Calculate the appropriate bit size for a value
  ///
  /// Returns the minimum number of bits needed to represent the value
  static int calculateBitSize(int value) {
    if (value < 0) {
      throw ArgumentError('value must be non-negative');
    }
    if (value == 0) return 1;

    return (value.bitLength);
  }

  /// Recommend a bit size for a maximum value
  /// Returns a standard bit size (8, 16, 32, 64) that can represent the value
  static int recommendBitSize(int maxValue) {
    if (maxValue < 0) {
      throw ArgumentError('maxValue must be non-negative');
    }

    int requiredBits = calculateBitSize(maxValue);

    if (requiredBits <= 8) return 8;
    if (requiredBits <= 16) return 16;
    if (requiredBits <= 32) return 32;
    return 64;
  }

  /// Scale multiple decimal values
  ///
  /// Example matching Java:
  /// ```dart
  /// List<int> values = BulletproofUtil.scaleDecimals([3.45, 2.9, 4.0], 2);
  /// // [345, 290, 400]
  /// ```
  static List<int> scaleDecimals(List<double> values, int decimalPlaces) {
    return values.map((v) => scaleDecimal(v, decimalPlaces)).toList();
  }

  /// Unscale multiple integer values
  static List<double> unscaleDecimals(List<int> values, int decimalPlaces) {
    return values.map((v) => unscaleDecimal(v, decimalPlaces)).toList();
  }

  /// Validate that a value is within a range
  static bool isInRange(int value, int min, int max) {
    if (max == noMaxValue) {
      return value >= min;
    }
    return value >= min && value <= max;
  }

  /// Validate multiple values are within their respective ranges
  static bool areInRanges(List<int> values, List<int> mins, List<int> maxs) {
    if (values.length != mins.length || values.length != maxs.length) {
      throw ArgumentError('All lists must have the same length');
    }

    for (int i = 0; i < values.length; i++) {
      if (!isInRange(values[i], mins[i], maxs[i])) {
        return false;
      }
    }
    return true;
  }

  /// Check if a base64url string has the correct prefix
  static bool hasCorrectPrefix(String base64url) {
    return base64url.startsWith(base64UrlPrefix);
  }

  /// Validate a list of commitments
  static bool validateCommitments(List<String> commitments) {
    if (commitments.isEmpty) return false;

    for (String commitment in commitments) {
      if (!hasCorrectPrefix(commitment)) {
        return false;
      }
    }
    return true;
  }

  /// Calculate expected number of commitments for min-max proof
  ///
  /// For each value:
  /// - 1 commitment for lower bound (value - min)
  /// - 1 commitment for upper bound (max - value) if max != noMaxValue
  static int calculateExpectedCommitments(List<int> maxs) {
    int count = 0;
    for (int max in maxs) {
      count++; // Lower bound commitment
      if (max != noMaxValue) {
        count++; // Upper bound commitment
      }
    }
    return count;
  }
}
