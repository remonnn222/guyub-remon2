import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/user.dart';

/// Auth Repository Interface
/// Defines contract for authentication operations
abstract class AuthRepository {
  /// Login with email and password
  /// Returns AuthTokens and User on success
  Future<Either<Failure, (AuthTokens, User)>> login({
    required String email,
    required String password,
  });

  /// Logout current user
  Future<Either<Failure, void>> logout();

  /// Refresh access token using refresh token
  Future<Either<Failure, AuthTokens>> refreshToken();

  /// Get current authenticated user
  Future<Either<Failure, User>> getCurrentUser();

  /// Update user profile
  Future<Either<Failure, User>> updateProfile({
    required String name,
    String? email,
  });

  /// Change password
  Future<Either<Failure, void>> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  });

  /// Check if user is authenticated (has valid token)
  Future<bool> isAuthenticated();

  /// Clear authentication data (for logout or session expiry)
  Future<void> clearAuthData();
}
