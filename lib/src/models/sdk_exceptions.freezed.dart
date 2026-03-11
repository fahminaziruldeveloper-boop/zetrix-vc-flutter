// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sdk_exceptions.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ZetrixSDKExceptions implements DiagnosticableTreeMixin {
  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties..add(DiagnosticsProperty('type', 'ZetrixSDKExceptions'));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is ZetrixSDKExceptions);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'ZetrixSDKExceptions()';
  }
}

/// @nodoc
class $ZetrixSDKExceptionsCopyWith<$Res> {
  $ZetrixSDKExceptionsCopyWith(
      ZetrixSDKExceptions _, $Res Function(ZetrixSDKExceptions) __);
}

/// @nodoc

class RequestCancelled
    with DiagnosticableTreeMixin
    implements ZetrixSDKExceptions {
  const RequestCancelled();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(
          DiagnosticsProperty('type', 'ZetrixSDKExceptions.requestCancelled'));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is RequestCancelled);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'ZetrixSDKExceptions.requestCancelled()';
  }
}

/// @nodoc

class UnauthorisedRequest
    with DiagnosticableTreeMixin
    implements ZetrixSDKExceptions {
  const UnauthorisedRequest();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(DiagnosticsProperty(
          'type', 'ZetrixSDKExceptions.unauthorisedRequest'));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is UnauthorisedRequest);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'ZetrixSDKExceptions.unauthorisedRequest()';
  }
}

/// @nodoc

class BadRequest with DiagnosticableTreeMixin implements ZetrixSDKExceptions {
  const BadRequest();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(DiagnosticsProperty('type', 'ZetrixSDKExceptions.badRequest'));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is BadRequest);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'ZetrixSDKExceptions.badRequest()';
  }
}

/// @nodoc

class NotFound with DiagnosticableTreeMixin implements ZetrixSDKExceptions {
  const NotFound(this.reason);

  final String reason;

  /// Create a copy of ZetrixSDKExceptions
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $NotFoundCopyWith<NotFound> get copyWith =>
      _$NotFoundCopyWithImpl<NotFound>(this, _$identity);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(DiagnosticsProperty('type', 'ZetrixSDKExceptions.notFound'))
      ..add(DiagnosticsProperty('reason', reason));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is NotFound &&
            (identical(other.reason, reason) || other.reason == reason));
  }

  @override
  int get hashCode => Object.hash(runtimeType, reason);

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'ZetrixSDKExceptions.notFound(reason: $reason)';
  }
}

/// @nodoc
abstract mixin class $NotFoundCopyWith<$Res>
    implements $ZetrixSDKExceptionsCopyWith<$Res> {
  factory $NotFoundCopyWith(NotFound value, $Res Function(NotFound) _then) =
      _$NotFoundCopyWithImpl;
  @useResult
  $Res call({String reason});
}

/// @nodoc
class _$NotFoundCopyWithImpl<$Res> implements $NotFoundCopyWith<$Res> {
  _$NotFoundCopyWithImpl(this._self, this._then);

  final NotFound _self;
  final $Res Function(NotFound) _then;

  /// Create a copy of ZetrixSDKExceptions
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? reason = null,
  }) {
    return _then(NotFound(
      null == reason
          ? _self.reason
          : reason // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class MethodNotAllowed
    with DiagnosticableTreeMixin
    implements ZetrixSDKExceptions {
  const MethodNotAllowed();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(
          DiagnosticsProperty('type', 'ZetrixSDKExceptions.methodNotAllowed'));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is MethodNotAllowed);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'ZetrixSDKExceptions.methodNotAllowed()';
  }
}

/// @nodoc

class NotAcceptable
    with DiagnosticableTreeMixin
    implements ZetrixSDKExceptions {
  const NotAcceptable();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(DiagnosticsProperty('type', 'ZetrixSDKExceptions.notAcceptable'));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is NotAcceptable);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'ZetrixSDKExceptions.notAcceptable()';
  }
}

/// @nodoc

class RequestTimeout
    with DiagnosticableTreeMixin
    implements ZetrixSDKExceptions {
  const RequestTimeout();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(DiagnosticsProperty('type', 'ZetrixSDKExceptions.requestTimeout'));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is RequestTimeout);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'ZetrixSDKExceptions.requestTimeout()';
  }
}

/// @nodoc

class SendTimeout with DiagnosticableTreeMixin implements ZetrixSDKExceptions {
  const SendTimeout();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(DiagnosticsProperty('type', 'ZetrixSDKExceptions.sendTimeout'));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is SendTimeout);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'ZetrixSDKExceptions.sendTimeout()';
  }
}

