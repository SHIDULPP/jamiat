import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jamiat/src/data/models/api_response.dart';
import 'package:jamiat/src/data/models/location_model.dart';
import 'package:jamiat/src/data/providers/api_provider.dart';

class LocationApi {
  LocationApi(this._api);

  final ApiProvider _api;

  /// Active districts from Jamiat location module (API key only, no JWT).
  Future<ApiResponse<List<LocationDistrict>>> getDistricts() async {
    final response = await _api.get('/location/districts');
    if (!response.success) {
      return ApiResponse.error(
        response.message ?? 'Failed to load districts',
        response.statusCode,
      );
    }

    final districts = nestedListData(response.data)
        .map(LocationDistrict.fromJson)
        .where((d) => d.id.isNotEmpty && d.name.isNotEmpty)
        .toList();

    return ApiResponse.success(districts, response.statusCode ?? 200);
  }

  /// Active areas, optionally scoped to a district id or district name.
  Future<ApiResponse<List<LocationArea>>> getAreas({
    String? districtId,
    String? districtName,
  }) async {
    final response = await _api.get(
      '/location/areas',
      queryParams: {
        if (districtId != null && districtId.trim().isNotEmpty)
          'district_id': districtId.trim()
        else if (districtName != null && districtName.trim().isNotEmpty)
          'district': districtName.trim(),
      },
    );

    if (!response.success) {
      return ApiResponse.error(
        response.message ?? 'Failed to load areas',
        response.statusCode,
      );
    }

    final areas = nestedListData(response.data)
        .map(LocationArea.fromJson)
        .where((a) => a.id.isNotEmpty && a.name.isNotEmpty)
        .toList();

    return ApiResponse.success(areas, response.statusCode ?? 200);
  }
}

final locationApiProvider = Provider<LocationApi>(
  (ref) => LocationApi(ref.watch(apiProviderProvider)),
);
