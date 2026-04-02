import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import '../../../../config/constants/app_constants.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/security/biometric_service.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../../../core/utils/rate_limiter.dart';
import '../../../../core/services/fcm_token_service.dart';
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
  late final LoginUseCase _loginUseCase;
  late final LogoutUseCase _logoutUseCase;
  late final GetCurrentUserUseCase _getCurrentUserUseCase;

  @override
  AuthState build() {
    // Resolve use cases from DI container
    _loginUseCase = sl<LoginUseCase>();
    _logoutUseCase = sl<LogoutUseCase>();
    _getCurrentUserUseCase = sl<GetCurrentUserUseCase>();

    // Check initial auth status
    _checkAuthStatus();
    return const AuthState.initial();
  }

  /// Check if user is authenticated on app start
  /// Includes biometric auto-login flow
  Future<void> _checkAuthStatus() async {
    state = const AuthState.loading();

    // Try to authenticate user with stored credentials
    final result = await _getCurrentUserUseCase();

    result.fold(
      (failure) async {
        // User is not authenticated, check if biometric login is available
        await _checkBiometricAutoLogin();
      },
      (user) {
        state = AuthState.authenticated(user);
      },
    );
  }

  /// Check and perform biometric auto-login if enabled
  /// This is called when user is not authenticated but biometric credentials exist
  Future<void> _checkBiometricAutoLogin() async {
    try {
      final biometricService = sl<BiometricService>();
      sl<SecureStorageService>();

      // Check if biometric login is enabled
      final isBiometricEnabled = await biometricService.isBiometricLoginEnabled;

      if (!isBiometricEnabled) {
        state = const AuthState.unauthenticated();
        return;
      }

      // Get biometric credentials (this will prompt biometric verification)
      final credentials = await biometricService.getBiometricCredentials();

      if (credentials == null) {
        // Biometric authentication failed
        state = const AuthState.unauthenticated();
        return;
      }

      final (email, password) = credentials;

      // Try to login with retrieved credentials
      await login(email, password);
    } catch (e) {
      // On any error, go to unauthenticated state
      state = const AuthState.unauthenticated();
    }
  }

  /// Login with email and password
  /// [rememberMe] - if true, refresh token will be persisted on device
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
        // Clear remember me flag on login failure
        _clearRememberMe();
        state = AuthState.error(failure.message);
      },
      (data) {
        final (_, user) = data;

        // Set user identifier for crash reporting
        FirebaseCrashlytics.instance.setUserIdentifier(user.id.toString());

        // Send FCM token to backend
        final fcmTokenService = sl<FcmTokenService>();
        fcmTokenService.sendTokenToBackend(user.id.toString());

        // Handle remember me preference
        if (rememberMe) {
          _setRememberMe();
        } else {
          _clearRememberMe();
        }

        state = AuthState.authenticated(user);
      },
    );
  }

  /// Logout current user
  Future<void> logout() async {
    state = const AuthState.loading();

    // Clear remember me flag
    _clearRememberMe();

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

  /// Set remember me preference
  Future<void> _setRememberMe() async {
    final storage = sl<SecureStorageService>();
    await storage.write(AppConstants.keyRememberMe, 'true');
  }

  /// Clear remember me preference
  Future<void> _clearRememberMe() async {
    final storage = sl<SecureStorageService>();
    await storage.delete(AppConstants.keyRememberMe);
  }

  /// Check if remember me is enabled
  Future<bool> isRememberMeEnabled() async {
    final storage = sl<SecureStorageService>();
    final value = await storage.read(AppConstants.keyRememberMe);
    return value == 'true';
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

/// Check if biometric login is enabled
@riverpod
Future<bool> isBiometricEnabled(Ref ref) async {
  final biometricService = sl<BiometricService>();
  return biometricService.isBiometricLoginEnabled;
}

/// Get available biometric types on device
@riverpod
Future<List<AppBiometricType>> availableBiometrics(Ref ref) async {
  final biometricService = sl<BiometricService>();
  return biometricService.getAvailableBiometrics();
}

/// Check if biometric is supported on device
@riverpod
Future<bool> isBiometricSupported(Ref ref) async {
  final biometricService = sl<BiometricService>();
  return biometricService.isSupported;
}

/// Check if biometric is enrolled on device
@riverpod
Future<bool> isBiometricEnrolled(Ref ref) async {
  final biometricService = sl<BiometricService>();
  return biometricService.isEnrolled;
}

/// Remember Me Provider - checks if user has enabled remember me
@riverpod
Future<bool> isRememberMeEnabled(Ref ref) async {
  final notifier = ref.read(authProvider.notifier);
  return notifier.isRememberMeEnabled();
}