/// @nodoc

class Conflict with DiagnosticableTreeMixin implements ZetrixSDKExceptions {
  const Conflict();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(DiagnosticsProperty('type', 'ZetrixSDKExceptions.conflict'));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is Conflict);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'ZetrixSDKExceptions.conflict()';
  }
}

/// @nodoc

class InternalServerError
    with DiagnosticableTreeMixin
    implements ZetrixSDKExceptions {
  const InternalServerError();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(DiagnosticsProperty(
          'type', 'ZetrixSDKExceptions.internalServerError'));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is InternalServerError);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'ZetrixSDKExceptions.internalServerError()';
  }
}

/// @nodoc

class NotImplemented
    with DiagnosticableTreeMixin
    implements ZetrixSDKExceptions {
  const NotImplemented();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(DiagnosticsProperty('type', 'ZetrixSDKExceptions.notImplemented'));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is NotImplemented);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'ZetrixSDKExceptions.notImplemented()';
  }
}

/// @nodoc

class ServiceUnavailable
    with DiagnosticableTreeMixin
    implements ZetrixSDKExceptions {
  const ServiceUnavailable();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(DiagnosticsProperty(
          'type', 'ZetrixSDKExceptions.serviceUnavailable'));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is ServiceUnavailable);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'ZetrixSDKExceptions.serviceUnavailable()';
  }
}

/// @nodoc

class NoInternetConnection
    with DiagnosticableTreeMixin
    implements ZetrixSDKExceptions {
  const NoInternetConnection();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(DiagnosticsProperty(
          'type', 'ZetrixSDKExceptions.noInternetConnection'));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is NoInternetConnection);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'ZetrixSDKExceptions.noInternetConnection()';
  }
}

/// @nodoc

class FormatException
    with DiagnosticableTreeMixin
    implements ZetrixSDKExceptions {
  const FormatException();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(DiagnosticsProperty('type', 'ZetrixSDKExceptions.formatException'));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is FormatException);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'ZetrixSDKExceptions.formatException()';
  }
}

/// @nodoc

class UnableToProcess
    with DiagnosticableTreeMixin
    implements ZetrixSDKExceptions {
  const UnableToProcess();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(DiagnosticsProperty('type', 'ZetrixSDKExceptions.unableToProcess'));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is UnableToProcess);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'ZetrixSDKExceptions.unableToProcess()';
  }
}

/// @nodoc

class DefaultError with DiagnosticableTreeMixin implements ZetrixSDKExceptions {
  const DefaultError(this.error);

  final String error;

  /// Create a copy of ZetrixSDKExceptions
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $DefaultErrorCopyWith<DefaultError> get copyWith =>
      _$DefaultErrorCopyWithImpl<DefaultError>(this, _$identity);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(DiagnosticsProperty('type', 'ZetrixSDKExceptions.defaultError'))
      ..add(DiagnosticsProperty('error', error));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is DefaultError &&
            (identical(other.error, error) || other.error == error));
  }

  @override
  int get hashCode => Object.hash(runtimeType, error);

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'ZetrixSDKExceptions.defaultError(error: $error)';
  }
}

/// @nodoc
abstract mixin class $DefaultErrorCopyWith<$Res>
    implements $ZetrixSDKExceptionsCopyWith<$Res> {
  factory $DefaultErrorCopyWith(
          DefaultError value, $Res Function(DefaultError) _then) =
      _$DefaultErrorCopyWithImpl;
  @useResult
  $Res call({String error});
}

/// @nodoc
class _$DefaultErrorCopyWithImpl<$Res> implements $DefaultErrorCopyWith<$Res> {
  _$DefaultErrorCopyWithImpl(this._self, this._then);

  final DefaultError _self;
  final $Res Function(DefaultError) _then;

  /// Create a copy of ZetrixSDKExceptions
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? error = null,
  }) {
    return _then(DefaultError(
      null == error
          ? _self.error
          : error // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class CryptoError with DiagnosticableTreeMixin implements ZetrixSDKExceptions {
  const CryptoError(this.error);

  final String error;

  /// Create a copy of ZetrixSDKExceptions
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $CryptoErrorCopyWith<CryptoError> get copyWith =>
      _$CryptoErrorCopyWithImpl<CryptoError>(this, _$identity);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(DiagnosticsProperty('type', 'ZetrixSDKExceptions.cryptoError'))
      ..add(DiagnosticsProperty('error', error));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is CryptoError &&
            (identical(other.error, error) || other.error == error));
  }

  @override
  int get hashCode => Object.hash(runtimeType, error);

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'ZetrixSDKExceptions.cryptoError(error: $error)';
  }
}

