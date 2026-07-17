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

  factory ApiResponse.error(String message, [int? statusCode]) {
    return ApiResponse(
      success: false,
      statusCode: statusCode,
      message: message,
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
