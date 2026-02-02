import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/user.dart';

part 'auth_state.freezed.dart';

/// Auth State using Freezed for immutability
@freezed
class AuthState with _$AuthState {
  /// Initial state - checking auth status
  const factory AuthState.initial() = AuthStateInitial;

  /// Loading state - authenticating
  const factory AuthState.loading() = AuthStateLoading;

  /// Authenticated state - user is logged in
  const factory AuthState.authenticated(User user) = AuthStateAuthenticated;

  /// Unauthenticated state - user is logged out
  const factory AuthState.unauthenticated() = AuthStateUnauthenticated;

  /// Error state - authentication failed
  const factory AuthState.error(String message) = AuthStateError;
}

/// Extension methods for AuthState
extension AuthStateX on AuthState {
  /// Check if state is authenticated
  bool get isAuthenticated => this is AuthStateAuthenticated;

  /// Check if state is loading
  bool get isLoading => this is AuthStateLoading;

  /// Check if state is error
  bool get isError => this is AuthStateError;

  /// Check if state is unauthenticated
  bool get isUnauthenticated => this is AuthStateUnauthenticated;

  /// Get user if authenticated
  User? get user {
    return maybeWhen(
      authenticated: (user) => user,
      orElse: () => null,
    );
  }

  /// Get error message if error
  String? get errorMessage {
    return maybeWhen(
      error: (message) => message,
      orElse: () => null,
    );
  }
}
