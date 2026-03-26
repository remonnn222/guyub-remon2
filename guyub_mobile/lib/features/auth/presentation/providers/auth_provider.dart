import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:guyub_mobile/core/storage/secure_storage.dart';
import 'package:guyub_mobile/core/storage/token_manager.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/utils/rate_limiter.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/refresh_token_usecase.dart';
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
  late final LoginUseCase _loginUseCase;
  late final LogoutUseCase _logoutUseCase;
  late final GetCurrentUserUseCase _getCurrentUserUseCase;
  late final RefreshTokenUseCase _refreshTokenUseCase;

  @override
  AuthState build() {
    // Resolve use cases from DI container
    _loginUseCase = sl<LoginUseCase>();
    _logoutUseCase = sl<LogoutUseCase>();
    _getCurrentUserUseCase = sl<GetCurrentUserUseCase>();
    _refreshTokenUseCase = sl<RefreshTokenUseCase>();

    // Check initial auth status
    _checkAuthStatus();
    return const AuthState.initial();
  }

  /// Check if user is authenticated on app start
  Future<void> _checkAuthStatus() async {
    state = const AuthState.loading();

    final storage = sl<SecureStorageService>();
    final tokenManager = sl<TokenManager>();

    final rememberMe = await storage.getRememberMe();
    if (!rememberMe) {
      // Clear any stored tokens when the user chose not to stay logged in
      await storage.clearTokens();
      state = const AuthState.unauthenticated();
      return;
    }

    // Ensure we have valid tokens before attempting to load the user
    final tokenStatus = await tokenManager.getTokenStatus();
    if (tokenStatus.needsLogin) {
      state = const AuthState.unauthenticated();
      return;
    }

    if (tokenStatus.needsRefresh) {
      // Attempt a refresh token flow before proceeding
      final refreshResult = await _refreshTokenUseCase();
      await refreshResult.fold(
        (_) async {
          state = const AuthState.unauthenticated();
        },
        (_) async {
          final userResult = await _getCurrentUserUseCase();
          userResult.fold(
            (_) => state = const AuthState.unauthenticated(),
            (user) => state = AuthState.authenticated(user),
          );
        },
      );
      return;
    }

    // Tokens appear valid, load current user (cached or remote)
    final result = await _getCurrentUserUseCase();
    result.fold(
      (_) => state = const AuthState.unauthenticated(),
      (user) => state = AuthState.authenticated(user),
    );
  }

  /// Login with email and password
  Future<void> login(
    String email,
    String password, {
    bool rememberMe = false,
  }) async {
    state = const AuthState.loading();

    final params = LoginParams(email: email, password: password);
    final result = await _loginUseCase(params);

    result.fold(
      (failure) {
        state = AuthState.error(failure.message);
      },
      (data) async {
        final (_, user) = data;
        state = AuthState.authenticated(user);

        // Save remember me preference
        final storage = sl<SecureStorageService>();
        await storage.setRememberMe(rememberMe);
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

  /// Login with refresh token (for biometric authentication)
  Future<void> loginWithRefreshToken() async {
    state = const AuthState.loading();

    final result = await _refreshTokenUseCase();

    result.fold(
      (failure) {
        state = AuthState.error(failure.message);
      },
      (tokens) async {
        // Get user data after successful token refresh
        final userResult = await _getCurrentUserUseCase();
        userResult.fold(
          (userFailure) {
            state = AuthState.error(userFailure.message);
          },
          (user) {
            state = AuthState.authenticated(user);
          },
        );
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
  return authState.maybeWhen(authenticated: (user) => user, orElse: () => null);
}

/// Is Authenticated Provider
@riverpod
bool isAuthenticated(Ref ref) {
  final authState = ref.watch(authProvider);
  return authState.maybeWhen(authenticated: (_) => true, orElse: () => false);
}

/// Is Loading Provider
@riverpod
bool isAuthLoading(Ref ref) {
  final authState = ref.watch(authProvider);
  return authState.maybeWhen(loading: () => true, orElse: () => false);
}

/// Auth Error Provider
@riverpod
String? authError(Ref ref) {
  final authState = ref.watch(authProvider);
  return authState.maybeWhen(error: (message) => message, orElse: () => null);
}
