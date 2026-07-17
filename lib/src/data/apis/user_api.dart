import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jamiat/src/data/models/api_response.dart';
import 'package:jamiat/src/data/providers/api_provider.dart';

class UserApi {
  UserApi(this._api);

  final ApiProvider _api;

  Future<ApiResponse<Map<String, dynamic>>> getCurrentStatus() {
    return _api.get('/user/current-status', requireAuth: true);
  }

  Future<ApiResponse<Map<String, dynamic>>> updateProfile(
    Map<String, dynamic> profile,
  ) {
    return _api.patch('/user/update', profile, requireAuth: true);
  }

  Future<ApiResponse<Map<String, dynamic>>> updateFcmToken(String fcmToken) {
    return _api.patch('/user/fcm', {'fcm': fcmToken}, requireAuth: true);
  }
}

final userApiProvider = Provider<UserApi>(
  (ref) => UserApi(ref.watch(apiProviderProvider)),
);
