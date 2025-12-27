/// Generic API response wrapper model
/// Matches the backend response format from BaseApiController
class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final Map<String, dynamic>? errors;

  const ApiResponse({
    required this.success,
    required this.message,
    this.data,
    this.errors,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic json)? fromJsonT,
  ) {
    return ApiResponse<T>(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null && fromJsonT != null
          ? fromJsonT(json['data'])
          : json['data'],
      errors: json['errors'] != null
          ? Map<String, dynamic>.from(json['errors'])
          : null,
    );
  }

  /// Check if response is successful
  bool get isSuccess => success;

  /// Check if response has error
  bool get hasError => !success;

  /// Get first error message from errors map
  String? get firstError {
    if (errors == null || errors!.isEmpty) return null;
    final firstValue = errors!.values.first;
    if (firstValue is List && firstValue.isNotEmpty) {
      return firstValue.first.toString();
    }
    return firstValue.toString();
  }
}

/// API response for list data
class ApiListResponse<T> {
  final bool success;
  final String message;
  final List<T> data;

  const ApiListResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory ApiListResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic> json) fromJsonT,
  ) {
    return ApiListResponse<T>(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null
          ? (json['data'] as List)
              .map((item) => fromJsonT(item as Map<String, dynamic>))
              .toList()
          : [],
    );
  }
}
