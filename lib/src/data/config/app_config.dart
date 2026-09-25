import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  AppConfig._();

  /// Dev:  https://uat-admin.juhkerala.com/api/v1/
  /// Prod: https://api.jamiatconnect.juhkerala.com/api/v1/
  static String get baseUrl => dotenv.env['BASE_URL']?.trim() ?? '';
  static String get apiKey => dotenv.env['API_KEY']?.trim() ?? '';

  static String get normalizedBaseUrl {
    final value = baseUrl;
    if (value.endsWith('/')) {
      return value.substring(0, value.length - 1);
    }
    return value;
  }

  /// Origin only, e.g. `https://uat-admin.juhkerala.com`
  static String get apiOrigin {
    final uri = Uri.tryParse(normalizedBaseUrl);
    if (uri == null || !uri.hasScheme || uri.host.isEmpty) return '';
    return '${uri.scheme}://${uri.host}';
  }

  static String get apiHost {
    final uri = Uri.tryParse(normalizedBaseUrl);
    return uri?.host ?? '';
  }

  static bool get isProductionApi =>
      apiHost == 'api.jamiatconnect.juhkerala.com';

  static bool get isDevelopmentApi =>
      apiHost == 'uat-admin.juhkerala.com';

  static String get androidPackageId =>
      dotenv.env['ANDROID_PACKAGE_ID']?.trim().isNotEmpty == true
      ? dotenv.env['ANDROID_PACKAGE_ID']!.trim()
      : 'com.jamiatconnect';

  static String get iosAppStoreId =>
      dotenv.env['IOS_APP_STORE_ID']?.trim() ?? '';

  static String get appDeepLinkScheme =>
      dotenv.env['APP_DEEP_LINK_SCHEME']?.trim().isNotEmpty == true
      ? dotenv.env['APP_DEEP_LINK_SCHEME']!.trim()
      : 'jamiatconnect';

  /// Always derived from [BASE_URL] (dev or prod) — never hardcodes a host.
  /// Dev:  `…/api/v1/share/campaign/{id}` on uat-admin
  /// Prod: `…/api/v1/share/campaign/{id}` on api.jamiatconnect
  static String campaignShareUrl(String campaignId) {
    return '$normalizedBaseUrl/share/campaign/$campaignId';
  }

  /// Always derived from [BASE_URL] (dev or prod) — never hardcodes a host.
  /// Dev:  `https://uat-admin.juhkerala.com/api/v1/share/donate`
  /// Prod: `https://api.jamiatconnect.juhkerala.com/api/v1/share/donate`
  static String get donateShareUrl => '$normalizedBaseUrl/share/donate';

  static String campaignDeepLink(String campaignId) =>
      '$appDeepLinkScheme://campaign/$campaignId';

  /// Opens the in-app campaign list (`DonationList`).
  static String get campaignListDeepLink =>
      '$appDeepLinkScheme://campaign/list';

  /// Opens the Donate bottom-tab (`DonatePage`).
  /// Trailing slash: Android path matching can reject path-less hosts.
  static String get donateDeepLink => '$appDeepLinkScheme://donate/';

  static String get playStoreUrl =>
      'https://play.google.com/store/apps/details?id=$androidPackageId';

  static String get appStoreUrl {
    if (iosAppStoreId.isNotEmpty) {
      return 'https://apps.apple.com/app/id$iosAppStoreId';
    }
    return 'https://apps.apple.com/search?term=Jamiat%20Connect';
  }

  static String? get configurationError {
    if (normalizedBaseUrl.isEmpty) {
      return 'API is not configured. Set BASE_URL in the .env file.';
    }
    return null;
  }
}
