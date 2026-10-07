import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jamiat/src/data/apis/user_api.dart';
import 'package:jamiat/src/data/services/secure_storage_service.dart';
import 'package:url_launcher/url_launcher.dart';

class ExternalDonationService {
  static const String externalDonateUrl =
      'https://jamiatconnect.juhkerala.com/#donate';
  static const String targetPhoneNumber = '9645398555';

  static bool isTargetPhone(String? phone) {
    if (phone == null || phone.trim().isEmpty) return false;
    final digits = phone.replaceAll(RegExp(r'[^0-9]'), '');
    return digits.endsWith(targetPhoneNumber);
  }

  static Future<bool> shouldRedirectExternal({
    WidgetRef? ref,
    String? phone,
  }) async {
    if (isTargetPhone(phone)) return true;

    if (ref != null) {
      final userPhone = ref.read(userProfileProvider).asData?.value.phone;
      if (isTargetPhone(userPhone)) return true;

      try {
        final storedPhone =
            await ref.read(secureStorageServiceProvider).getPhone();
        if (isTargetPhone(storedPhone)) return true;
      } catch (_) {}
    }

    return false;
  }

  static Future<bool> openExternalDonationUrl() async {
    final uri = Uri.parse(externalDonateUrl);
    try {
      return await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    } catch (_) {
      return false;
    }
  }

  /// Checks if the current user matches the test phone number, and if so,
  /// opens the external donation webpage and returns true.
  /// Otherwise returns false.
  static Future<bool> handleDonationClick({
    required WidgetRef ref,
    String? phone,
  }) async {
    final shouldRedirect = await shouldRedirectExternal(ref: ref, phone: phone);
    if (shouldRedirect) {
      await openExternalDonationUrl();
      return true;
    }
    return false;
  }

  /// Returns the button label based on whether the user is the review test user.
  static String getDonationButtonLabel({
    required WidgetRef ref,
    bool isAutopay = false,
  }) {
    final userPhone = ref.watch(userProfileProvider).value?.phone;
    if (isTargetPhone(userPhone)) {
      return 'Donate through website';
    }
    return isAutopay ? 'Set up Autopay' : 'Donate Now';
  }
}
