import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'exceptions.dart';
import 'failures.dart';

/// Global Error Handler
/// Provides centralized error handling and logging
class ErrorHandler {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
    ),
  );

  /// Initialize error handling
  static void init() {
    // Catch Flutter errors
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      _logError('Flutter Error', details.exception, details.stack);
    };

    // Catch async errors
    PlatformDispatcher.instance.onError = (error, stack) {
      _logError('Platform Error', error, stack);
      return true;
    };
  }

  /// Log error with context
  static void _logError(String context, Object error, StackTrace? stack) {
    if (kDebugMode) {
      _logger.e('[$context]', error: error, stackTrace: stack);
    }
    // Send to crash reporting service
    FirebaseCrashlytics.instance.recordError(error, stack);
  }

  /// Handle exception and return appropriate failure
  static Failure handleException(dynamic exception) {
    _logError('Exception', exception, StackTrace.current);

    if (exception is ServerException) {
      return ServerFailure(
        message: exception.message,
        statusCode: exception.statusCode,
      );
    }

    if (exception is CacheException) {
      return CacheFailure(message: exception.message);
    }

    if (exception is NetworkException) {
      return NetworkFailure(message: exception.message);
    }

    if (exception is DioException) {
      return _handleDioException(exception);
    }

    if (exception is SocketException) {
      return const NetworkFailure(
        message:
            'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.',
      );
    }

    if (exception is TimeoutException) {
      return const NetworkFailure(
        message: 'Koneksi timeout. Silakan coba lagi.',
      );
    }

    if (exception is FormatException) {
      return const ServerFailure(
        message: 'Format data tidak valid dari server.',
      );
    }

    // Default error
    return ServerFailure(message: exception.toString());
  }

  /// Handle Dio specific exceptions
  static Failure _handleDioException(DioException exception) {
    switch (exception.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const NetworkFailure(
          message: 'Koneksi timeout. Silakan coba lagi.',
        );

      case DioExceptionType.connectionError:
        return const NetworkFailure(
          message:
              'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.',
        );

      case DioExceptionType.badCertificate:
        return const NetworkFailure(
          message: 'Sertifikat keamanan tidak valid.',
        );

      case DioExceptionType.badResponse:
        return _handleBadResponse(exception.response);

      case DioExceptionType.cancel:
        return const ServerFailure(message: 'Permintaan dibatalkan.');

      case DioExceptionType.unknown:
        if (exception.error is SocketException) {
          return const NetworkFailure(
            message:
                'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.',
          );
        }
        return ServerFailure(
          message: exception.message ?? 'Terjadi kesalahan tidak dikenal.',
        );
    }
  }

  /// Handle HTTP error responses
  static Failure _handleBadResponse(Response? response) {
    if (response == null) {
      return const ServerFailure(message: 'Tidak ada respons dari server.');
    }

    final statusCode = response.statusCode ?? 0;
    final data = response.data;

    // Try to extract error message from response
    String message = 'Terjadi kesalahan pada server.';
    if (data is Map<String, dynamic>) {
      message =
          data['message'] as String? ?? data['error'] as String? ?? message;
    }

    switch (statusCode) {
      case 400:
        return ServerFailure(
          message: message.isNotEmpty ? message : 'Permintaan tidak valid.',
          statusCode: 400,
        );

      case 401:
        return UnauthorizedFailure(message: message);

      case 403:
        return ServerFailure(
          message: 'Anda tidak memiliki akses ke resource ini.',
          statusCode: 403,
        );

      case 404:
        return ServerFailure(message: 'Data tidak ditemukan.', statusCode: 404);

      case 409:
        return ServerFailure(
          message: message.isNotEmpty ? message : 'Konflik data.',
          statusCode: 409,
        );

      case 422:
        return ValidationFailure(
          message: message,
          errors: _extractValidationErrors(data),
        );

      case 429:
        return const ServerFailure(
          message: 'Terlalu banyak permintaan. Silakan coba lagi nanti.',
          statusCode: 429,
        );

      case 500:
      case 502:
      case 503:
      case 504:
        return const ServerFailure(
          message: 'Server sedang mengalami gangguan. Silakan coba lagi nanti.',
          statusCode: 500,
        );

      default:
        return ServerFailure(message: message, statusCode: statusCode);
    }
  }

  /// Extract validation errors from response
  static Map<String, List<String>>? _extractValidationErrors(dynamic data) {
    if (data is! Map<String, dynamic>) return null;

    final errors = data['errors'];
    if (errors is! Map<String, dynamic>) return null;

    return errors.map((key, value) {
      if (value is List) {
        return MapEntry(key, value.map((e) => e.toString()).toList());
      }
      return MapEntry(key, [value.toString()]);
    });
  }

  /// Show user-friendly error message
  static String getUserFriendlyMessage(Failure failure) {
    if (failure is ValidationFailure && failure.errors != null) {
      final firstError = failure.errors!.values.first.first;
      return firstError;
    }
    return failure.message;
  }
}

/// Validation Failure with field-level errors
class ValidationFailure extends Failure {
  final Map<String, List<String>>? errors;

  const ValidationFailure({
    super.message = 'Validasi gagal',
    this.errors,
    super.statusCode = 422,
  });

  @override
  List<Object?> get props => [message, statusCode, errors];
}
