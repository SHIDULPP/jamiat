import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jamiat/src/data/models/api_response.dart';
import 'package:jamiat/src/data/providers/api_provider.dart';

class AuthApi {
  AuthApi(this._api);

  final ApiProvider _api;

  Future<ApiResponse<Map<String, dynamic>>> requestOtp({
    required String phone,
    String? fcm,
  }) {
    return _api.post('/auth/login', {
      'phone': phone,
      if (fcm != null && fcm.isNotEmpty) 'fcm': fcm,
    });
  }

  Future<ApiResponse<Map<String, dynamic>>> verifyOtp({
    required String phone,
    required String otp,
  }) {
    return _api.post('/auth/verify', {'phone': phone, 'otp': otp});
  }

  Future<ApiResponse<Map<String, dynamic>>> logout() {
    return _api.post('/auth/logout', const {}, requireAuth: true);
  }
}

final authApiProvider = Provider<AuthApi>(
  (ref) => AuthApi(ref.watch(apiProviderProvider)),
);
