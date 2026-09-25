import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  AppConfig._();

  static String get baseUrl => dotenv.env['BASE_URL']?.trim() ?? '';
  static String get apiKey => dotenv.env['API_KEY']?.trim() ?? '';

  static String get normalizedBaseUrl {
    final value = baseUrl;
    if (value.endsWith('/')) {
      return value.substring(0, value.length - 1);
    }
    return value;
  }

  /// Host for share links. Defaults to API host (…/api/v1) so nginx hits Node.
  static String get shareBaseUrl {
    final explicit = dotenv.env['SHARE_BASE_URL']?.trim();
    if (explicit != null && explicit.isNotEmpty) {
      return explicit.replaceAll(RegExp(r'/+$'), '');
    }
    // e.g. https://uat-admin.juhkerala.com/api/v1
    return normalizedBaseUrl;
  }

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

  /// Must stay under `/api/v1/...` — the admin SPA owns non-API paths and
  /// redirects guests to https://uat-admin.juhkerala.com/login.
  static String campaignShareUrl(String campaignId) {
    var origin = shareBaseUrl;
    // Normalize whether SHARE_BASE_URL is host or …/api/v1
    origin = origin.replaceFirst(RegExp(r'/api/v\d+/?$'), '');
    return '$origin/api/v1/share/campaign/$campaignId';
  }

  static String campaignDeepLink(String campaignId) =>
      '$appDeepLinkScheme://campaign/$campaignId';

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
