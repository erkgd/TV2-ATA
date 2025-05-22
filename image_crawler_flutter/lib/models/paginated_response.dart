class PaginatedResponse<T> {
  final List<T> items;
  final Pagination pagination;

  PaginatedResponse({
    required this.items,
    required this.pagination,
  });

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    final itemsJson = json['items'] as List<dynamic>;
    return PaginatedResponse(
      items: itemsJson.map((item) => fromJsonT(item)).toList(),
      pagination: Pagination.fromJson(json['pagination'] ?? {}),
    );
  }

  Map<String, dynamic> toJson(Map<String, dynamic> Function(T) toJsonT) {
    return {
      'items': items.map((item) => toJsonT(item)).toList(),
      'pagination': pagination.toJson(),
    };
  }
}

class Pagination {
  final int total;
  final int page;
  final int pages;

  Pagination({
    required this.total,
    required this.page,
    required this.pages,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      total: json['total'] ?? 0,
      page: json['page'] ?? 1,
      pages: json['pages'] ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total': total,
      'page': page,
      'pages': pages,
    };
  }
}
