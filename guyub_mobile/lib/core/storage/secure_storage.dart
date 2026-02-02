import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../config/constants/app_constants.dart';

/// Secure Storage Service
/// Handles secure storage of tokens and sensitive data
class SecureStorageService {
  final FlutterSecureStorage _storage;

  SecureStorageService()
      : _storage = const FlutterSecureStorage(
          aOptions: AndroidOptions(
            // Using default encryption (migrates from deprecated encryptedSharedPreferences)
          ),
          iOptions: IOSOptions(
            accessibility: KeychainAccessibility.first_unlock_this_device,
          ),
        );

  // Token Management

  /// Get access token
  Future<String?> getAccessToken() async {
    return await _storage.read(key: AppConstants.keyAccessToken);
  }

  /// Set access token
  Future<void> setAccessToken(String token) async {
    await _storage.write(key: AppConstants.keyAccessToken, value: token);
  }

  /// Get refresh token
  Future<String?> getRefreshToken() async {
    return await _storage.read(key: AppConstants.keyRefreshToken);
  }

  /// Set refresh token
  Future<void> setRefreshToken(String token) async {
    await _storage.write(key: AppConstants.keyRefreshToken, value: token);
  }

  /// Clear all tokens
  Future<void> clearTokens() async {
    await _storage.delete(key: AppConstants.keyAccessToken);
    await _storage.delete(key: AppConstants.keyRefreshToken);
  }

  /// Check if user is authenticated (has valid tokens)
  Future<bool> isAuthenticated() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  // User Data Management

  /// Save user data as JSON
  Future<void> saveUser(Map<String, dynamic> user) async {
    await _storage.write(
      key: AppConstants.keyUser,
      value: jsonEncode(user),
    );
  }

  /// Get user data
  Future<Map<String, dynamic>?> getUser() async {
    final userJson = await _storage.read(key: AppConstants.keyUser);
    if (userJson == null) return null;
    return jsonDecode(userJson) as Map<String, dynamic>;
  }

  /// Clear user data
  Future<void> clearUser() async {
    await _storage.delete(key: AppConstants.keyUser);
  }

  // Generic Storage Methods

  /// Read a value
  Future<String?> read(String key) async {
    return await _storage.read(key: key);
  }

  /// Write a value
  Future<void> write(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  /// Delete a value
  Future<void> delete(String key) async {
    await _storage.delete(key: key);
  }

  /// Check if key exists
  Future<bool> containsKey(String key) async {
    return await _storage.containsKey(key: key);
  }

  /// Delete all stored data
  Future<void> deleteAll() async {
    await _storage.deleteAll();
  }

  /// Clear all authentication related data (for logout)
  Future<void> clearAuthData() async {
    await clearTokens();
    await clearUser();
  }
}
