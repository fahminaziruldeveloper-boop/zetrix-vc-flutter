import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../utils/tools.dart';

part 'sdk_exceptions.freezed.dart';

/// A sealed class that defines various SDK-specific exceptions for handling errors
/// in Zetrix SDK. This includes exceptions related to HTTP requests, connectivity,
/// server issues, and unexpected behavior.
///
/// Each exception provides a clean and reusable way to represent a specific error scenario.

@freezed
abstract class ZetrixSDKExceptions with _$ZetrixSDKExceptions {
  /// Exception for cancelled requests.
  const factory ZetrixSDKExceptions.requestCancelled() = RequestCancelled;

  /// Exception for unauthorized requests.
  const factory ZetrixSDKExceptions.unauthorisedRequest() = UnauthorisedRequest;

  /// Exception for bad requests (400).
  const factory ZetrixSDKExceptions.badRequest() = BadRequest;

  /// Exception for not found resources (404).
  const factory ZetrixSDKExceptions.notFound(String reason) = NotFound;

  /// Exception for a method not allowed error (405).
  const factory ZetrixSDKExceptions.methodNotAllowed() = MethodNotAllowed;

  /// Exception for an unacceptable response (406).
  const factory ZetrixSDKExceptions.notAcceptable() = NotAcceptable;

  /// Exception for request timeout during connection or response.
  const factory ZetrixSDKExceptions.requestTimeout() = RequestTimeout;

  /// Exception for timeout during a send operation.
  const factory ZetrixSDKExceptions.sendTimeout() = SendTimeout;

  /// Exception for a conflict error (409).
  const factory ZetrixSDKExceptions.conflict() = Conflict;

  /// Exception for internal server errors (500).
  const factory ZetrixSDKExceptions.internalServerError() = InternalServerError;

  /// Exception for when a feature or method is not implemented (501).
  const factory ZetrixSDKExceptions.notImplemented() = NotImplemented;

  /// Exception for when a service is unavailable (503).
  const factory ZetrixSDKExceptions.serviceUnavailable() = ServiceUnavailable;

  /// Exception for network connectivity issues (e.g., no internet connection).
  const factory ZetrixSDKExceptions.noInternetConnection() =
      NoInternetConnection;

  /// Exception for format errors (e.g., invalid input format).
  const factory ZetrixSDKExceptions.formatException() = FormatException;

  /// Exception for when the SDK is unable to process the request for unknown reasons.
  const factory ZetrixSDKExceptions.unableToProcess() = UnableToProcess;

  /// Custom exception for generic or default errors, providing a custom error message.
  const factory ZetrixSDKExceptions.defaultError(String error) = DefaultError;

  const factory ZetrixSDKExceptions.cryptoError(String error) = CryptoError;

  const factory ZetrixSDKExceptions.vcSchemaError(String error) = VcSchemaError;

  const factory ZetrixSDKExceptions.ResolverError(String error) = ResolverError;
 
  /// Exception for unexpected errors or behavior.
  const factory ZetrixSDKExceptions.unexpectedError() = UnexpectedError;

