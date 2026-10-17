import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jamiat/src/data/apis/event_api.dart';
import 'package:jamiat/src/data/config/app_config.dart';
import 'package:share_plus/share_plus.dart';

class EventShareResult {
  const EventShareResult({required this.success, this.shareUrl, this.message});

  final bool success;
  final String? shareUrl;
  final String? message;
}

/// Opens the system share sheet and records the share independently with a link
/// that opens Event Details in-app (or the store) via the backend landing page.
class EventShareService {
  EventShareService(this._api);

  final EventApi _api;

  Future<EventShareResult> shareEvent({
    required BuildContext context,
    required String eventId,
    required String title,
  }) async {
    final shareUrl = AppConfig.eventShareUrl(eventId);

    if (!context.mounted) {
      return EventShareResult(success: false, shareUrl: shareUrl);
    }

    final box = context.findRenderObject() as RenderBox?;
    final origin = box != null
        ? box.localToGlobal(Offset.zero) & box.size
        : null;

    final text = 'Join "$title" on Jamiat Connect\n\n$shareUrl';

    final shareFuture = SharePlus.instance.share(
      ShareParams(text: text, subject: title, sharePositionOrigin: origin),
    );
    unawaited(_recordShare(eventId));
    await shareFuture;

    return EventShareResult(success: true, shareUrl: shareUrl);
  }

  Future<void> _recordShare(String eventId) async {
    try {
      // Tracking must never delay or prevent the native share sheet.
      await _api.shareEvent(eventId);
    } catch (_) {
      // Sharing remains available when tracking is offline or fails.
    }
  }
}

final eventShareServiceProvider = Provider<EventShareService>(
  (ref) => EventShareService(ref.watch(eventApiProvider)),
);
