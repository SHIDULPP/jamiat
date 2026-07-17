import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jamiat/src/data/apis/user_api.dart';
import 'package:jamiat/src/data/models/api_response.dart';
import 'package:jamiat/src/data/models/user_model.dart';
import 'package:jamiat/src/data/services/secure_storage_service.dart';
import 'package:jamiat/src/data/utils/auth_navigation.dart';

class AuthSessionService {
  AuthSessionService({
    required SecureStorageService storage,
    required UserApi userApi,
  }) : _storage = storage,
       _userApi = userApi;

  final SecureStorageService _storage;
  final UserApi _userApi;

  Future<String> resolveInitialRoute() async {
    final token = await _storage.getAuthToken();
    final userId = await _storage.getUserId();

    if (token == null || token.isEmpty || userId == null || userId.isEmpty) {
      await _storage.clearSession();
      return 'Login';
    }

    final response = await _userApi.getCurrentStatus();
    if (!response.success) {
      if (response.statusCode == 401 || response.statusCode == 403) {
        await _storage.clearSession();
      }
      return 'Login';
    }

    final data = nestedData(response.data);
    if (data == null) {
      return 'Login';
    }

    final user = UserModel.fromJson(data);
    if (user.status == 'deleted' ||
        user.status == 'suspended' ||
        user.status == 'rejected') {
      await _storage.clearSession();
      return 'Login';
    }

    return routeForUser(user);
  }
}

final authSessionServiceProvider = Provider<AuthSessionService>((ref) {
  return AuthSessionService(
    storage: ref.watch(secureStorageServiceProvider),
    userApi: ref.watch(userApiProvider),
  );
});
