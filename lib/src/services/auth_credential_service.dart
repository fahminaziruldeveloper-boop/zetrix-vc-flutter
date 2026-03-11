import 'package:dio/dio.dart';
import 'package:zetrix_vc_flutter/src/config.dart';

/// Provides hardcoded authentication credentials for Zetrix BaaS API requests.
///
/// Reads the Bearer token and x-api-key from [ConfigReader] based on
/// the target environment. No network call is made.
///
/// Example usage:
///
/// ```dart
/// final credentialService = AuthCredentialService(Dio(), isMainnet: true);
/// ```
class AuthCredentialService { 
  /// The shared Dio client used for other SDK requests.
  final Dio dio;

  /// Whether this service is configured for the mainnet environment.
  final bool isMainnet;

  /// The fixed Bearer token for the configured environment.
  late final String _apiToken;

  /// The fixed x-api-key for the configured environment.
  late final String _xApiKey;

  /// Constructs an [AuthCredentialService].
  ///
  /// - [dio] is the shared HTTP client used elsewhere in the SDK.
  /// - [isMainnet] determines whether to use mainnet (`true`) or testnet
  ///   (`false`) credentials. Defaults to `false`.
  AuthCredentialService(this.dio, {this.isMainnet = false}) {
    _apiToken = ConfigReader.getApiToken(isMainnet);
    _xApiKey = ConfigReader.getXApiKey(isMainnet);
  }

  /// Returns the fixed Bearer token for the configured environment.
  String fetchToken() => _apiToken;

  /// Returns the fixed x-api-key for the configured environment.
  String getXApiKey() => _xApiKey;
}