  /// Maps Dio-specific exceptions into meaningful SDK exceptions.
  ///
  /// This method processes a DioException error and converts it into
  /// a corresponding [ZetrixSDKExceptions] instance based on the type of DioException
  /// or the HTTP response code.
  static ZetrixSDKExceptions getDioException(Object error) {
    if (error is Exception) {
      try {
        ZetrixSDKExceptions sdkExceptions;
        if (error is DioException) {
          switch (error.type) {
            case DioExceptionType.cancel:
              sdkExceptions = const ZetrixSDKExceptions.requestCancelled();
              break;
            case DioExceptionType.connectionTimeout:
              sdkExceptions = const ZetrixSDKExceptions.requestTimeout();
              break;
            case DioExceptionType.unknown:
              sdkExceptions = const ZetrixSDKExceptions.noInternetConnection();
              break;
            case DioExceptionType.receiveTimeout:
              switch (error.response!.statusCode) {
                case 400:
                  sdkExceptions = ZetrixSDKExceptions.defaultError(error
                      .response!.data['messages'].first['message']
                      .toString());

                  break;
                case 401:
                  sdkExceptions =
                      const ZetrixSDKExceptions.unauthorisedRequest();
                  break;
                case 403:
                  sdkExceptions =
                      const ZetrixSDKExceptions.unauthorisedRequest();
                  break;
                case 404:
                  sdkExceptions =
                      const ZetrixSDKExceptions.notFound("Not found");
                  break;
                case 409:
                  sdkExceptions = const ZetrixSDKExceptions.conflict();
                  break;
                case 408:
                  sdkExceptions = const ZetrixSDKExceptions.requestTimeout();
                  break;
                case 500:
                  sdkExceptions =
                      const ZetrixSDKExceptions.internalServerError();
                  break;
                case 503:
                  sdkExceptions =
                      const ZetrixSDKExceptions.serviceUnavailable();
                  break;
                default:
                  var responseCode = error.response!.statusCode;
                  sdkExceptions = ZetrixSDKExceptions.defaultError(
                    "Received invalid status code: $responseCode",
                  );
              }
              break;
            case DioExceptionType.sendTimeout:
              sdkExceptions = const ZetrixSDKExceptions.sendTimeout();
              break;
            case DioExceptionType.badCertificate:
              sdkExceptions = const ZetrixSDKExceptions.badRequest();
            case DioExceptionType.badResponse:
              sdkExceptions = const ZetrixSDKExceptions.badRequest();
            case DioExceptionType.connectionError:
              sdkExceptions = const ZetrixSDKExceptions.badRequest();
          }
        } else if (error is SocketException) {
          sdkExceptions = const ZetrixSDKExceptions.noInternetConnection();
        } else {
          sdkExceptions = const ZetrixSDKExceptions.unexpectedError();
        }
        return sdkExceptions;
      } on FormatException catch (e) {
        // Helper.printError(e.toString());
        Tools.logDebug(e.toString());
        return const ZetrixSDKExceptions.formatException();
      } catch (_) {
        return const ZetrixSDKExceptions.unexpectedError();
      }
    } else {
      if (error.toString().contains("is not a subtype of")) {
        return const ZetrixSDKExceptions.unableToProcess();
      } else {
        return const ZetrixSDKExceptions.unexpectedError();
      }
    }
  }

  /// Provides a user-friendly error message based on the type of [ZetrixSDKExceptions].
  ///
  /// This method takes an instance of [ZetrixSDKExceptions] and returns the corresponding
  /// human-readable message. Each exception type is mapped to a specific message, which could
  /// be displayed to the user or logged for debugging purposes.
  static String getErrorMessage(ZetrixSDKExceptions sdkExceptions) {
    if (sdkExceptions is NotImplemented) {
      return "Not Implemented";
    } else if (sdkExceptions is RequestCancelled) {
      return "Request Cancelled";
    } else if (sdkExceptions is InternalServerError) {
      return "Internal Server Error";
    } else if (sdkExceptions is NotFound) {
      return sdkExceptions.reason;
    } else if (sdkExceptions is ServiceUnavailable) {
      return "Service unavailable";
    } else if (sdkExceptions is MethodNotAllowed) {
      return "Method Not Allowed";
    } else if (sdkExceptions is BadRequest) {
      return "Bad request";
    } else if (sdkExceptions is UnauthorisedRequest) {
      return "Unauthorised request";
    } else if (sdkExceptions is UnexpectedError) {
      return "Unexpected error occurred";
    } else if (sdkExceptions is RequestTimeout) {
      return "Connection request timeout";
    } else if (sdkExceptions is NoInternetConnection) {
      return "No internet connection";
    } else if (sdkExceptions is Conflict) {
      return "Error due to a conflict";
    } else if (sdkExceptions is SendTimeout) {
      return "Send timeout in connection with API server";
    } else if (sdkExceptions is UnableToProcess) {
      return "Unable to process the data";
    } else if (sdkExceptions is DefaultError) {
      return sdkExceptions.error;
    } else if (sdkExceptions is CryptoError) {
      return sdkExceptions.error;
    } else if (sdkExceptions is VcSchemaError) {
      return sdkExceptions.error;
    } else if (sdkExceptions is ResolverError) {
      return sdkExceptions.error;
    } else if (sdkExceptions is FormatException) {
      return "Unexpected error occurred";
    } else if (sdkExceptions is NotAcceptable) {
      return "Not acceptable";
    } else {
      return "Something went wrong";
    }
  }
}
