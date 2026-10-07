import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jamiat/src/data/apis/event_api.dart';
import 'package:jamiat/src/data/config/app_config.dart';
import 'package:share_plus/share_plus.dart';

class EventShareResult {
  const EventShareResult({
    required this.success,
    this.shareUrl,
    this.message,
  });

  final bool success;
  final String? shareUrl;
  final String? message;
}

/// Records a share on the API and opens the system share sheet with a link
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
    String? apiMessage;

    try {
      // Record the share server-side; always share the BASE_URL-derived link
      // so UAT/prod never mix (API may return a fixed host).
      final response = await _api.shareEvent(eventId);
      if (response.success) {
        apiMessage = response.message;
      }
    } catch (_) {
      // Still share a locally built link if the API call fails.
    }

    if (!context.mounted) {
      return EventShareResult(success: false, shareUrl: shareUrl);
    }

    final box = context.findRenderObject() as RenderBox?;
    final origin = box != null
        ? box.localToGlobal(Offset.zero) & box.size
        : null;

    final text = 'Join "$title" on Jamiat Connect\n\n$shareUrl';

    await SharePlus.instance.share(
      ShareParams(
        text: text,
        subject: title,
        sharePositionOrigin: origin,
      ),
    );

    return EventShareResult(
      success: true,
      shareUrl: shareUrl,
      message: apiMessage,
    );
  }
}

final eventShareServiceProvider = Provider<EventShareService>(
  (ref) => EventShareService(ref.watch(eventApiProvider)),
);
