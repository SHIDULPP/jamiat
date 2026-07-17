import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jamiat/src/data/models/api_response.dart';
import 'package:jamiat/src/data/models/campaign_model.dart';
import 'package:jamiat/src/data/models/paginated_response.dart';
import 'package:jamiat/src/data/providers/api_provider.dart';
import 'package:jamiat/src/data/utils/category_mapper.dart';

class CampaignApi {
  CampaignApi(this._api);

  final ApiProvider _api;

  Future<ApiResponse<PaginatedResponse<CampaignModel>>> listCampaigns({
    int pageNo = 1,
    int limit = 10,
    String? search,
    String? category,
  }) async {
    final response = await _api.get(
      '/campaign/list',
      queryParams: {
        'page_no': '$pageNo',
        'limit': '$limit',
        if (search != null && search.isNotEmpty) 'search': search,
        if (category != null && category.isNotEmpty)
          'category': CategoryMapper.toApi(category),
      },
    );

    if (!response.success) {
      return ApiResponse.error(
        response.message ?? 'Failed to load campaigns',
        response.statusCode,
      );
    }

    final items = nestedListData(
      response.data,
    ).map(CampaignModel.fromJson).toList();

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

  Future<ApiResponse<CampaignMobileStats>> getMobileStats() async {
    final response = await _api.get('/campaign/mobile-stats');
    if (!response.success) {
      return ApiResponse.error(
        response.message ?? 'Failed to load stats',
        response.statusCode,
      );
    }
    final data = nestedData(response.data);
    if (data == null) {
      return ApiResponse.error('Invalid stats response', response.statusCode);
    }
    return ApiResponse.success(
      CampaignMobileStats.fromJson(data),
      response.statusCode ?? 200,
    );
  }

  Future<ApiResponse<CampaignModel>> getCampaignById(String id) async {
    final response = await _api.get('/campaign/$id', requireAuth: true);
    if (!response.success) {
      return ApiResponse.error(
        response.message ?? 'Failed to load campaign',
        response.statusCode,
      );
    }
    final data = nestedData(response.data);
    if (data == null) {
      return ApiResponse.error(
        'Invalid campaign response',
        response.statusCode,
      );
    }
    return ApiResponse.success(
      CampaignModel.fromJson(data),
      response.statusCode ?? 200,
    );
  }

  Future<ApiResponse<PaginatedResponse<CampaignModel>>> getSavedCampaigns({
    int pageNo = 1,
    int limit = 10,
  }) async {
    final response = await _api.get(
      '/campaign/saved',
      requireAuth: true,
      queryParams: {'page_no': '$pageNo', 'limit': '$limit'},
    );
    if (!response.success) {
      return ApiResponse.error(
        response.message ?? 'Failed to load saved campaigns',
        response.statusCode,
      );
    }
    final items = nestedListData(
      response.data,
    ).map(CampaignModel.fromJson).toList();
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

  Future<ApiResponse<void>> bookmarkCampaign(String campaignId) async {
    final response = await _api.post('/campaign/bookmark', {
      'campaign_id': campaignId,
    }, requireAuth: true);
    if (!response.success) {
      return ApiResponse.error(
        response.message ?? 'Failed to bookmark',
        response.statusCode,
      );
    }
    return ApiResponse.success(null, response.statusCode ?? 200);
  }

  Future<ApiResponse<void>> removeBookmark(String campaignId) async {
    final response = await _api.delete(
      '/campaign/bookmark/$campaignId',
      requireAuth: true,
    );
    if (!response.success) {
      return ApiResponse.error(
        response.message ?? 'Failed to remove bookmark',
        response.statusCode,
      );
    }
    return ApiResponse.success(null, response.statusCode ?? 200);
  }

  Future<ApiResponse<void>> shareCampaign(String campaignId) async {
    final response = await _api.post(
      '/campaign/share/$campaignId',
      const {},
      requireAuth: true,
    );
    if (!response.success) {
      return ApiResponse.error(
        response.message ?? 'Failed to share',
        response.statusCode,
      );
    }
    return ApiResponse.success(null, response.statusCode ?? 200);
  }
}

final campaignApiProvider = Provider<CampaignApi>(
  (ref) => CampaignApi(ref.watch(apiProviderProvider)),
);
