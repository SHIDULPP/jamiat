import 'dart:developer';

import 'package:jamiat/src/data/config/app_config.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

typedef PaymentSuccessHandler = void Function(PaymentSuccessResponse response);
typedef PaymentErrorHandler = void Function(PaymentFailureResponse response);
typedef ExternalWalletHandler = void Function(ExternalWalletResponse response);

/// Thin wrapper around [Razorpay] that keeps callbacks alive across
/// bottom-sheet / route rebuilds (checkout opens a native activity).
class RazorpayService {
  RazorpayService() {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handleSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handleError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    log('Razorpay handlers registered', name: 'RazorpayService');
  }

  late final Razorpay _razorpay;
  PaymentSuccessHandler? _onSuccess;
  PaymentErrorHandler? _onError;
  ExternalWalletHandler? _onExternalWallet;
  bool _disposed = false;

  void setCallbacks({
    required PaymentSuccessHandler onSuccess,
    required PaymentErrorHandler onError,
    ExternalWalletHandler? onExternalWallet,
  }) {
    _onSuccess = onSuccess;
    _onError = onError;
    _onExternalWallet = onExternalWallet;
  }

  /// Opens one-time checkout for a Razorpay order.
  ///
  /// [amount] must be in INR (rupees), same unit the backend stores and
  /// returns from `POST /donation`. Razorpay Checkout expects paise.
  void openCheckout({
    required String keyId,
    required String orderId,
    required num amount,
    required String name,
    required String description,
    String currency = 'INR',
    String? contact,
    String? email,
    String themeColor = '#00A54F',
  }) {
    final key = _resolveKey(keyId);
    final trimmedOrderId = orderId.trim();
    if (trimmedOrderId.isEmpty) {
      throw Exception('Payment order is missing. Please try again.');
    }
    if (amount <= 0) {
      throw Exception('Invalid payment amount.');
    }

    final options = <String, dynamic>{
      'key': key,
      'amount': (amount * 100).round(),
      'currency': currency,
      'name': name,
      'description': description,
      'order_id': trimmedOrderId,
      'theme': {'color': themeColor},
      'prefill': _prefill(contact: contact, email: email),
    };

    _open(options, context: 'checkout');
  }

  /// Opens subscription/mandate checkout for autopay.
  void openSubscriptionCheckout({
    required String keyId,
    required String subscriptionId,
    required String name,
    required String description,
    String? contact,
    String? email,
    String themeColor = '#00A54F',
  }) {
    final key = _resolveKey(keyId);
    final trimmedSubId = subscriptionId.trim();
    if (trimmedSubId.isEmpty) {
      throw Exception('Subscription is missing. Please try again.');
    }

    final options = <String, dynamic>{
      'key': key,
      'subscription_id': trimmedSubId,
      'name': name,
      'description': description,
      'theme': {'color': themeColor},
      'prefill': _prefill(contact: contact, email: email),
    };

    _open(options, context: 'subscription');
  }

  String _resolveKey(String keyId) {
    final fromApi = keyId.trim();
    if (fromApi.isNotEmpty) return fromApi;
    final fromEnv = AppConfig.razorpayKeyId;
    if (fromEnv.isNotEmpty) return fromEnv;
    throw Exception(
      'Razorpay is not configured. Missing razorpay_key_id from server '
      'and RAZORPAY_KEY_ID in .env.',
    );
  }

  Map<String, String> _prefill({String? contact, String? email}) {
    final map = <String, String>{};
    final phone = contact?.trim();
    final mail = email?.trim();
    if (phone != null && phone.isNotEmpty) map['contact'] = phone;
    if (mail != null && mail.isNotEmpty) map['email'] = mail;
    return map;
  }

  void _open(Map<String, dynamic> options, {required String context}) {
    if (_disposed) {
      throw Exception('Payment service was closed. Please try again.');
    }
    try {
      log(
        'Opening Razorpay $context: '
        'key=${_maskKey(options['key']?.toString())}, '
        'order=${options['order_id']}, '
        'subscription=${options['subscription_id']}, '
        'amount=${options['amount']}',
        name: 'RazorpayService',
      );
      _razorpay.open(options);
    } catch (e, st) {
      log('Failed to open Razorpay: $e', name: 'RazorpayService', stackTrace: st);
      rethrow;
    }
  }

  String _maskKey(String? key) {
    if (key == null || key.length < 8) return '***';
    return '${key.substring(0, 8)}…';
  }

  void _handleSuccess(PaymentSuccessResponse response) {
    log(
      'Payment success: paymentId=${response.paymentId}, '
      'orderId=${response.orderId}',
      name: 'RazorpayService',
    );
    if (_disposed) return;
    final cb = _onSuccess;
    if (cb == null) {
      log('WARNING: onSuccess callback is null', name: 'RazorpayService');
      return;
    }
    cb(response);
  }

  void _handleError(PaymentFailureResponse response) {
    log(
      'Payment error: code=${response.code}, message=${response.message}',
      name: 'RazorpayService',
    );
    if (_disposed) return;
    final cb = _onError;
    if (cb == null) {
      log('WARNING: onError callback is null', name: 'RazorpayService');
      return;
    }
    cb(response);
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    log('External wallet: ${response.walletName}', name: 'RazorpayService');
    if (_disposed) return;
    _onExternalWallet?.call(response);
  }

  /// Clears listeners. Prefer keeping the singleton alive for the app session.
  void dispose() {
    if (_disposed) return;
    _disposed = true;
    _onSuccess = null;
    _onError = null;
    _onExternalWallet = null;
    _razorpay.clear();
    log('Razorpay disposed', name: 'RazorpayService');
  }
}
