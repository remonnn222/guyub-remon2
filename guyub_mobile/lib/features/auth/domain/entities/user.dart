import 'package:equatable/equatable.dart';

/// User Entity
/// Core business object for user data
class User extends Equatable {
  final int id;
  final String name;
  final String email;
  final String? avatarUrl;
  final String status;
  final String type;
  final Role? role;
  final List<String> permissions;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const User({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
    required this.status,
    required this.type,
    this.role,
    this.permissions = const [],
    this.createdAt,
    this.updatedAt,
  });

  /// Check if user is active
  bool get isActive => status == 'active';

  /// Check if user is super admin
  bool get isSuperAdmin => role?.name == 'super_admin';

  /// Check if user has a specific permission
  bool hasPermission(String permission) {
    if (isSuperAdmin) return true;
    return permissions.contains(permission);
  }

  /// Check if user has any of the permissions
  bool hasAnyPermission(List<String> perms) {
    if (isSuperAdmin) return true;
    return perms.any((perm) => permissions.contains(perm));
  }

  /// Check if user has all of the permissions
  bool hasAllPermissions(List<String> perms) {
    if (isSuperAdmin) return true;
    return perms.every((perm) => permissions.contains(perm));
  }

  /// Get user initials for avatar fallback
  String get initials {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  @override
  List<Object?> get props => [
        id,
        name,
        email,
        avatarUrl,
        status,
        type,
        role,
        permissions,
        createdAt,
        updatedAt,
      ];

  User copyWith({
    int? id,
    String? name,
    String? email,
    String? avatarUrl,
    String? status,
    String? type,
    Role? role,
    List<String>? permissions,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      status: status ?? this.status,
      type: type ?? this.type,
      role: role ?? this.role,
      permissions: permissions ?? this.permissions,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Role Entity
class Role extends Equatable {
  final int id;
  final String name;
  final String? description;
  final int level;

  const Role({
    required this.id,
    required this.name,
    this.description,
    required this.level,
  });

  @override
  List<Object?> get props => [id, name, description, level];
}

/// Auth Tokens
class AuthTokens extends Equatable {
  final String accessToken;
  final String refreshToken;
  final int expiresIn;

  const AuthTokens({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
  });

  @override
  List<Object?> get props => [accessToken, refreshToken, expiresIn];
}
