import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jamiat/src/data/apis/campaign_api.dart';
import 'package:jamiat/src/data/config/app_config.dart';
import 'package:share_plus/share_plus.dart';

class CampaignShareResult {
  const CampaignShareResult({
    required this.success,
    this.shareUrl,
    this.message,
  });

  final bool success;
  final String? shareUrl;
  final String? message;
}

/// Records a share on the API and opens the system share sheet with a link
/// that opens the app (or store) via the backend landing page.
class CampaignShareService {
  CampaignShareService(this._api);

  final CampaignApi _api;

  Future<CampaignShareResult> shareCampaign({
    required BuildContext context,
    required String campaignId,
    required String title,
  }) async {
    String shareUrl = AppConfig.campaignShareUrl(campaignId);
    String? apiMessage;

    try {
      // Record the share server-side; always share the BASE_URL-derived link
      // so UAT/prod never mix (API may return a fixed host).
      final response = await _api.shareCampaign(campaignId);
      if (response.success) {
        apiMessage = response.message;
      }
    } catch (_) {
      // Still share a locally built link if the API call fails.
    }

    if (!context.mounted) {
      return CampaignShareResult(success: false, shareUrl: shareUrl);
    }

    final box = context.findRenderObject() as RenderBox?;
    final origin = box != null
        ? box.localToGlobal(Offset.zero) & box.size
        : null;

    final text =
        'Support "$title" on Jamiat Connect\n\n$shareUrl';

    await SharePlus.instance.share(
      ShareParams(
        text: text,
        subject: title,
        sharePositionOrigin: origin,
      ),
    );

    return CampaignShareResult(
      success: true,
      shareUrl: shareUrl,
      message: apiMessage,
    );
  }
}

final campaignShareServiceProvider = Provider<CampaignShareService>(
  (ref) => CampaignShareService(ref.watch(campaignApiProvider)),
);
