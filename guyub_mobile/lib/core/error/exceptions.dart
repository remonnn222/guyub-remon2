/// Base App Exception
class AppException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  AppException({
    required this.message,
    this.statusCode,
    this.data,
  });

  @override
  String toString() => message;
}

/// Network Exception (connection errors, timeouts)
class NetworkException extends AppException {
  NetworkException({
    required super.message,
    super.statusCode,
    super.data,
  });
}

/// Server Exception (5xx errors)
class ServerException extends AppException {
  ServerException({
    required super.message,
    super.statusCode,
    super.data,
  });
}

/// Unauthorized Exception (401)
class UnauthorizedException extends AppException {
  UnauthorizedException({
    required super.message,
    super.statusCode,
    super.data,
  });
}

/// Forbidden Exception (403)
class ForbiddenException extends AppException {
  ForbiddenException({
    required super.message,
    super.statusCode,
    super.data,
  });
}

/// Not Found Exception (404)
class NotFoundException extends AppException {
  NotFoundException({
    required super.message,
    super.statusCode,
    super.data,
  });
}

/// Validation Exception (400, 422)
class ValidationException extends AppException {
  final Map<String, dynamic>? errors;

  ValidationException({
    required super.message,
    super.statusCode,
    super.data,
    this.errors,
  });

  /// Get error message for a specific field
  String? getFieldError(String field) {
    if (errors == null) return null;
    final fieldErrors = errors![field];
    if (fieldErrors is List && fieldErrors.isNotEmpty) {
      return fieldErrors.first.toString();
    }
    if (fieldErrors is String) {
      return fieldErrors;
    }
    return null;
  }

  /// Get all field errors as a map
  Map<String, String> get fieldErrors {
    if (errors == null) return {};
    final result = <String, String>{};
    errors!.forEach((key, value) {
      if (value is List && value.isNotEmpty) {
        result[key] = value.first.toString();
      } else if (value is String) {
        result[key] = value;
      }
    });
    return result;
  }
}

/// Rate Limit Exception (429)
class RateLimitException extends AppException {
  final int? retryAfter;

  RateLimitException({
    required super.message,
    super.statusCode,
    super.data,
    this.retryAfter,
  });
}

/// Cache Exception
class CacheException extends AppException {
  CacheException({
    required super.message,
    super.data,
  }) : super(statusCode: null);
}

/// Database Exception
class DatabaseException extends AppException {
  DatabaseException({
    required super.message,
    super.data,
  }) : super(statusCode: null);
}

/// Sync Exception
class SyncException extends AppException {
  SyncException({
    required super.message,
    super.data,
  }) : super(statusCode: null);
}

/// Parse Exception
class ParseException extends AppException {
  ParseException({
    required super.message,
    super.data,
  }) : super(statusCode: null);
}

/// File Exception
class FileException extends AppException {
  FileException({
    required super.message,
    super.data,
  }) : super(statusCode: null);
}

/// Permission Exception
class PermissionException extends AppException {
  final String permission;

  PermissionException({
    required super.message,
    required this.permission,
    super.data,
  }) : super(statusCode: null);
}
