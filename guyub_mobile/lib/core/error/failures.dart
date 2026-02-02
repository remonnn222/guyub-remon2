import 'package:equatable/equatable.dart';

/// Base Failure class for domain layer
/// Used with Either<Failure, Success> pattern
abstract class Failure extends Equatable {
  final String message;
  final int? statusCode;

  const Failure({
    required this.message,
    this.statusCode,
  });

  @override
  List<Object?> get props => [message, statusCode];
}

/// Server Failure (API errors)
class ServerFailure extends Failure {
  const ServerFailure({
    required super.message,
    super.statusCode,
  });
}

/// Network Failure (connection errors)
class NetworkFailure extends Failure {
  const NetworkFailure({
    super.message = 'Tidak dapat terhubung ke server',
    super.statusCode,
  });
}

/// Cache Failure (local storage errors)
class CacheFailure extends Failure {
  const CacheFailure({
    super.message = 'Gagal mengakses data lokal',
    super.statusCode,
  });
}

/// Validation Failure (form/input errors)
class ValidationFailure extends Failure {
  final Map<String, String>? fieldErrors;

  const ValidationFailure({
    required super.message,
    super.statusCode,
    this.fieldErrors,
  });

  @override
  List<Object?> get props => [message, statusCode, fieldErrors];
}

/// Auth Failure (authentication errors)
class AuthFailure extends Failure {
  const AuthFailure({
    required super.message,
    super.statusCode,
  });
}

/// Permission Failure (authorization errors)
class PermissionFailure extends Failure {
  final String? requiredPermission;

  const PermissionFailure({
    required super.message,
    super.statusCode,
    this.requiredPermission,
  });

  @override
  List<Object?> get props => [message, statusCode, requiredPermission];
}

/// Not Found Failure
class NotFoundFailure extends Failure {
  const NotFoundFailure({
    super.message = 'Data tidak ditemukan',
    super.statusCode = 404,
  });
}

/// Database Failure
class DatabaseFailure extends Failure {
  const DatabaseFailure({
    super.message = 'Gagal mengakses database',
    super.statusCode,
  });
}

/// Sync Failure (offline sync errors)
class SyncFailure extends Failure {
  final int? pendingCount;

  const SyncFailure({
    super.message = 'Gagal sinkronisasi data',
    super.statusCode,
    this.pendingCount,
  });

  @override
  List<Object?> get props => [message, statusCode, pendingCount];
}

/// Unauthorized Failure (401)
class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure({
    super.message = 'Sesi telah berakhir, silakan login kembali',
    super.statusCode = 401,
  });
}

/// Unknown Failure (fallback)
class UnknownFailure extends Failure {
  const UnknownFailure({
    super.message = 'Terjadi kesalahan yang tidak diketahui',
    super.statusCode,
  });
}

/// Rate Limit Failure (429)
class RateLimitFailure extends Failure {
  final int? retryAfterSeconds;

  const RateLimitFailure({
    super.message = 'Terlalu banyak permintaan',
    super.statusCode = 429,
    this.retryAfterSeconds,
  });

  @override
  List<Object?> get props => [message, statusCode, retryAfterSeconds];
}
