import 'dart:convert';
import 'secure_storage.dart';

/// JWT Token Payload
class JwtPayload {
  final String subject;
  final int? issuedAt;
  final int? expiresAt;
  final String? email;
  final String? name;
  final Map<String, dynamic> raw;

  JwtPayload({
    required this.subject,
    this.issuedAt,
    this.expiresAt,
    this.email,
    this.name,
    required this.raw,
  });

  factory JwtPayload.fromJson(Map<String, dynamic> json) {
    return JwtPayload(
      subject: json['sub']?.toString() ?? '',
      issuedAt: json['iat'] as int?,
      expiresAt: json['exp'] as int?,
      email: json['email'] as String?,
      name: json['name'] as String?,
      raw: json,
    );
  }

  /// Check if token is expired
  bool get isExpired {
    if (expiresAt == null) return false;
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    return now >= expiresAt!;
  }

  /// Check if token will expire soon (within buffer time)
  bool willExpireSoon({Duration buffer = const Duration(minutes: 5)}) {
    if (expiresAt == null) return false;
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    return now >= (expiresAt! - buffer.inSeconds);
  }

  /// Get time until expiration
  Duration? get timeUntilExpiry {
    if (expiresAt == null) return null;
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final diff = expiresAt! - now;
    return diff > 0 ? Duration(seconds: diff) : Duration.zero;
  }

  /// Get expiry DateTime
  DateTime? get expiryDateTime {
    if (expiresAt == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(expiresAt! * 1000);
  }
}

/// Token Manager
/// Handles JWT token validation, parsing, and lifecycle management
class TokenManager {
  final SecureStorageService _storage;

  TokenManager({required SecureStorageService storage}) : _storage = storage;

  /// Parse JWT token to extract payload
  JwtPayload? parseToken(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;

      // Decode payload (middle part)
      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(normalized));
      final json = jsonDecode(decoded) as Map<String, dynamic>;

      return JwtPayload.fromJson(json);
    } catch (e) {
      return null;
    }
  }

  /// Get current access token payload
  Future<JwtPayload?> getAccessTokenPayload() async {
    final token = await _storage.getAccessToken();
    if (token == null) return null;
    return parseToken(token);
  }

  /// Get current refresh token payload
  Future<JwtPayload?> getRefreshTokenPayload() async {
    final token = await _storage.getRefreshToken();
    if (token == null) return null;
    return parseToken(token);
  }

  /// Check if access token is valid (exists and not expired)
  Future<bool> isAccessTokenValid() async {
    final token = await _storage.getAccessToken();
    if (token == null || token.isEmpty) return false;

    final payload = parseToken(token);
    if (payload == null) return false;

    return !payload.isExpired;
  }

  /// Check if access token needs refresh (expired or expiring soon)
  Future<bool> needsRefresh({Duration buffer = const Duration(minutes: 5)}) async {
    final token = await _storage.getAccessToken();
    if (token == null || token.isEmpty) return true;

    final payload = parseToken(token);
    if (payload == null) return true;

    return payload.willExpireSoon(buffer: buffer);
  }

  /// Check if refresh token is valid
  Future<bool> isRefreshTokenValid() async {
    final token = await _storage.getRefreshToken();
    if (token == null || token.isEmpty) return false;

    final payload = parseToken(token);
    if (payload == null) return false;

    return !payload.isExpired;
  }

  /// Save tokens and validate them
  Future<bool> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    // Validate tokens before saving
    final accessPayload = parseToken(accessToken);
    final refreshPayload = parseToken(refreshToken);

    if (accessPayload == null || accessPayload.isExpired) {
      return false;
    }

    if (refreshPayload == null || refreshPayload.isExpired) {
      return false;
    }

    await _storage.setAccessToken(accessToken);
    await _storage.setRefreshToken(refreshToken);
    return true;
  }

  /// Clear all tokens
  Future<void> clearTokens() async {
    await _storage.clearTokens();
  }

  /// Get token status
  Future<TokenStatus> getTokenStatus() async {
    final accessToken = await _storage.getAccessToken();
    final refreshToken = await _storage.getRefreshToken();

    if (accessToken == null || refreshToken == null) {
      return TokenStatus.noToken;
    }

    final accessPayload = parseToken(accessToken);
    final refreshPayload = parseToken(refreshToken);

    if (accessPayload == null || refreshPayload == null) {
      return TokenStatus.invalid;
    }

    if (refreshPayload.isExpired) {
      return TokenStatus.refreshExpired;
    }

    if (accessPayload.isExpired) {
      return TokenStatus.accessExpired;
    }

    if (accessPayload.willExpireSoon()) {
      return TokenStatus.expiringSoon;
    }

    return TokenStatus.valid;
  }

  /// Get user ID from token
  Future<String?> getUserIdFromToken() async {
    final payload = await getAccessTokenPayload();
    return payload?.subject;
  }
}

/// Token Status Enum
enum TokenStatus {
  /// No tokens stored
  noToken,

  /// Tokens are invalid (malformed)
  invalid,

  /// Access token expired, refresh token still valid
  accessExpired,

  /// Refresh token expired, need to re-login
  refreshExpired,

  /// Access token expiring soon, should refresh
  expiringSoon,

  /// All tokens are valid
  valid,
}

extension TokenStatusExtension on TokenStatus {
  bool get needsLogin => this == TokenStatus.noToken ||
                         this == TokenStatus.refreshExpired ||
                         this == TokenStatus.invalid;

  bool get needsRefresh => this == TokenStatus.accessExpired ||
                           this == TokenStatus.expiringSoon;

  bool get isValid => this == TokenStatus.valid;

  String get message {
    switch (this) {
      case TokenStatus.noToken:
        return 'Silakan login untuk melanjutkan';
      case TokenStatus.invalid:
        return 'Sesi tidak valid, silakan login kembali';
      case TokenStatus.accessExpired:
        return 'Sesi telah berakhir, memperbarui...';
      case TokenStatus.refreshExpired:
        return 'Sesi telah habis, silakan login kembali';
      case TokenStatus.expiringSoon:
        return 'Sesi akan segera berakhir';
      case TokenStatus.valid:
        return 'Sesi aktif';
    }
  }
}
