import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jamiat/src/data/models/api_response.dart';
import 'package:jamiat/src/data/models/paginated_response.dart';
import 'package:jamiat/src/data/models/product_model.dart';
import 'package:jamiat/src/data/providers/api_provider.dart';

class ProductApi {
  ProductApi(this._api);

  final ApiProvider _api;

  Future<ApiResponse<PaginatedResponse<ProductModel>>> listProducts({
    int pageNo = 1,
    int limit = 50,
    String? search,
  }) async {
    final response = await _api.get(
      '/product/list',
      requireAuth: true,
      queryParams: {
        'page_no': '$pageNo',
        'limit': '$limit',
        if (search != null && search.isNotEmpty) 'search': search,
      },
    );

    if (!response.success) {
      return ApiResponse.error(
        response.message ?? 'Failed to load products',
        response.statusCode,
      );
    }

    final items = nestedListData(
      response.data,
    ).map(ProductModel.fromJson).toList();

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

  Future<ApiResponse<ProductModel>> getProductById(String id) async {
    final response = await _api.get('/product/$id', requireAuth: true);
    if (!response.success) {
      return ApiResponse.error(
        response.message ?? 'Failed to load product',
        response.statusCode,
      );
    }
    final data = nestedData(response.data);
    if (data == null) {
      return ApiResponse.error('Invalid product response', response.statusCode);
    }
    return ApiResponse.success(
      ProductModel.fromJson(data),
      response.statusCode ?? 200,
    );
  }

  Future<ApiResponse<PaginatedResponse<ProductModel>>> getSavedProducts({
    int pageNo = 1,
    int limit = 50,
    String? search,
  }) async {
    final response = await _api.get(
      '/product/saved',
      requireAuth: true,
      queryParams: {
        'page_no': '$pageNo',
        'limit': '$limit',
        if (search != null && search.isNotEmpty) 'search': search,
      },
    );

    if (!response.success) {
      return ApiResponse.error(
        response.message ?? 'Failed to load saved products',
        response.statusCode,
      );
    }

    final items = nestedListData(
      response.data,
    ).map(ProductModel.fromJson).toList();

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

  Future<ApiResponse<bool>> toggleSaveProduct(String productId) async {
    final response = await _api.post(
      '/product/save',
      {'product_id': productId},
      requireAuth: true,
    );
    if (!response.success) {
      return ApiResponse.error(
        response.message ?? 'Failed to update saved product',
        response.statusCode,
      );
    }
    final data = nestedData(response.data);
    final isSaved = data?['is_saved'] == true;
    return ApiResponse.success(
      isSaved,
      response.statusCode ?? 200,
      message: response.message,
    );
  }

  Future<ApiResponse<void>> createEnquiry(String productId) async {
    final response = await _api.post(
      '/product/enquiry',
      {'product_id': productId},
      requireAuth: true,
    );
    if (!response.success) {
      return ApiResponse.error(
        response.message ?? 'Failed to submit enquiry',
        response.statusCode,
      );
    }
    return ApiResponse.success(
      null,
      response.statusCode ?? 200,
      message: response.message,
    );
  }

  Future<ApiResponse<PaginatedResponse<ProductEnquiryModel>>> getMyEnquiries({
    int pageNo = 1,
    int limit = 50,
    String? search,
  }) async {
    final response = await _api.get(
      '/product/my-enquiries',
      requireAuth: true,
      queryParams: {
        'page_no': '$pageNo',
        'limit': '$limit',
        if (search != null && search.isNotEmpty) 'search': search,
      },
    );

    if (!response.success) {
      return ApiResponse.error(
        response.message ?? 'Failed to load enquiries',
        response.statusCode,
      );
    }

    final items = nestedListData(
      response.data,
    ).map(ProductEnquiryModel.fromJson).toList();

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
}

final productApiProvider = Provider<ProductApi>(
  (ref) => ProductApi(ref.watch(apiProviderProvider)),
);
