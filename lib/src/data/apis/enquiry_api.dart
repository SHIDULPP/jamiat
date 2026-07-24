import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jamiat/src/data/models/api_response.dart';
import 'package:jamiat/src/data/models/enquiry_model.dart';
import 'package:jamiat/src/data/models/paginated_response.dart';
import 'package:jamiat/src/data/providers/api_provider.dart';

class EnquiryApi {
  EnquiryApi(this._api);

  final ApiProvider _api;

  /// Received enquiries for the logged-in user (receiver).
  /// `GET /enquiry`
  Future<ApiResponse<PaginatedResponse<EnquiryModel>>> getReceivedEnquiries({
    int pageNo = 1,
    int limit = 50,
    String? search,
  }) async {
    final response = await _api.get(
      '/enquiry',
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
    ).map(EnquiryModel.fromJson).toList();

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

  /// Public create — used from marketplace product enquire.
  /// `POST /enquiry`
  Future<ApiResponse<EnquiryModel>> createEnquiry({
    required String receiverId,
    required String name,
    required String email,
    required String message,
    String? phone,
  }) async {
    final response = await _api.post('/enquiry', {
      'receiver': receiverId,
      'name': name,
      'email': email,
      'message': message,
      if (phone != null && phone.isNotEmpty) 'phone': phone,
    });

    if (!response.success) {
      return ApiResponse.error(
        response.message ?? 'Failed to send enquiry',
        response.statusCode,
      );
    }

    final data = nestedData(response.data);
    if (data == null) {
      return ApiResponse.error(
        'Invalid enquiry response',
        response.statusCode,
      );
    }

    return ApiResponse.success(
      EnquiryModel.fromJson(data),
      response.statusCode ?? 200,
      message: response.message,
    );
  }
}

final enquiryApiProvider = Provider<EnquiryApi>(
  (ref) => EnquiryApi(ref.watch(apiProviderProvider)),
);