/// @nodoc
abstract mixin class $CryptoErrorCopyWith<$Res>
    implements $ZetrixSDKExceptionsCopyWith<$Res> {
  factory $CryptoErrorCopyWith(
          CryptoError value, $Res Function(CryptoError) _then) =
      _$CryptoErrorCopyWithImpl;
  @useResult
  $Res call({String error});
}

/// @nodoc
class _$CryptoErrorCopyWithImpl<$Res> implements $CryptoErrorCopyWith<$Res> {
  _$CryptoErrorCopyWithImpl(this._self, this._then);

  final CryptoError _self;
  final $Res Function(CryptoError) _then;

  /// Create a copy of ZetrixSDKExceptions
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? error = null,
  }) {
    return _then(CryptoError(
      null == error
          ? _self.error
          : error // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class VcSchemaError
    with DiagnosticableTreeMixin
    implements ZetrixSDKExceptions {
  const VcSchemaError(this.error);

  final String error;

  /// Create a copy of ZetrixSDKExceptions
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $VcSchemaErrorCopyWith<VcSchemaError> get copyWith =>
      _$VcSchemaErrorCopyWithImpl<VcSchemaError>(this, _$identity);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(DiagnosticsProperty('type', 'ZetrixSDKExceptions.vcSchemaError'))
      ..add(DiagnosticsProperty('error', error));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is VcSchemaError &&
            (identical(other.error, error) || other.error == error));
  }

  @override
  int get hashCode => Object.hash(runtimeType, error);

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'ZetrixSDKExceptions.vcSchemaError(error: $error)';
  }
}

/// @nodoc
abstract mixin class $VcSchemaErrorCopyWith<$Res>
    implements $ZetrixSDKExceptionsCopyWith<$Res> {
  factory $VcSchemaErrorCopyWith(
          VcSchemaError value, $Res Function(VcSchemaError) _then) =
      _$VcSchemaErrorCopyWithImpl;
  @useResult
  $Res call({String error});
}

/// @nodoc
class _$VcSchemaErrorCopyWithImpl<$Res>
    implements $VcSchemaErrorCopyWith<$Res> {
  _$VcSchemaErrorCopyWithImpl(this._self, this._then);

  final VcSchemaError _self;
  final $Res Function(VcSchemaError) _then;

  /// Create a copy of ZetrixSDKExceptions
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? error = null,
  }) {
    return _then(VcSchemaError(
      null == error
          ? _self.error
          : error // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class ResolverError
    with DiagnosticableTreeMixin
    implements ZetrixSDKExceptions {
  const ResolverError(this.error);

  final String error;

  /// Create a copy of ZetrixSDKExceptions
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ResolverErrorCopyWith<ResolverError> get copyWith =>
      _$ResolverErrorCopyWithImpl<ResolverError>(this, _$identity);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(DiagnosticsProperty('type', 'ZetrixSDKExceptions.ResolverError'))
      ..add(DiagnosticsProperty('error', error));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ResolverError &&
            (identical(other.error, error) || other.error == error));
  }

  @override
  int get hashCode => Object.hash(runtimeType, error);

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'ZetrixSDKExceptions.ResolverError(error: $error)';
  }
}

/// @nodoc
abstract mixin class $ResolverErrorCopyWith<$Res>
    implements $ZetrixSDKExceptionsCopyWith<$Res> {
  factory $ResolverErrorCopyWith(
          ResolverError value, $Res Function(ResolverError) _then) =
      _$ResolverErrorCopyWithImpl;
  @useResult
  $Res call({String error});
}

/// @nodoc
class _$ResolverErrorCopyWithImpl<$Res>
    implements $ResolverErrorCopyWith<$Res> {
  _$ResolverErrorCopyWithImpl(this._self, this._then);

  final ResolverError _self;
  final $Res Function(ResolverError) _then;

  /// Create a copy of ZetrixSDKExceptions
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? error = null,
  }) {
    return _then(ResolverError(
      null == error
          ? _self.error
          : error // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class UnexpectedError
    with DiagnosticableTreeMixin
    implements ZetrixSDKExceptions {
  const UnexpectedError();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(DiagnosticsProperty('type', 'ZetrixSDKExceptions.unexpectedError'));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is UnexpectedError);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'ZetrixSDKExceptions.unexpectedError()';
  }
}

// dart format on
