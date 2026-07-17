import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:jamiat/src/data/apis/auth_api.dart';
import 'package:jamiat/src/data/models/api_response.dart';
import 'package:jamiat/src/data/providers/api_provider.dart';
import 'package:jamiat/src/data/services/secure_storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await dotenv.load(fileName: '.env');
  });

  test('AuthApi requestOtp posts phone payload to /auth/login', () async {
    late Uri capturedUri;
    late String? capturedBody;

    final client = MockClient((request) async {
      capturedUri = request.url;
      capturedBody = request.body;
      return http.Response(
        '{"status":200,"message":"OTP sent successfully"}',
        200,
        headers: {'content-type': 'application/json'},
      );
    });

    final api = ApiProvider(
      baseUrl: 'http://127.0.0.1:3005/api/v1',
      apiKey: 'test-key',
      secureStorage: SecureStorageService(),
      client: client,
    );
    final authApi = AuthApi(api);

    final response = await authApi.requestOtp(phone: '+919645398555');

    expect(response.success, isTrue);
    expect(response.message, 'OTP sent successfully');
    expect(capturedUri.toString(), 'http://127.0.0.1:3005/api/v1/auth/login');
    expect(capturedBody, contains('+919645398555'));
  });

  test('AuthApi verifyOtp parses token and user envelope', () async {
    final client = MockClient((request) async {
      return http.Response(
        '''
        {
          "status": 200,
          "message": "OTP verified successfully",
          "data": {
            "token": "jwt-token",
            "user": {
              "_id": "user-1",
              "phone": "+919645398555",
              "status": "inactive",
              "role": "normal_member",
              "is_profile_complete": false
            }
          }
        }
        ''',
        200,
        headers: {'content-type': 'application/json'},
      );
    });

    final api = ApiProvider(
      baseUrl: 'http://127.0.0.1:3005/api/v1',
      apiKey: 'test-key',
      secureStorage: SecureStorageService(),
      client: client,
    );
    final authApi = AuthApi(api);

    final response = await authApi.verifyOtp(
      phone: '+919645398555',
      otp: '123456',
    );
    final data = nestedData(response.data);

    expect(response.success, isTrue);
    expect(data?['token'], 'jwt-token');
    expect(data?['user'], isA<Map>());
  });
}
