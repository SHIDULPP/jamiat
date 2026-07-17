import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jamiat/src/data/constants/color_constants.dart';
import 'package:jamiat/src/data/constants/style_constants.dart';
import 'package:jamiat/src/data/models/donation_model.dart';
import 'package:jamiat/src/data/providers/donation_provider.dart';
import 'package:jamiat/src/data/services/haptic_helper.dart';
import 'package:jamiat/src/data/utils/format_helpers.dart';
import 'package:jamiat/src/interfaces/components/async_content.dart';

class DonationHistoryScreen extends ConsumerWidget {
  const DonationHistoryScreen({super.key});

  Widget _buildStatCard(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: kCaption14M.copyWith(color: kMutedText, fontSize: 13),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: kHeadTitleB.copyWith(color: kPrimaryColor, fontSize: 22),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(DonationModel donation) {
    final dateLabel = donation.paidAt != null
        ? formatDateLabel(donation.paidAt)
        : '';
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: 64,
              height: 64,
              color: kScreenBg,
              child: const Icon(
                Icons.volunteer_activism_outlined,
                color: kMutedText,
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEEEEE),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    donation.id.length > 12
                        ? donation.id.substring(0, 12).toUpperCase()
                        : donation.id.toUpperCase(),
                    style: kStyle(kMedium, 10, color: kSecondaryTextColor),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  donation.campaignName ?? 'Donation',
                  style: kBodyTitleB.copyWith(color: kTextColor, fontSize: 15),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  dateLabel.isEmpty ? donation.status : dateLabel,
                  style: kCaption12R.copyWith(color: kSecondaryTextColor),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            formatRupee(donation.amount),
            style: kBodyTitleB.copyWith(color: kTextColor, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Map<String, List<DonationModel>> _groupByDate(List<DonationModel> donations) {
    final map = <String, List<DonationModel>>{};
    for (final d in donations) {
      final key = d.paidAt != null ? formatDateLabel(d.paidAt) : 'Recent';
      map.putIfAbsent(key, () => []).add(d);
    }
    return map;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(donationHistoryProvider);

    return Scaffold(
      backgroundColor: kWhite,
      body: SafeArea(
        child: AsyncContent(
          asyncValue: historyAsync,
          onRetry: () => ref.invalidate(donationHistoryProvider),
          builder: (data) {
            final grouped = _groupByDate(data.donations);
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () {
                          HapticHelper.impact(HapticImpact.light);
                          Navigator.pop(context);
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: kWhite,
                            border: Border.all(color: kBorder, width: 1.25),
                          ),
                          child: const Icon(
                            Icons.arrow_back,
                            color: kTextColor,
                            size: 20,
                          ),
                        ),
                      ),
                      Text(
                        'My Donations',
                        style: kHeadTitleB.copyWith(
                          color: kTextColor,
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(width: 40),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'Total Donated',
                          formatRupee(data.summary.totalDonated),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: _buildStatCard(
                          'Campaigns',
                          '${data.summary.participatedCampaigns}',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  if (data.donations.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 48),
                      child: Center(
                        child: Text('No donations yet', style: kEmptyStateM),
                      ),
                    )
                  else
                    ...grouped.entries.map((entry) {
                      final groupTotal = entry.value.fold<num>(
                        0,
                        (sum, d) => sum + d.amount,
                      );
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                entry.key,
                                style: kBodyTitleB.copyWith(
                                  color: kTextColor,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                formatRupee(groupTotal),
                                style: kCaption14R.copyWith(color: kTextColor),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ...entry.value.map(_buildHistoryCard),
                          const SizedBox(height: 24),
                        ],
                      );
                    }),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
