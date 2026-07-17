import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  SecureStorageService({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  static const _authTokenKey = 'auth_token';
  static const _userIdKey = 'user_id';
  static const _phoneKey = 'phone';
  static const _fcmTokenKey = 'fcm_token';

  final FlutterSecureStorage _storage;

  Future<void> saveSession({
    required String token,
    required String userId,
    required String phone,
  }) async {
    await Future.wait([
      _storage.write(key: _authTokenKey, value: token),
      _storage.write(key: _userIdKey, value: userId),
      _storage.write(key: _phoneKey, value: phone),
    ]);
  }

  Future<String?> getAuthToken() => _storage.read(key: _authTokenKey);

  Future<String?> getUserId() => _storage.read(key: _userIdKey);

  Future<String?> getPhone() => _storage.read(key: _phoneKey);

  Future<void> saveFcmToken(String token) async {
    await _storage.write(key: _fcmTokenKey, value: token);
  }

  Future<String?> getFcmToken() => _storage.read(key: _fcmTokenKey);

  Future<void> clearSession() async {
    await Future.wait([
      _storage.delete(key: _authTokenKey),
      _storage.delete(key: _userIdKey),
      _storage.delete(key: _phoneKey),
      _storage.delete(key: _fcmTokenKey),
    ]);
  }
}

final secureStorageServiceProvider = Provider<SecureStorageService>(
  (ref) => SecureStorageService(),
);
