import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jamiat/src/data/models/api_response.dart';
import 'package:jamiat/src/data/providers/api_provider.dart';

class UploadApi {
  UploadApi(this._api);

  final ApiProvider _api;

  Future<ApiResponse<String>> uploadImage({
    required Uint8List bytes,
    required String filename,
    String mimeType = 'image/jpeg',
  }) async {
    final response = await _api.postMultipart(
      endpoint: '/upload',
      fieldName: 'image',
      bytes: bytes,
      filename: filename,
      mimeType: mimeType,
      requireAuth: true,
    );

    if (!response.success) {
      return ApiResponse.error(
        response.message ?? 'Upload failed',
        response.statusCode,
      );
    }

    final data = response.data?['data'];
    if (data is String && data.isNotEmpty) {
      return ApiResponse.success(data, response.statusCode ?? 200);
    }

    return ApiResponse.error('Invalid upload response', response.statusCode);
  }
}

final uploadApiProvider = Provider<UploadApi>(
  (ref) => UploadApi(ref.watch(apiProviderProvider)),
);
