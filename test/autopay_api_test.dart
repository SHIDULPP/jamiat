import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:jamiat/src/data/apis/autopay_api.dart';
import 'package:jamiat/src/data/models/autopay_model.dart';
import 'package:jamiat/src/data/providers/api_provider.dart';
import 'package:jamiat/src/data/services/secure_storage_service.dart';

class _TestSecureStorage extends SecureStorageService {
  @override
  Future<String?> getAuthToken() async => 'test-jwt';
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await dotenv.load(fileName: '.env');
  });

  test('AutopayCreateResult.fromJson parses nested autopay', () {
    final result = AutopayCreateResult.fromJson({
      'autopay': {'_id': 'ap-1', 'amount': 500, 'period': 'monthly'},
      'razorpay_subscription_id': 'sub_123',
      'razorpay_key_id': 'rzp_test',
    });

    expect(result.autopayId, 'ap-1');
    expect(result.razorpaySubscriptionId, 'sub_123');
    expect(result.razorpayKeyId, 'rzp_test');
  });

  test('AutopayApi.verifyAutopay posts full validation body', () async {
    late String? capturedBody;
    late bool hasAuthHeader;

    final client = MockClient((request) async {
      capturedBody = request.body;
      hasAuthHeader = request.headers.containsKey('Authorization');
      expect(request.url.path, endsWith('/autopay/verify'));
      return http.Response(
        '''
        {
          "status": 200,
          "message": "verified",
          "data": {
            "_id": "ap-1",
            "amount": 500,
            "period": "monthly",
            "status": "active",
            "campaign": {"_id": "c1", "title": "Zakat"}
          }
        }
        ''',
        200,
        headers: {'content-type': 'application/json'},
      );
    });

    final api = AutopayApi(
      ApiProvider(
        baseUrl: 'http://127.0.0.1:3005/api/v1',
        apiKey: 'test-key',
        secureStorage: _TestSecureStorage(),
        client: client,
      ),
    );

    final response = await api.verifyAutopay(
      autopayId: 'ap-1',
      razorpaySubscriptionId: 'sub_123',
      razorpayPaymentId: 'pay_9',
      razorpaySignature: 'sig_9',
    );

    expect(response.success, isTrue);
    expect(hasAuthHeader, isTrue);
    expect(response.data!.status, 'active');
    expect(capturedBody, contains('autopay_id'));
    expect(capturedBody, contains('razorpay_subscription_id'));
    expect(capturedBody, contains('razorpay_payment_id'));
    expect(capturedBody, contains('razorpay_signature'));
  });
}
