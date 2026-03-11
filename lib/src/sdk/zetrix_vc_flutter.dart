import 'package:dio/dio.dart';
import '../../src/services/auth_credential_service.dart';
import '../../src/utils/auth_interceptor.dart';
import 'package:zetrix_vc_flutter/frb_generated.dart'; 
/// Singleton entry point for interacting with the Zetrix VC Flutter SDK.
///
/// Call [init] once before using services in this SDK. It handles:
///
/// - Configuring the [Dio] client.
/// - Initializing the [AuthCredentialService].
/// - Attaching the [AuthInterceptor] to inject authentication headers.
///
/// Example usage:
///
/// ```dart
/// final sdk = ZetrixVcFlutter();
/// await sdk.init(isMainnet: true);
/// ```
///
/// You can check whether the SDK is configured for mainnet via [isMainnet].
class ZetrixVcFlutter {
  static final ZetrixVcFlutter _instance = ZetrixVcFlutter._internal();

  late final Dio _dio;
  late final AuthCredentialService _credentialService;
  bool _isInitialized = false;
  bool _isMainnet = false;

  ZetrixVcFlutter._internal();

  /// Returns the singleton instance of [ZetrixVcFlutter].
  factory ZetrixVcFlutter() => _instance;

 /// Initializes the SDK.
  ///
  /// - [isMainnet] determines whether to connect to the mainnet (`true`)
  ///   or testnet (`false`). Defaults to `false`.
  ///
  /// Call this method **once** before using any services.
  Future<void> init({bool isMainnet = false}) async {
    if (_isInitialized) return;


    // Initialize RustLib for bulletproofs
    await RustLib.init();

    _dio = Dio();
    _credentialService = AuthCredentialService(_dio, isMainnet: isMainnet);
    _dio.interceptors.add(AuthInterceptor(_credentialService));
    _isInitialized = true;
    _isMainnet = isMainnet;
  }

  /// Returns the Dio HTTP client configured by the SDK.
  Dio get dio => _dio;

  /// Returns `true` if the SDK is configured for mainnet.
  bool get isMainnet => _isMainnet;

  /// Returns the [AuthCredentialService].
  AuthCredentialService get credentialService => _credentialService;
}