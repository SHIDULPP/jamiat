import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jamiat/src/data/apis/product_api.dart';
import 'package:jamiat/src/data/config/app_config.dart';
import 'package:share_plus/share_plus.dart';

class ProductShareResult {
  const ProductShareResult({
    required this.success,
    this.shareUrl,
    this.message,
  });

  final bool success;
  final String? shareUrl;
  final String? message;
}

/// Opens the system share sheet and records the share independently with a link
/// that opens Product Details in-app (or the store) via the backend landing page.
class ProductShareService {
  ProductShareService(this._api);

  final ProductApi _api;

  Future<ProductShareResult> shareProduct({
    required BuildContext context,
    required String productId,
    required String title,
  }) async {
    final shareUrl = AppConfig.productShareUrl(productId);

    if (!context.mounted) {
      return ProductShareResult(success: false, shareUrl: shareUrl);
    }

    final box = context.findRenderObject() as RenderBox?;
    final origin = box != null
        ? box.localToGlobal(Offset.zero) & box.size
        : null;

    final text = 'View "$title" on Jamiat Connect\n\n$shareUrl';

    final shareFuture = SharePlus.instance.share(
      ShareParams(text: text, subject: title, sharePositionOrigin: origin),
    );
    unawaited(_recordShare(productId));
    await shareFuture;

    return ProductShareResult(success: true, shareUrl: shareUrl);
  }

  Future<void> _recordShare(String productId) async {
    try {
      // Tracking must never delay or prproduct the native share sheet.
      await _api.shareProduct(productId);
    } catch (_) {
      // Sharing remains available when tracking is offline or fails.
    }
  }
}

final productShareServiceProvider = Provider<ProductShareService>(
  (ref) => ProductShareService(ref.watch(productApiProvider)),
);
