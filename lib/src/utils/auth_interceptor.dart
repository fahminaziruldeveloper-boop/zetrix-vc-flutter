import 'package:dio/dio.dart';
import 'package:zetrix_vc_flutter/zetrix_vc_flutter.dart';

/// An interceptor that attaches authentication headers to every outgoing
/// Zetrix BaaS API request.
///
/// Adds the following headers sourced from [AuthCredentialService]:
/// - `Authorization: Bearer <token>`
/// - `x-api-key: <key>`
///
/// Both values are read from [ConfigReader] at SDK initialisation —
/// no network call is made.
///
/// Example usage:
/// ```dart
/// final dio = Dio();
/// dio.interceptors.add(AuthInterceptor(credentialService));
/// ```
class AuthInterceptor extends Interceptor {

  /// Service responsible for providing authentication credentials.
  final AuthCredentialService credentialService;

  /// Constructs an [AuthInterceptor] with the provided [credentialService].
  AuthInterceptor(this.credentialService);

  /// Called before a request is sent.
  ///
  /// Attaches the `Authorization` Bearer token and `x-api-key` header
  /// to every outgoing request.
  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) {
    options.headers['Authorization'] = 'Bearer ${credentialService.fetchToken()}';
    options.headers['x-api-key'] = credentialService.getXApiKey();
    handler.next(options);
  }

  /// Forwards errors as-is.
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    handler.next(err);
  }
}
