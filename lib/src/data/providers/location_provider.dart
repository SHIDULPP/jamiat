import 'package:flutter_countries/flutter_countries.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final getAllCountriesProvider = FutureProvider<List<Country>>((ref) async {
  return Countries.all;
});

final getStatesByCountryProvider =
    FutureProvider.family<List<State>, String>((ref, countryCode) async {
      try {
        return await States.byCountryCode(countryCode);
      } catch (_) {
        return [];
      }
    });

typedef DistrictLookupParams = ({String countryCode, String stateCode});

final getDistrictsByStateProvider =
    FutureProvider.family<List<City>, DistrictLookupParams>((
      ref,
      params,
    ) async {
      try {
        return await Cities.byStateCode(params.stateCode);
      } catch (_) {
        return [];
      }
    });
