import 'package:equatable/equatable.dart';

/// Branch entity
class Branch extends Equatable {
  final int id;
  final String name;
  final String? code;
  final String? address;
  final bool isActive;

  const Branch({
    required this.id,
    required this.name,
    this.code,
    this.address,
    this.isActive = true,
  });

  @override
  List<Object?> get props => [id, name, code, address, isActive];
}

/// Area entity
class Area extends Equatable {
  final int id;
  final String name;
  final String? code;
  final String? description;
  final bool isActive;

  const Area({
    required this.id,
    required this.name,
    this.code,
    this.description,
    this.isActive = true,
  });

  @override
  List<Object?> get props => [id, name, code, description, isActive];
}

/// User entity - domain layer
class User extends Equatable {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final String? avatar;
  final bool isActive;
  final Branch? branch;
  final List<String> roles;
  final List<Area> areas;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const User({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.avatar,
    this.isActive = true,
    this.branch,
    this.roles = const [],
    this.areas = const [],
    this.createdAt,
    this.updatedAt,
  });

  /// Check if user has specific role
  bool hasRole(String role) => roles.contains(role);

  /// Check if user is admin
  bool get isAdmin => hasRole('Admin');

  /// Check if user is manager
  bool get isManager => hasRole('Manager');

  /// Check if user is sales
  bool get isSales => hasRole('Sales');

  /// Get primary role
  String get primaryRole => roles.isNotEmpty ? roles.first : 'User';

  @override
  List<Object?> get props => [
        id,
        name,
        email,
        phone,
        avatar,
        isActive,
        branch,
        roles,
        areas,
        createdAt,
        updatedAt,
      ];
}

/// Auth result entity - contains user and token after login
class AuthResult extends Equatable {
  final User user;
  final String token;

  const AuthResult({
    required this.user,
    required this.token,
  });

  @override
  List<Object?> get props => [user, token];
}
