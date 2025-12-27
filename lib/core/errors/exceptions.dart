/// Base exception class for the application
abstract class AppException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  const AppException({
    required this.message,
    this.statusCode,
    this.data,
  });

  @override
  String toString() => message;
}

/// Exception thrown when server returns an error
class ServerException extends AppException {
  const ServerException({
    required super.message,
    super.statusCode,
    super.data,
  });

  factory ServerException.fromStatusCode(int statusCode, [String? message]) {
    switch (statusCode) {
      case 400:
        return ServerException(
          message: message ?? 'Bad request',
          statusCode: statusCode,
        );
      case 401:
        return ServerException(
          message: message ?? 'Unauthorized. Please login again.',
          statusCode: statusCode,
        );
      case 403:
        return ServerException(
          message: message ?? 'Access denied',
          statusCode: statusCode,
        );
      case 404:
        return ServerException(
          message: message ?? 'Resource not found',
          statusCode: statusCode,
        );
      case 422:
        return ServerException(
          message: message ?? 'Validation error',
          statusCode: statusCode,
        );
      case 500:
        return ServerException(
          message: message ?? 'Internal server error',
          statusCode: statusCode,
        );
      case 502:
        return ServerException(
          message: message ?? 'Bad gateway',
          statusCode: statusCode,
        );
      case 503:
        return ServerException(
          message: message ?? 'Service unavailable',
          statusCode: statusCode,
        );
      default:
        return ServerException(
          message: message ?? 'Something went wrong',
          statusCode: statusCode,
        );
    }
  }
}

/// Exception thrown when there's no internet connection
class NetworkException extends AppException {
  const NetworkException({
    super.message = 'No internet connection. Please check your network.',
  });
}

/// Exception thrown when cache operation fails
class CacheException extends AppException {
  const CacheException({
    super.message = 'Cache error occurred',
  });
}

/// Exception thrown when validation fails
class ValidationException extends AppException {
  final Map<String, List<String>>? errors;

  const ValidationException({
    required super.message,
    this.errors,
  });
}

/// Exception thrown when authentication fails
class AuthException extends AppException {
  const AuthException({
    required super.message,
    super.statusCode,
  });
}

/// Exception thrown for timeout errors
class TimeoutException extends AppException {
  const TimeoutException({
    super.message = 'Connection timeout. Please try again.',
  });
}

/// Exception thrown for parsing errors
class ParseException extends AppException {
  const ParseException({
    super.message = 'Failed to parse response data',
  });
}

/// Exception thrown when there's insufficient stock
class InsufficientStockException extends AppException {
  const InsufficientStockException({
    required super.message,
  });
}
