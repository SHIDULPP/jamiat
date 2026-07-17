class PaginatedResponse<T> {
  const PaginatedResponse({
    required this.items,
    required this.totalCount,
    required this.pageNo,
    required this.limit,
  });

  final List<T> items;
  final int totalCount;
  final int pageNo;
  final int limit;

  bool get hasMore => pageNo * limit < totalCount;
}
