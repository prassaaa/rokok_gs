import 'package:equatable/equatable.dart';

import '../../../domain/entities/user.dart';

/// Auth status enum
enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

/// Auth State
class AuthState extends Equatable {
  final AuthStatus status;
  final User? user;
  final String? errorMessage;
  final Map<String, List<String>>? validationErrors;
  final bool isProfileUpdating;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
    this.validationErrors,
    this.isProfileUpdating = false,
  });

  /// Initial state
  factory AuthState.initial() => const AuthState(
        status: AuthStatus.initial,
      );

  /// Loading state
  AuthState loading() => copyWith(
        status: AuthStatus.loading,
        errorMessage: null,
        validationErrors: null,
      );

  /// Authenticated state
  AuthState authenticated(User user) => copyWith(
        status: AuthStatus.authenticated,
        user: user,
        errorMessage: null,
        validationErrors: null,
        isProfileUpdating: false,
      );

  /// Unauthenticated state
  AuthState unauthenticated() => const AuthState(
        status: AuthStatus.unauthenticated,
        user: null,
        errorMessage: null,
        validationErrors: null,
        isProfileUpdating: false,
      );

  /// Error state
  AuthState error(String message, {Map<String, List<String>>? errors}) =>
      copyWith(
        status: AuthStatus.error,
        errorMessage: message,
        validationErrors: errors,
        isProfileUpdating: false,
      );

  /// Profile updating state
  AuthState profileUpdating() => copyWith(
        isProfileUpdating: true,
        errorMessage: null,
        validationErrors: null,
      );

  /// Copy with method
  AuthState copyWith({
    AuthStatus? status,
    User? user,
    String? errorMessage,
    Map<String, List<String>>? validationErrors,
    bool? isProfileUpdating,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage,
      validationErrors: validationErrors,
      isProfileUpdating: isProfileUpdating ?? this.isProfileUpdating,
    );
  }

  /// Check if authenticated
  bool get isAuthenticated => status == AuthStatus.authenticated;

  /// Check if loading
  bool get isLoading => status == AuthStatus.loading;

  /// Check if has error
  bool get hasError =>
      status == AuthStatus.error ||
      errorMessage != null ||
      validationErrors != null;

  /// Get validation error for field
  String? getFieldError(String field) {
    if (validationErrors == null) return null;
    final errors = validationErrors![field];
    return errors?.isNotEmpty == true ? errors!.first : null;
  }

  @override
  List<Object?> get props => [
        status,
        user,
        errorMessage,
        validationErrors,
        isProfileUpdating,
      ];
}
