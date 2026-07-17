import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:jamiat/src/data/config/app_config.dart';
import 'package:jamiat/src/data/models/api_response.dart';
import 'package:jamiat/src/data/services/api_logger.dart';
import 'package:jamiat/src/data/services/secure_storage_service.dart';

class ApiProvider {
  ApiProvider({
    required this.baseUrl,
    required this.apiKey,
    required this.secureStorage,
    http.Client? client,
  }) : _client = client ?? http.Client();

  final String baseUrl;
  final String apiKey;
  final SecureStorageService secureStorage;
  final http.Client _client;

  static const _timeout = Duration(seconds: 30);

  Future<ApiResponse<Map<String, dynamic>>> get(
    String endpoint, {
    bool requireAuth = false,
    Map<String, String>? queryParams,
  }) {
    return _send(
      'GET',
      endpoint,
      requireAuth: requireAuth,
      queryParams: queryParams,
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> post(
    String endpoint,
    Map<String, dynamic> body, {
    bool requireAuth = false,
  }) {
    return _send('POST', endpoint, body: body, requireAuth: requireAuth);
  }

  Future<ApiResponse<Map<String, dynamic>>> patch(
    String endpoint,
    Map<String, dynamic> body, {
    bool requireAuth = false,
  }) {
    return _send('PATCH', endpoint, body: body, requireAuth: requireAuth);
  }

  Future<ApiResponse<Map<String, dynamic>>> delete(
    String endpoint, {
    bool requireAuth = false,
  }) {
    return _send('DELETE', endpoint, requireAuth: requireAuth);
  }

  Future<ApiResponse<Map<String, dynamic>>> postMultipart({
    required String endpoint,
    required String fieldName,
    required Uint8List bytes,
    required String filename,
    required String mimeType,
    bool requireAuth = true,
  }) async {
    if (baseUrl.isEmpty) {
      return ApiResponse.error(
        AppConfig.configurationError ?? 'API base URL is missing.',
      );
    }

    late final Uri uri;
    try {
      uri = Uri.parse('$baseUrl$endpoint');
    } on FormatException catch (error) {
      return ApiResponse.error('The API address is invalid: $error');
    }

    final stopwatch = Stopwatch()..start();

    try {
      final headers = await _buildHeaders(
        requireAuth: requireAuth,
        includeJsonContentType: false,
      );

      final request = http.MultipartRequest('POST', uri)
        ..headers.addAll(headers)
        ..files.add(
          http.MultipartFile.fromBytes(
            fieldName,
            bytes,
            filename: filename,
            contentType: MediaType.parse(mimeType),
          ),
        );

      ApiLogger.request(
        method: 'POST',
        uri: uri,
        headers: headers,
        body: '<multipart $fieldName ${bytes.lengthInBytes} bytes>',
      );

      final streamed = await request.send().timeout(_timeout);
      final response = await http.Response.fromStream(streamed);

      stopwatch.stop();
      ApiLogger.response(
        method: 'POST',
        uri: uri,
        statusCode: response.statusCode,
        body: response.body,
        duration: stopwatch.elapsed,
      );

      return _parseResponse(response);
    } on StateError catch (error) {
      stopwatch.stop();
      ApiLogger.error(
        method: 'POST',
        uri: uri,
        error: error,
        duration: stopwatch.elapsed,
      );
      return ApiResponse.error(error.message);
    } on TimeoutException catch (error) {
      stopwatch.stop();
      ApiLogger.error(
        method: 'POST',
        uri: uri,
        error: error,
        duration: stopwatch.elapsed,
      );
      return ApiResponse.error('The request timed out. Please try again.');
    } catch (error) {
      stopwatch.stop();
      ApiLogger.error(
        method: 'POST',
        uri: uri,
        error: error,
        duration: stopwatch.elapsed,
      );
      return ApiResponse.error('Upload failed. Please try again.');
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> _send(
    String method,
    String endpoint, {
    Map<String, dynamic>? body,
    required bool requireAuth,
    Map<String, String>? queryParams,
  }) async {
    if (baseUrl.isEmpty) {
      return ApiResponse.error(
        AppConfig.configurationError ?? 'API base URL is missing.',
      );
    }

    late final Uri uri;
    try {
      final baseUri = Uri.parse('$baseUrl$endpoint');
      uri = queryParams != null && queryParams.isNotEmpty
          ? baseUri.replace(
              queryParameters: {...baseUri.queryParameters, ...queryParams},
            )
          : baseUri;
    } on FormatException catch (error) {
      return ApiResponse.error('The API address is invalid: $error');
    }

    final stopwatch = Stopwatch()..start();

    try {
      final headers = await _buildHeaders(requireAuth: requireAuth);
      final encodedBody = body == null ? null : jsonEncode(body);

      ApiLogger.request(
        method: method,
        uri: uri,
        headers: headers,
        body: encodedBody,
      );

      final response = switch (method) {
        'GET' => await _client.get(uri, headers: headers).timeout(_timeout),
        'POST' =>
          await _client
              .post(uri, headers: headers, body: encodedBody)
              .timeout(_timeout),
        'PATCH' =>
          await _client
              .patch(uri, headers: headers, body: encodedBody)
              .timeout(_timeout),
        'DELETE' =>
          await _client.delete(uri, headers: headers).timeout(_timeout),
        _ => throw UnsupportedError('Unsupported HTTP method: $method'),
      };

      stopwatch.stop();
      ApiLogger.response(
        method: method,
        uri: uri,
        statusCode: response.statusCode,
        body: response.body,
        duration: stopwatch.elapsed,
      );

      return _parseResponse(response);
    } on StateError catch (error) {
      stopwatch.stop();
      ApiLogger.error(
        method: method,
        uri: uri,
        error: error,
        duration: stopwatch.elapsed,
      );
      return ApiResponse.error(error.message);
    } on TimeoutException catch (error) {
      stopwatch.stop();
      ApiLogger.error(
        method: method,
        uri: uri,
        error: error,
        duration: stopwatch.elapsed,
      );
      return ApiResponse.error('The request timed out. Please try again.');
    } on FormatException catch (error) {
      stopwatch.stop();
      ApiLogger.error(
        method: method,
        uri: uri,
        error: error,
        duration: stopwatch.elapsed,
      );
      return ApiResponse.error('The API address or response is invalid.');
    } on http.ClientException catch (error) {
      stopwatch.stop();
      ApiLogger.error(
        method: method,
        uri: uri,
        error: error,
        duration: stopwatch.elapsed,
      );
      return ApiResponse.error(
        'Unable to connect to the server. Check your internet connection.',
      );
    } catch (error) {
      stopwatch.stop();
      ApiLogger.error(
        method: method,
        uri: uri,
        error: error,
        duration: stopwatch.elapsed,
      );
      return ApiResponse.error('Something went wrong. Please try again.');
    }
  }

  Future<Map<String, String>> _buildHeaders({
    required bool requireAuth,
    bool includeJsonContentType = true,
  }) async {
    final headers = <String, String>{'Accept': 'application/json'};

    if (includeJsonContentType) {
      headers['Content-Type'] = 'application/json';
    }

    if (apiKey.isNotEmpty) {
      headers['x-api-key'] = apiKey;
    }

    if (requireAuth) {
      final token = await secureStorage.getAuthToken();
      if (token == null || token.isEmpty) {
        throw StateError('Your session has expired. Please log in again.');
      }
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  ApiResponse<Map<String, dynamic>> _parseResponse(http.Response response) {
    Map<String, dynamic>? decoded;

    if (response.body.trim().isNotEmpty) {
      final body = jsonDecode(response.body);
      if (body is! Map) {
        return ApiResponse.error(
          'Unexpected response from the server.',
          response.statusCode,
        );
      }
      decoded = Map<String, dynamic>.from(body);
    }

    final message = decoded?['message']?.toString();
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return ApiResponse.success(
        decoded,
        response.statusCode,
        message: message,
      );
    }

    return ApiResponse.error(
      message ?? 'Request failed. Please try again.',
      response.statusCode,
    );
  }

  void dispose() => _client.close();
}

final apiProviderProvider = Provider<ApiProvider>((ref) {
  final provider = ApiProvider(
    baseUrl: AppConfig.normalizedBaseUrl,
    apiKey: AppConfig.apiKey,
    secureStorage: ref.watch(secureStorageServiceProvider),
  );
  ref.onDispose(provider.dispose);
  return provider;
});
