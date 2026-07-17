import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jamiat/src/data/models/api_response.dart';
import 'package:jamiat/src/data/models/notification_model.dart';
import 'package:jamiat/src/data/models/paginated_response.dart';
import 'package:jamiat/src/data/providers/api_provider.dart';

class NotificationApi {
  NotificationApi(this._api);

  final ApiProvider _api;

  Future<ApiResponse<PaginatedResponse<NotificationModel>>> getForUser({
    int pageNo = 1,
    int limit = 20,
  }) async {
    final response = await _api.get(
      '/notification/user',
      requireAuth: true,
      queryParams: {'page_no': '$pageNo', 'limit': '$limit'},
    );

    if (!response.success) {
      return ApiResponse.error(
        response.message ?? 'Failed to load notifications',
        response.statusCode,
      );
    }

    final items = nestedListData(
      response.data,
    ).map(NotificationModel.fromJson).toList();

    return ApiResponse.success(
      PaginatedResponse(
        items: items,
        totalCount: nestedTotalCount(response.data),
        pageNo: pageNo,
        limit: limit,
      ),
      response.statusCode ?? 200,
    );
  }

  Future<ApiResponse<void>> markAllAsRead() async {
    final response = await _api.patch(
      '/notification/mark-all-as-read',
      const {},
      requireAuth: true,
    );
    if (!response.success) {
      return ApiResponse.error(
        response.message ?? 'Failed to mark notifications read',
        response.statusCode,
      );
    }
    return ApiResponse.success(null, response.statusCode ?? 200);
  }
}

final notificationApiProvider = Provider<NotificationApi>(
  (ref) => NotificationApi(ref.watch(apiProviderProvider)),
);
