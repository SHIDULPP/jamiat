import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jamiat/src/data/apis/user_api.dart';
import 'package:jamiat/src/data/models/user_model.dart';
import 'package:jamiat/src/data/providers/donation_provider.dart';

final homeStatsProvider =
    FutureProvider<
      ({UserModel user, num totalDonated, int participatedCampaigns})
    >((ref) async {
      final profile = await ref.watch(userProfileProvider.future);
      final history = await ref.watch(donationHistoryProvider.future);

      return (
        user: profile,
        totalDonated: history.summary.totalDonated,
        participatedCampaigns: history.summary.participatedCampaigns,
      );
    });
