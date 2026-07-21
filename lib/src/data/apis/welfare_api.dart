import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jamiat/src/data/models/api_response.dart';
import 'package:jamiat/src/data/models/paginated_response.dart';
import 'package:jamiat/src/data/models/welfare_model.dart';
import 'package:jamiat/src/data/providers/api_provider.dart';

class WelfareApi {
  WelfareApi(this._api);

  final ApiProvider _api;

  Future<ApiResponse<PaginatedResponse<WelfareServiceModel>>> listServices({
    int pageNo = 1,
    int limit = 50,
    String? search,
  }) async {
    final response = await _api.get(
      '/welfare/list',
      requireAuth: true,
      queryParams: {
        'page_no': '$pageNo',
        'limit': '$limit',
        if (search != null && search.isNotEmpty) 'search': search,
      },
    );

    if (!response.success) {
      return ApiResponse.error(
        response.message ?? 'Failed to load welfare services',
        response.statusCode,
      );
    }

    final items = nestedListData(
      response.data,
    ).map(WelfareServiceModel.fromJson).toList();

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

  Future<ApiResponse<WelfareServiceModel>> getServiceById(
    String id, {
    int campaignPageNo = 1,
    int campaignLimit = 20,
  }) async {
    final response = await _api.get(
      '/welfare/$id',
      requireAuth: true,
      queryParams: {
        'campaign_page_no': '$campaignPageNo',
        'campaign_limit': '$campaignLimit',
        'campaign_status': 'active',
      },
    );

    if (!response.success) {
      return ApiResponse.error(
        response.message ?? 'Failed to load welfare service',
        response.statusCode,
      );
    }

    final data = nestedData(response.data);
    if (data == null) {
      return ApiResponse.error(
        'Invalid welfare service response',
        response.statusCode,
      );
    }

    return ApiResponse.success(
      WelfareServiceModel.fromJson(data),
      response.statusCode ?? 200,
    );
  }
}

final welfareApiProvider = Provider<WelfareApi>(
  (ref) => WelfareApi(ref.watch(apiProviderProvider)),
);
