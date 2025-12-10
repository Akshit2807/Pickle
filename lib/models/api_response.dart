/// API Response wrapper for handling success and error states
class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? error;
  final String? message;
  final int? statusCode;
  final Map<String, dynamic>? rawResponse;

  ApiResponse({
    required this.success,
    this.data,
    this.error,
    this.message,
    this.statusCode,
    this.rawResponse,
  });

  factory ApiResponse.success({
    T? data,
    String? message,
    int? statusCode,
    Map<String, dynamic>? rawResponse,
  }) {
    return ApiResponse(
      success: true,
      data: data,
      message: message,
      statusCode: statusCode,
      rawResponse: rawResponse,
    );
  }

  factory ApiResponse.error({
    required String error,
    String? message,
    int? statusCode,
    Map<String, dynamic>? rawResponse,
  }) {
    return ApiResponse(
      success: false,
      error: error,
      message: message,
      statusCode: statusCode,
      rawResponse: rawResponse,
    );
  }

  bool get isSuccess => success;
  bool get isError => !success;
}

/// Pagination model for paginated responses
class PaginationMeta {
  final int totalCount;
  final int page;
  final int limit;
  final int totalPages;

  PaginationMeta({
    required this.totalCount,
    required this.page,
    required this.limit,
    required this.totalPages,
  });

  factory PaginationMeta.fromJson(Map<String, dynamic> json) {
    return PaginationMeta(
      totalCount: json['total_count'] ?? 0,
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 20,
      totalPages: json['total_pages'] ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_count': totalCount,
      'page': page,
      'limit': limit,
      'total_pages': totalPages,
    };
  }
}

/// Paginated response wrapper
class PaginatedResponse<T> {
  final List<T> data;
  final PaginationMeta pagination;

  PaginatedResponse({
    required this.data,
    required this.pagination,
  });
}
