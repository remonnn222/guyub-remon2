import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

/// Refresh Token Use Case
/// Handles token refresh using stored refresh token
class RefreshTokenUseCase {
  final AuthRepository repository;

  RefreshTokenUseCase(this.repository);

  /// Execute token refresh
  /// Returns new AuthTokens on success
  Future<Either<Failure, AuthTokens>> call() {
    return repository.refreshToken();
  }
}