import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jamiat/src/data/models/api_response.dart';
import 'package:jamiat/src/data/models/empowerment_model.dart';
import 'package:jamiat/src/data/models/paginated_response.dart';
import 'package:jamiat/src/data/providers/api_provider.dart';

class EmpowermentApi {
  EmpowermentApi(this._api);

  final ApiProvider _api;

  Future<ApiResponse<PaginatedResponse<EmpowermentProgramModel>>> getPrograms({
    int pageNo = 1,
    int limit = 10,
    String mode = 'all',
    String? search,
  }) async {
    final response = await _api.get(
      '/empowerment/user/programs',
      requireAuth: true,
      queryParams: {
        'page_no': '$pageNo',
        'limit': '$limit',
        'mode': mode,
        if (search != null && search.isNotEmpty) 'search': search,
      },
    );

    if (!response.success) {
      return ApiResponse.error(
        response.message ?? 'Failed to load programs',
        response.statusCode,
      );
    }

    final items = nestedListData(
      response.data,
    ).map(EmpowermentProgramModel.fromJson).toList();

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

  Future<ApiResponse<EmpowermentProgramModel>> getProgramById(String id) async {
    final response = await _api.get(
      '/empowerment/user/programs/$id',
      requireAuth: true,
    );
    if (!response.success) {
      return ApiResponse.error(
        response.message ?? 'Failed to load program',
        response.statusCode,
      );
    }
    final data = nestedData(response.data);
    if (data == null) {
      return ApiResponse.error('Invalid program response', response.statusCode);
    }
    return ApiResponse.success(
      EmpowermentProgramModel.fromJson(data),
      response.statusCode ?? 200,
    );
  }

  Future<ApiResponse<void>> saveProgram(String id) async {
    final response = await _api.post(
      '/empowerment/user/programs/$id/save',
      const {},
      requireAuth: true,
    );
    if (!response.success) {
      return ApiResponse.error(
        response.message ?? 'Failed to save program',
        response.statusCode,
      );
    }
    return ApiResponse.success(null, response.statusCode ?? 200);
  }

  Future<ApiResponse<void>> unsaveProgram(String id) async {
    final response = await _api.delete(
      '/empowerment/user/programs/$id/save',
      requireAuth: true,
    );
    if (!response.success) {
      return ApiResponse.error(
        response.message ?? 'Failed to unsave program',
        response.statusCode,
      );
    }
    return ApiResponse.success(null, response.statusCode ?? 200);
  }

  Future<ApiResponse<void>> applyForProgram(String id) async {
    final response = await _api.post(
      '/empowerment/user/programs/$id/apply',
      const {},
      requireAuth: true,
    );
    if (!response.success) {
      return ApiResponse.error(
        response.message ?? 'Failed to apply',
        response.statusCode,
      );
    }
    return ApiResponse.success(null, response.statusCode ?? 200);
  }
}

final empowermentApiProvider = Provider<EmpowermentApi>(
  (ref) => EmpowermentApi(ref.watch(apiProviderProvider)),
);
