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

  static String? get configurationError {
    if (normalizedBaseUrl.isEmpty) {
      return 'API is not configured. Set BASE_URL in the .env file.';
    }
    return null;
  }
}
