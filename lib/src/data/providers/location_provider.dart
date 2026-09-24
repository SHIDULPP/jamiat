import 'package:flutter_countries/flutter_countries.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final getAllCountriesProvider = FutureProvider<List<Country>>((ref) async {
  final countries = await Countries.all;
  countries.sort(
    (a, b) => (a.name ?? '').toLowerCase().compareTo((b.name ?? '').toLowerCase()),
  );
  return countries;
});

final getStatesByCountryProvider =
    FutureProvider.family<List<State>, String>((ref, countryCode) async {
      try {
        // Package query uses substring match — keep exact ISO country only.
        final states = await States.byCountryCode(countryCode);
        final filtered = states
            .where((state) => state.countryCode == countryCode)
            .toList()
          ..sort(
            (a, b) => (a.name ?? '')
                .toLowerCase()
                .compareTo((b.name ?? '').toLowerCase()),
          );
        return filtered;
      } catch (_) {
        return [];
      }
    });

/// Districts/cities for a state.
///
/// [stateId] is preferred: state codes like `KL` / `01` collide across countries,
/// so `Cities.byStateCode` alone returns wrong places (e.g. Botswana + Congo
/// cities when Kerala/IN is selected).
typedef DistrictLookupParams = ({
  String countryCode,
  String stateCode,
  int? stateId,
});

final getDistrictsByStateProvider =
    FutureProvider.family<List<City>, DistrictLookupParams>((
      ref,
      params,
    ) async {
      try {
        List<City> cities;

        final stateId = params.stateId;
        if (stateId != null) {
          // Package `byStateId` uses substring match on the id string — exact id only.
          cities = await Cities.byStateId(stateId.toString());
          cities = cities.where((city) => city.stateId == stateId).toList();
        } else {
          // Fallback when we only know country + state code (e.g. legacy prefill).
          cities = await Cities.byStateCode(params.stateCode);
          cities = cities
              .where(
                (city) =>
                    city.stateCode == params.stateCode &&
                    city.countryCode == params.countryCode,
              )
              .toList();
        }

        cities.sort(
          (a, b) => (a.name ?? '')
              .toLowerCase()
              .compareTo((b.name ?? '').toLowerCase()),
        );
        return cities;
      } catch (_) {
        return [];
      }
    });
