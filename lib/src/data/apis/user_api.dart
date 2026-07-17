import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jamiat/src/data/models/api_response.dart';
import 'package:jamiat/src/data/models/user_model.dart';
import 'package:jamiat/src/data/providers/api_provider.dart';

class UserApi {
  UserApi(this._api);

  final ApiProvider _api;

  Future<ApiResponse<Map<String, dynamic>>> getCurrentStatus() {
    return _api.get('/user/current-status', requireAuth: true);
  }

  Future<ApiResponse<UserModel>> getProfile() async {
    final response = await _api.get('/user/profile', requireAuth: true);
    if (!response.success) {
      return ApiResponse.error(
        response.message ?? 'Failed to load profile',
        response.statusCode,
      );
    }
    final data = nestedData(response.data);
    if (data == null) {
      return ApiResponse.error('Invalid profile response', response.statusCode);
    }
    return ApiResponse.success(
      UserModel.fromJson(data),
      response.statusCode ?? 200,
    );
  }

  Future<ApiResponse<UserModel>> updateProfile(
    Map<String, dynamic> profile,
  ) async {
    final response = await _api.patch(
      '/user/update',
      profile,
      requireAuth: true,
    );
    if (!response.success) {
      return ApiResponse.error(
        response.message ?? 'Failed to update profile',
        response.statusCode,
      );
    }
    final data = nestedData(response.data);
    if (data == null) {
      return ApiResponse.error('Invalid update response', response.statusCode);
    }
    return ApiResponse.success(
      UserModel.fromJson(data),
      response.statusCode ?? 200,
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> updateFcmToken(String fcmToken) {
    return _api.patch('/user/fcm', {'fcm': fcmToken}, requireAuth: true);
  }
}

final userApiProvider = Provider<UserApi>(
  (ref) => UserApi(ref.watch(apiProviderProvider)),
);

final userProfileProvider = FutureProvider<UserModel>((ref) async {
  final response = await ref.watch(userApiProvider).getProfile();
  if (!response.success || response.data == null) {
    throw Exception(response.message ?? 'Failed to load profile');
  }
  return response.data!;
});
