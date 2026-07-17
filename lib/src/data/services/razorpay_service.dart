import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

typedef PaymentSuccessHandler = void Function(PaymentSuccessResponse response);
typedef PaymentErrorHandler = void Function(PaymentFailureResponse response);

class RazorpayService {
  RazorpayService() : _razorpay = Razorpay();

  final Razorpay _razorpay;
  PaymentSuccessHandler? _onSuccess;
  PaymentErrorHandler? _onError;
  bool _disposed = false;

  void init({
    required PaymentSuccessHandler onSuccess,
    required PaymentErrorHandler onError,
  }) {
    _onSuccess = onSuccess;
    _onError = onError;
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handleSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handleError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  void openCheckout({
    required String keyId,
    required String orderId,
    required num amount,
    required String name,
    required String description,
    String currency = 'INR',
    String? contact,
    String? email,
  }) {
    final options = <String, dynamic>{
      'key': keyId,
      'amount': (amount * 100).round(),
      'name': name,
      'description': description,
      'order_id': orderId,
      'currency': currency,
      'prefill': {
        'contact': ?contact,
        'email': ?email,
      },
    };
    _razorpay.open(options);
  }

  void openSubscriptionCheckout({
    required String keyId,
    required String subscriptionId,
    required String name,
    required String description,
    String? contact,
    String? email,
  }) {
    final options = <String, dynamic>{
      'key': keyId,
      'subscription_id': subscriptionId,
      'name': name,
      'description': description,
      'prefill': {
        'contact': ?contact,
        'email': ?email,
      },
    };
    _razorpay.open(options);
  }

  void _handleSuccess(PaymentSuccessResponse response) {
    if (_disposed) return;
    _onSuccess?.call(response);
  }

  void _handleError(PaymentFailureResponse response) {
    if (_disposed) return;
    _onError?.call(response);
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    debugPrint('External wallet: ${response.walletName}');
  }

  void dispose() {
    _disposed = true;
    _onSuccess = null;
    _onError = null;
    _razorpay.clear();
  }
}
