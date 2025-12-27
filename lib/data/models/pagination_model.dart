/// Pagination meta data model
/// Matches the backend pagination format from BaseApiController
class PaginationMeta {
  final int currentPage;
  final int? from;
  final int lastPage;
  final int perPage;
  final int? to;
  final int total;

  const PaginationMeta({
    required this.currentPage,
    this.from,
    required this.lastPage,
    required this.perPage,
    this.to,
    required this.total,
  });

  factory PaginationMeta.fromJson(Map<String, dynamic> json) {
    return PaginationMeta(
      currentPage: json['current_page'] ?? 1,
      from: json['from'],
      lastPage: json['last_page'] ?? 1,
      perPage: json['per_page'] ?? 15,
      to: json['to'],
      total: json['total'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'current_page': currentPage,
      'from': from,
      'last_page': lastPage,
      'per_page': perPage,
      'to': to,
      'total': total,
    };
  }

  /// Check if there's a next page
  bool get hasNextPage => currentPage < lastPage;

  /// Check if there's a previous page
  bool get hasPreviousPage => currentPage > 1;

  /// Check if it's the first page
  bool get isFirstPage => currentPage == 1;

  /// Check if it's the last page
  bool get isLastPage => currentPage == lastPage;

  /// Get next page number
  int get nextPage => hasNextPage ? currentPage + 1 : currentPage;

  /// Get previous page number
  int get previousPage => hasPreviousPage ? currentPage - 1 : currentPage;
}

/// Paginated API response wrapper
class PaginatedResponse<T> {
  final bool success;
  final String message;
  final List<T> data;
  final PaginationMeta meta;

  const PaginatedResponse({
    this.success = true,
    this.message = '',
    required this.data,
    required this.meta,
  });

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic> json) fromJsonT,
  ) {
    return PaginatedResponse<T>(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null
          ? (json['data'] as List)
              .map((item) => fromJsonT(item as Map<String, dynamic>))
              .toList()
          : [],
      meta: json['meta'] != null
          ? PaginationMeta.fromJson(json['meta'])
          : const PaginationMeta(
              currentPage: 1,
              lastPage: 1,
              perPage: 15,
              total: 0,
            ),
    );
  }

  /// Check if response is successful
  bool get isSuccess => success;

  /// Check if list is empty
  bool get isEmpty => data.isEmpty;

  /// Check if list is not empty
  bool get isNotEmpty => data.isNotEmpty;

  /// Check if there's more data to load
  bool get hasMore => meta.hasNextPage;
}
