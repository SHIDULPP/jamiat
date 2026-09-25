import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jamiat/src/data/services/razorpay_service.dart';

/// Process-wide instance so native checkout can return to Flutter callbacks
/// even if the donation bottom sheet is rebuilt or briefly disposed.
RazorpayService? _razorpayServiceInstance;

final razorpayServiceProvider = Provider<RazorpayService>((ref) {
  final existing = _razorpayServiceInstance;
  if (existing != null) {
    log('Reusing Razorpay service', name: 'razorpayProvider');
    return existing;
  }

  log('Creating Razorpay service', name: 'razorpayProvider');
  final service = RazorpayService();
  _razorpayServiceInstance = service;

  // Keep alive for payment callbacks — do not dispose with the provider.
  ref.onDispose(() {
    log('Razorpay provider disposed (service kept alive)', name: 'razorpayProvider');
  });

  return service;
});
