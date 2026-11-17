class PaginatedResponse<T> {
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;
  final String? nextPageUrl;
  final String? prevPageUrl;
  final List<T> data;

  const PaginatedResponse({
    this.currentPage = 1,
    this.lastPage = 1,
    this.perPage = 15,
    this.total = 0,
    this.nextPageUrl,
    this.prevPageUrl,
    this.data = const [],
  });

  bool get hasMorePages => currentPage < lastPage;

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic item) fromJsonItem,
  ) {
    final rawList = json['data'] as List<dynamic>? ?? [];
    final items = rawList.map((e) => fromJsonItem(e)).toList();

    return PaginatedResponse<T>(
      currentPage: json['current_page'] is int
          ? json['current_page'] as int
          : int.tryParse(json['current_page']?.toString() ?? '1') ?? 1,
      lastPage: json['last_page'] is int
          ? json['last_page'] as int
          : int.tryParse(json['last_page']?.toString() ?? '1') ?? 1,
      perPage: json['per_page'] is int
          ? json['per_page'] as int
          : int.tryParse(json['per_page']?.toString() ?? '15') ?? 15,
      total: json['total'] is int
          ? json['total'] as int
          : int.tryParse(json['total']?.toString() ?? '0') ?? 0,
      nextPageUrl: json['next_page_url']?.toString(),
      prevPageUrl: json['prev_page_url']?.toString(),
      data: items,
    );
  }

  Map<String, dynamic> toJson(dynamic Function(T item) toJsonItem) => {
    'current_page': currentPage,
    'last_page': lastPage,
    'per_page': perPage,
    'total': total,
    'next_page_url': nextPageUrl,
    'prev_page_url': prevPageUrl,
    'data': data.map((e) => toJsonItem(e)).toList(),
  };
}
