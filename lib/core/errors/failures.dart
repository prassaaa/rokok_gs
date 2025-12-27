import 'package:equatable/equatable.dart';

/// Base failure class for the application
/// Used with Either type from dartz package
abstract class Failure extends Equatable {
  final String message;
  final int? statusCode;

  const Failure({
    required this.message,
    this.statusCode,
  });

  @override
  List<Object?> get props => [message, statusCode];
}

/// Failure for server-related errors
class ServerFailure extends Failure {
  const ServerFailure({
    required super.message,
    super.statusCode,
  });
}

/// Failure for network-related errors
class NetworkFailure extends Failure {
  const NetworkFailure({
    super.message = 'No internet connection. Please check your network.',
  });
}

/// Failure for cache-related errors
class CacheFailure extends Failure {
  const CacheFailure({
    super.message = 'Cache error occurred',
  });
}

/// Failure for validation errors
class ValidationFailure extends Failure {
  final Map<String, List<String>>? errors;

  const ValidationFailure({
    required super.message,
    this.errors,
  });

  @override
  List<Object?> get props => [message, errors];
}

/// Failure for authentication errors
class AuthFailure extends Failure {
  const AuthFailure({
    required super.message,
    super.statusCode,
  });
}

/// Failure for timeout errors
class TimeoutFailure extends Failure {
  const TimeoutFailure({
    super.message = 'Connection timeout. Please try again.',
  });
}

/// Failure for unexpected errors
class UnexpectedFailure extends Failure {
  const UnexpectedFailure({
    super.message = 'An unexpected error occurred',
  });
}

/// Failure for permission denied errors
class PermissionFailure extends Failure {
  const PermissionFailure({
    super.message = 'Permission denied',
  });
}

/// Failure for not found errors
class NotFoundFailure extends Failure {
  const NotFoundFailure({
    super.message = 'Resource not found',
  });
}

/// Failure for insufficient stock
class InsufficientStockFailure extends Failure {
  const InsufficientStockFailure({
    required super.message,
  });
}
