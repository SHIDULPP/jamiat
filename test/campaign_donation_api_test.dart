import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:jamiat/src/data/apis/campaign_api.dart';
import 'package:jamiat/src/data/apis/donation_api.dart';
import 'package:jamiat/src/data/models/campaign_model.dart';
import 'package:jamiat/src/data/models/donation_model.dart';
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

  group('CampaignModel', () {
    test('fromJson maps nested ids and bookmark flag', () {
      final model = CampaignModel.fromJson({
        '_id': 'camp-1',
        'title': 'Zakat Drive',
        'description': 'Support community',
        'category': 'Zakat',
        'collected_amount': 1500,
        'target_amount': 10000,
        'progress_percent': 15,
        'is_bookmarked': true,
        'cover_image': 'https://example.com/c.jpg',
        'remaining_days': 12,
      });

      expect(model.id, 'camp-1');
      expect(model.title, 'Zakat Drive');
      expect(model.collectedAmount, 1500);
      expect(model.isBookmarked, isTrue);
      expect(model.remainingDays, 12);
    });
  });

  group('DonationCreateResult', () {
    test('fromJson reads nested donation and razorpay fields', () {
      final result = DonationCreateResult.fromJson({
        'donation': {'_id': 'don-9', 'amount': 500},
        'razorpay_order_id': 'order_abc',
        'razorpay_key_id': 'rzp_test_key',
        'amount': 500,
        'currency': 'INR',
      });

      expect(result.donationId, 'don-9');
      expect(result.razorpayOrderId, 'order_abc');
      expect(result.razorpayKeyId, 'rzp_test_key');
      expect(result.amount, 500);
    });
  });

  group('CampaignApi', () {
    test('listCampaigns parses paginated envelope', () async {
      final client = MockClient((request) async {
        expect(request.url.path, endsWith('/campaign/list'));
        expect(request.url.queryParameters['page_no'], '1');
        return http.Response(
          '''
          {
            "status": 200,
            "message": "ok",
            "data": [
              {
                "_id": "c1",
                "title": "Orphan Care",
                "description": "Help orphans",
                "category": "Orphan",
                "collected_amount": 200,
                "target_amount": 5000,
                "progress_percent": 4,
                "is_bookmarked": false
              }
            ],
            "total_count": 1
          }
          ''',
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final api = CampaignApi(
        ApiProvider(
          baseUrl: 'http://127.0.0.1:3005/api/v1',
          apiKey: 'test-key',
          secureStorage: SecureStorageService(),
          client: client,
        ),
      );

      final response = await api.listCampaigns(pageNo: 1, limit: 10);
      expect(response.success, isTrue);
      expect(response.data!.items, hasLength(1));
      expect(response.data!.items.first.title, 'Orphan Care');
      expect(response.data!.totalCount, 1);
    });
  });

  group('DonationApi', () {
    test('createDonation posts campaign/amount payload', () async {
      late String? capturedBody;
      late bool hasAuthHeader;

      final client = MockClient((request) async {
        capturedBody = request.body;
        hasAuthHeader = request.headers.containsKey('Authorization');
        expect(request.url.path, endsWith('/donation'));
        expect(request.method, 'POST');
        return http.Response(
          '''
          {
            "status": 200,
            "message": "created",
            "data": {
              "donation": {"_id": "d1", "amount": 250},
              "razorpay_order_id": "order_1",
              "razorpay_key_id": "rzp_test",
              "amount": 250,
              "currency": "INR"
            }
          }
          ''',
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final api = DonationApi(
        ApiProvider(
          baseUrl: 'http://127.0.0.1:3005/api/v1',
          apiKey: 'test-key',
          secureStorage: _TestSecureStorage(),
          client: client,
        ),
      );

      final response = await api.createDonation(
        campaignId: 'camp-42',
        amount: 250,
        message: 'For education',
      );

      expect(response.success, isTrue);
      expect(hasAuthHeader, isTrue);
      expect(response.data!.donationId, 'd1');
      expect(response.data!.razorpayOrderId, 'order_1');
      expect(capturedBody, contains('camp-42'));
      expect(capturedBody, contains('250'));
      expect(capturedBody, contains('For education'));
    });

    test('verifyPayment posts required razorpay fields', () async {
      late String? capturedBody;

      final client = MockClient((request) async {
        capturedBody = request.body;
        expect(request.url.path, endsWith('/donation/verify-payment'));
        return http.Response(
          '''
          {
            "status": 200,
            "message": "verified",
            "data": {
              "_id": "d1",
              "amount": 250,
              "status": "success",
              "campaign": {"_id": "camp-42", "title": "Education"}
            }
          }
          ''',
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final api = DonationApi(
        ApiProvider(
          baseUrl: 'http://127.0.0.1:3005/api/v1',
          apiKey: 'test-key',
          secureStorage: _TestSecureStorage(),
          client: client,
        ),
      );

      final response = await api.verifyPayment(
        donationId: 'd1',
        razorpayOrderId: 'order_1',
        razorpayPaymentId: 'pay_1',
        razorpaySignature: 'sig_1',
      );

      expect(response.success, isTrue);
      expect(response.data!.status, 'success');
      expect(capturedBody, contains('donation_id'));
      expect(capturedBody, contains('razorpay_order_id'));
      expect(capturedBody, contains('razorpay_payment_id'));
      expect(capturedBody, contains('razorpay_signature'));
    });
  });
}
