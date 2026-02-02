import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/utils/rate_limiter.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import 'auth_state.dart';

part 'auth_provider.g.dart';

/// Login Rate Limiter Provider
/// Singleton rate limiter for login attempts
final loginRateLimiterProvider = Provider<LoginRateLimiter>((ref) {
  return LoginRateLimiter();
});

/// Auth State Notifier
/// Manages authentication state using Riverpod
@riverpod
class AuthNotifier extends _$AuthNotifier {
  @override
  AuthState build() {
    // Check initial auth status
    _checkAuthStatus();
    return const AuthState.initial();
  }

  late final LoginUseCase _loginUseCase;
  late final LogoutUseCase _logoutUseCase;
  late final GetCurrentUserUseCase _getCurrentUserUseCase;

  /// Check if user is authenticated on app start
  Future<void> _checkAuthStatus() async {
    state = const AuthState.loading();

    final result = await _getCurrentUserUseCase();

    result.fold(
      (failure) {
        state = const AuthState.unauthenticated();
      },
      (user) {
        state = AuthState.authenticated(user);
      },
    );
  }

  /// Login with email and password
  Future<void> login(String email, String password) async {
    state = const AuthState.loading();

    final params = LoginParams(email: email, password: password);
    final result = await _loginUseCase(params);

    result.fold(
      (failure) {
        state = AuthState.error(failure.message);
      },
      (data) {
        final (_, user) = data;
        state = AuthState.authenticated(user);
      },
    );
  }

  /// Logout current user
  Future<void> logout() async {
    state = const AuthState.loading();

    final result = await _logoutUseCase();

    result.fold(
      (failure) {
        // Even on failure, we should logout locally
        state = const AuthState.unauthenticated();
      },
      (_) {
        state = const AuthState.unauthenticated();
      },
    );
  }

  /// Refresh user data
  Future<void> refreshUser() async {
    final currentUser = state.maybeWhen(
      authenticated: (user) => user,
      orElse: () => null,
    );

    if (currentUser == null) return;

    final result = await _getCurrentUserUseCase();

    result.fold(
      (failure) {
        // Keep current state on failure
      },
      (user) {
        state = AuthState.authenticated(user);
      },
    );
  }

  /// Update user in state (after profile update)
  void updateUser(User user) {
    state = AuthState.authenticated(user);
  }

  /// Clear error state
  void clearError() {
    if (state is AuthStateError) {
      state = const AuthState.unauthenticated();
    }
  }
}

/// Current User Provider
/// Provides access to current authenticated user
@riverpod
User? currentUser(Ref ref) {
  final authState = ref.watch(authProvider);
  return authState.maybeWhen(
    authenticated: (user) => user,
    orElse: () => null,
  );
}

/// Is Authenticated Provider
@riverpod
bool isAuthenticated(Ref ref) {
  final authState = ref.watch(authProvider);
  return authState.maybeWhen(
    authenticated: (_) => true,
    orElse: () => false,
  );
}

/// Is Loading Provider
@riverpod
bool isAuthLoading(Ref ref) {
  final authState = ref.watch(authProvider);
  return authState.maybeWhen(
    loading: () => true,
    orElse: () => false,
  );
}

/// Auth Error Provider
@riverpod
String? authError(Ref ref) {
  final authState = ref.watch(authProvider);
  return authState.maybeWhen(
    error: (message) => message,
    orElse: () => null,
  );
}
