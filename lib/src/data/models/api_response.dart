class ApiResponse<T> {
  const ApiResponse({
    required this.success,
    this.data,
    this.statusCode,
    this.message,
  });

  final bool success;
  final T? data;
  final int? statusCode;
  final String? message;

  factory ApiResponse.success(T? data, int statusCode, {String? message}) {
    return ApiResponse(
      success: true,
      data: data,
      statusCode: statusCode,
      message: message,
    );
  }

  factory ApiResponse.error(String message, [int? statusCode, T? data]) {
    return ApiResponse(
      success: false,
      statusCode: statusCode,
      message: message,
      data: data,
    );
  }
}

Map<String, dynamic>? nestedData(Map<String, dynamic>? body) {
  final data = body?['data'];
  if (data is Map<String, dynamic>) {
    return data;
  }
  return null;
}

List<Map<String, dynamic>> nestedListData(Map<String, dynamic>? body) {
  final data = body?['data'];
  if (data is List) {
    return data
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }
  if (data is Map<String, dynamic>) {
    for (final value in data.values) {
      if (value is List) {
        return value
            .whereType<Map>()
            .map((item) => Map<String, dynamic>.from(item))
            .toList();
      }
    }
  }
  return const [];
}

int nestedTotalCount(Map<String, dynamic>? body) {
  final count = body?['total_count'];
  if (count is int) return count;
  if (count is num) return count.toInt();
  return 0;
}
