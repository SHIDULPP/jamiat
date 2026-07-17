import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jamiat/src/data/apis/empowerment_api.dart';
import 'package:jamiat/src/data/models/empowerment_model.dart';
import 'package:jamiat/src/data/models/paginated_response.dart';

final empowermentProgramsProvider =
    FutureProvider.family<PaginatedResponse<EmpowermentProgramModel>, String>((
      ref,
      mode,
    ) async {
      final response = await ref
          .watch(empowermentApiProvider)
          .getPrograms(mode: mode);
      if (!response.success || response.data == null) {
        throw Exception(response.message ?? 'Failed to load programs');
      }
      return response.data!;
    });

final empowermentProgramDetailProvider =
    FutureProvider.family<EmpowermentProgramModel, String>((ref, id) async {
      final response = await ref
          .watch(empowermentApiProvider)
          .getProgramById(id);
      if (!response.success || response.data == null) {
        throw Exception(response.message ?? 'Failed to load program');
      }
      return response.data!;
    });
