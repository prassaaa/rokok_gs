import 'package:equatable/equatable.dart';

/// Base Auth Event
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Check initial authentication status
class AuthCheckStatus extends AuthEvent {
  const AuthCheckStatus();
}

/// Login event
class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;

  const AuthLoginRequested({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}

/// Register event
class AuthRegisterRequested extends AuthEvent {
  final String name;
  final String email;
  final String password;
  final String passwordConfirmation;
  final int branchId;
  final String? phone;

  const AuthRegisterRequested({
    required this.name,
    required this.email,
    required this.password,
    required this.passwordConfirmation,
    required this.branchId,
    this.phone,
  });

  @override
  List<Object?> get props => [
        name,
        email,
        password,
        passwordConfirmation,
        branchId,
        phone,
      ];
}

/// Logout event
class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}

/// Get profile event
class AuthGetProfile extends AuthEvent {
  const AuthGetProfile();
}

/// Update profile event
class AuthUpdateProfile extends AuthEvent {
  final String name;
  final String email;
  final String? phone;
  final String? password;
  final String? passwordConfirmation;
  final String? avatarPath;

  const AuthUpdateProfile({
    required this.name,
    required this.email,
    this.phone,
    this.password,
    this.passwordConfirmation,
    this.avatarPath,
  });

  @override
  List<Object?> get props => [
        name,
        email,
        phone,
        password,
        passwordConfirmation,
        avatarPath,
      ];
}

/// Clear error state
class AuthClearError extends AuthEvent {
  const AuthClearError();
}
