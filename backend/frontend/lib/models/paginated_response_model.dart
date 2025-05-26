// lib/models/paginated_response_model.dart

class PaginatedResponse<T> {
  final int total;
  final int limit;
  final int offset;
  final List<T> data;

  PaginatedResponse({
    required this.total,
    required this.limit,
    required this.offset,
    required this.data,
  });

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    return PaginatedResponse<T>(
      total: json['total'] as int,
      limit: json['limit'] as int,
      offset: json['offset'] as int,
      data: (json['data'] as List<dynamic>)
          .map((item) => fromJsonT(item as Map<String, dynamic>))
          .toList(),
    );
  }
}