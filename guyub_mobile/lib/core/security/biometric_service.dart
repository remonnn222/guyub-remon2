import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth/error_codes.dart' as auth_error;
import '../storage/secure_storage.dart';

/// App-specific Biometric Authentication Type
enum AppBiometricType {
  fingerprint,
  faceId,
  iris,
  none,
}

/// Biometric Authentication Result
enum BiometricResult {
  success,
  failed,
  cancelled,
  notAvailable,
  notEnrolled,
  lockedOut,
  permanentlyLockedOut,
  error,
}

/// Biometric Service
/// Handles biometric authentication (fingerprint, Face ID)
class BiometricService {
  final LocalAuthentication _localAuth;
  final SecureStorageService _storage;

  static const String _biometricEnabledKey = 'biometric_enabled';
  static const String _biometricUserEmailKey = 'biometric_user_email';

  BiometricService({
    LocalAuthentication? localAuth,
    required SecureStorageService storage,
  })  : _localAuth = localAuth ?? LocalAuthentication(),
        _storage = storage;

  /// Check if device supports biometric authentication
  Future<bool> get isSupported async {
    try {
      return await _localAuth.canCheckBiometrics ||
          await _localAuth.isDeviceSupported();
    } on PlatformException {
      return false;
    }
  }

  /// Check if biometric is enrolled on device
  Future<bool> get isEnrolled async {
    try {
      final biometrics = await _localAuth.getAvailableBiometrics();
      return biometrics.isNotEmpty;
    } on PlatformException {
      return false;
    }
  }

  /// Get available biometric types
  Future<List<AppBiometricType>> getAvailableBiometrics() async {
    try {
      final biometrics = await _localAuth.getAvailableBiometrics();
      return biometrics.map((b) {
        if (b == BiometricType.fingerprint) {
          return AppBiometricType.fingerprint;
        } else if (b == BiometricType.face) {
          return AppBiometricType.faceId;
        } else if (b == BiometricType.iris) {
          return AppBiometricType.iris;
        }
        return AppBiometricType.none;
      }).where((b) => b != AppBiometricType.none).toList();
    } on PlatformException {
      return [];
    }
  }

  /// Authenticate using biometrics
  Future<BiometricResult> authenticate({
    String reason = 'Verifikasi identitas Anda',
    bool biometricOnly = false,
  }) async {
    try {
      final didAuthenticate = await _localAuth.authenticate(
        localizedReason: reason,
        options: AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: biometricOnly,
          useErrorDialogs: true,
        ),
      );

      return didAuthenticate ? BiometricResult.success : BiometricResult.failed;
    } on PlatformException catch (e) {
      return _handlePlatformException(e);
    }
  }

  /// Handle platform exceptions
  BiometricResult _handlePlatformException(PlatformException e) {
    switch (e.code) {
      case auth_error.notAvailable:
        return BiometricResult.notAvailable;
      case auth_error.notEnrolled:
        return BiometricResult.notEnrolled;
      case auth_error.lockedOut:
        return BiometricResult.lockedOut;
      case auth_error.permanentlyLockedOut:
        return BiometricResult.permanentlyLockedOut;
      default:
        return BiometricResult.error;
    }
  }

  /// Check if biometric login is enabled for user
  Future<bool> get isBiometricLoginEnabled async {
    final value = await _storage.read(_biometricEnabledKey);
    return value == 'true';
  }

  /// Enable biometric login for current user
  Future<bool> enableBiometricLogin({
    required String email,
  }) async {
    final result = await authenticate(
      reason: 'Verifikasi untuk mengaktifkan login biometrik',
    );

    if (result != BiometricResult.success) {
      return false;
    }

    await _storage.write(_biometricEnabledKey, 'true');
    await _storage.write(_biometricUserEmailKey, email);

    return true;
  }

  /// Disable biometric login
  Future<void> disableBiometricLogin() async {
    await _storage.delete(_biometricEnabledKey);
    await _storage.delete(_biometricUserEmailKey);
  }

  /// Confirm biometric authentication for login flow
  Future<bool> authenticateBiometricLogin() async {
    final result = await authenticate(
      reason: 'Masuk dengan biometrik',
      biometricOnly: true,
    );

    return result == BiometricResult.success;
  }

  /// Get stored biometric user email
  Future<String?> getBiometricUserEmail() async {
    return await _storage.read(_biometricUserEmailKey);
  }

  /// Cancel any ongoing authentication
  Future<void> cancelAuthentication() async {
    await _localAuth.stopAuthentication();
  }
}

extension BiometricResultExtension on BiometricResult {
  bool get isSuccess => this == BiometricResult.success;

  String get message {
    switch (this) {
      case BiometricResult.success:
        return 'Autentikasi berhasil';
      case BiometricResult.failed:
        return 'Autentikasi gagal';
      case BiometricResult.cancelled:
        return 'Autentikasi dibatalkan';
      case BiometricResult.notAvailable:
        return 'Biometrik tidak tersedia di perangkat ini';
      case BiometricResult.notEnrolled:
        return 'Belum ada biometrik yang terdaftar';
      case BiometricResult.lockedOut:
        return 'Terlalu banyak percobaan. Coba lagi nanti.';
      case BiometricResult.permanentlyLockedOut:
        return 'Biometrik terkunci. Gunakan PIN/password perangkat.';
      case BiometricResult.error:
        return 'Terjadi kesalahan pada autentikasi biometrik';
    }
  }
}

extension AppBiometricTypeExtension on AppBiometricType {
  String get displayName {
    switch (this) {
      case AppBiometricType.fingerprint:
        return 'Sidik Jari';
      case AppBiometricType.faceId:
        return 'Face ID';
      case AppBiometricType.iris:
        return 'Iris';
      case AppBiometricType.none:
        return 'Tidak tersedia';
    }
  }

  String get icon {
    switch (this) {
      case AppBiometricType.fingerprint:
        return 'fingerprint';
      case AppBiometricType.faceId:
        return 'face';
      case AppBiometricType.iris:
        return 'remove_red_eye';
      case AppBiometricType.none:
        return 'lock';
    }
  }
}
