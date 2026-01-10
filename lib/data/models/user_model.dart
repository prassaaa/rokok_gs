import '../../domain/entities/user.dart';

/// Branch model - data layer
class BranchModel extends Branch {
  const BranchModel({
    required super.id,
    required super.name,
    super.code,
    super.address,
    super.isActive,
  });

  factory BranchModel.fromJson(Map<String, dynamic> json) {
    return BranchModel(
      id: _parseInt(json['id']),
      name: json['name'] ?? '',
      code: json['code'],
      address: json['address'],
      isActive: json['is_active'] == true || json['is_active'] == 1 || json['is_active'] == '1',
    );
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'address': address,
      'is_active': isActive,
    };
  }

  Branch toEntity() => Branch(
        id: id,
        name: name,
        code: code,
        address: address,
        isActive: isActive,
      );
}

/// Area model - data layer
class AreaModel extends Area {
  const AreaModel({
    required super.id,
    required super.name,
    super.code,
    super.description,
    super.isActive,
  });

  factory AreaModel.fromJson(Map<String, dynamic> json) {
    return AreaModel(
      id: _parseInt(json['id']),
      name: json['name'] ?? '',
      code: json['code'],
      description: json['description'],
      isActive: json['is_active'] == true || json['is_active'] == 1 || json['is_active'] == '1',
    );
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'description': description,
      'is_active': isActive,
    };
  }

  Area toEntity() => Area(
        id: id,
        name: name,
        code: code,
        description: description,
        isActive: isActive,
      );
}

/// User model - data layer
class UserModel extends User {
  const UserModel({
    required super.id,
    required super.name,
    required super.email,
    super.phone,
    super.avatar,
    super.isActive,
    super.branch,
    super.roles,
    super.areas,
    super.createdAt,
    super.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: _parseInt(json['id']),
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      avatar: json['avatar'],
      isActive: json['is_active'] == true || json['is_active'] == 1 || json['is_active'] == '1',
      branch: json['branch'] != null
          ? BranchModel.fromJson(json['branch']).toEntity()
          : null,
      roles: json['roles'] != null
          ? List<String>.from(json['roles'])
          : const [],
      areas: json['areas'] != null
          ? (json['areas'] as List)
              .map((e) => AreaModel.fromJson(e).toEntity())
              .toList()
          : const [],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'])
          : null,
    );
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'avatar': avatar,
      'is_active': isActive,
      'roles': roles,
    };
  }

  User toEntity() => User(
        id: id,
        name: name,
        email: email,
        phone: phone,
        avatar: avatar,
        isActive: isActive,
        branch: branch,
        roles: roles,
        areas: areas,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

  factory UserModel.fromEntity(User user) {
    return UserModel(
      id: user.id,
      name: user.name,
      email: user.email,
      phone: user.phone,
      avatar: user.avatar,
      isActive: user.isActive,
      branch: user.branch,
      roles: user.roles,
      areas: user.areas,
      createdAt: user.createdAt,
      updatedAt: user.updatedAt,
    );
  }
}

/// Auth result model - data layer
class AuthResultModel extends AuthResult {
  const AuthResultModel({
    required super.user,
    required super.token,
  });

  factory AuthResultModel.fromJson(Map<String, dynamic> json) {
    return AuthResultModel(
      user: UserModel.fromJson(json['user']).toEntity(),
      token: json['token'] ?? '',
    );
  }

  AuthResult toEntity() => AuthResult(
        user: user,
        token: token,
      );
}
