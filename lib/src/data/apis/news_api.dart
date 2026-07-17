import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jamiat/src/data/models/api_response.dart';
import 'package:jamiat/src/data/models/news_model.dart';
import 'package:jamiat/src/data/models/paginated_response.dart';
import 'package:jamiat/src/data/providers/api_provider.dart';

class NewsApi {
  NewsApi(this._api);

  final ApiProvider _api;

  Future<ApiResponse<PaginatedResponse<NewsModel>>> getNewsForUser({
    int pageNo = 1,
    int limit = 10,
    String? search,
  }) async {
    final response = await _api.get(
      '/news/user',
      requireAuth: true,
      queryParams: {
        'page_no': '$pageNo',
        'limit': '$limit',
        if (search != null && search.isNotEmpty) 'search': search,
      },
    );

    if (!response.success) {
      return ApiResponse.error(
        response.message ?? 'Failed to load news',
        response.statusCode,
      );
    }

    final items = nestedListData(
      response.data,
    ).map(NewsModel.fromJson).toList();

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

  Future<ApiResponse<NewsModel>> getNewsById(String id) async {
    final response = await _api.get('/news/user/$id', requireAuth: true);
    if (!response.success) {
      return ApiResponse.error(
        response.message ?? 'Failed to load article',
        response.statusCode,
      );
    }
    final data = nestedData(response.data);
    if (data == null) {
      return ApiResponse.error('Invalid news response', response.statusCode);
    }
    return ApiResponse.success(
      NewsModel.fromJson(data),
      response.statusCode ?? 200,
    );
  }
}

final newsApiProvider = Provider<NewsApi>(
  (ref) => NewsApi(ref.watch(apiProviderProvider)),
);
