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

  Widget _campaignImage(String? url) {
    final imageUrl = url?.trim();
    if (imageUrl != null &&
        imageUrl.isNotEmpty &&
        (imageUrl.startsWith('http://') ||
            imageUrl.startsWith('https://') ||
            imageUrl.startsWith('//'))) {
      final resolvedUrl = imageUrl.startsWith('//')
          ? 'https:$imageUrl'
          : imageUrl;
      return Image.network(
        resolvedUrl,
        width: 64,
        height: 64,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            width: 64,
            height: 64,
            color: kScreenBg,
            alignment: Alignment.center,
            child: const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        },
        errorBuilder: (_, _, _) => _campaignImagePlaceholder(),
      );
    }
    return _campaignImagePlaceholder();
  }

  Widget _campaignImagePlaceholder() {
    return Container(
      width: 64,
      height: 64,
      color: kScreenBg,
      child: const Icon(
        Icons.volunteer_activism_outlined,
        color: kMutedText,
        size: 24,
      ),
    );
  }

  String _transactionLabel(DonationModel donation) {
    final transactionId = donation.transactionId;
    if (transactionId != null && transactionId.isNotEmpty) {
      return transactionId.length > 12
          ? transactionId.substring(0, 12).toUpperCase()
          : transactionId.toUpperCase();
    }
    return donation.id.length > 12
        ? donation.id.substring(0, 12).toUpperCase()
        : donation.id.toUpperCase();
  }

  Widget _buildHistoryCard(DonationModel donation) {
    final displayDate = donation.displayDate;
    final dateTimeLabel = displayDate != null
        ? formatDonationDateTime(displayDate)
        : donation.status;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: _campaignImage(donation.coverImage),
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
                    _transactionLabel(donation),
                    style: kStyle(kMedium, 10, color: kSecondaryTextColor),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  donation.campaignName ?? 'Donation',
                  style: kBodyTitleB.copyWith(color: kTextColor, fontSize: 15),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  dateTimeLabel,
                  style: kCaption12R.copyWith(color: kSecondaryTextColor),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                formatRupee(donation.amount),
                style: kBodyTitleB.copyWith(color: kTextColor, fontSize: 16),
              ),
              if (donation.hasAutopay) ...[
                const SizedBox(height: 4),
                Text(
                  'Autopay',
                  style: kCaption12M.copyWith(color: kPrimaryColor),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  List<({String label, List<DonationModel> donations})> _groupByDate(
    List<DonationModel> donations,
  ) {
    final dated = <DateTime, List<DonationModel>>{};
    final undated = <DonationModel>[];

    for (final donation in donations) {
      final date = donation.displayDate;
      if (date == null) {
        undated.add(donation);
        continue;
      }
      final dayKey = DateTime(date.year, date.month, date.day);
      dated.putIfAbsent(dayKey, () => []).add(donation);
    }

    final groups = dated.entries.toList()
      ..sort((a, b) => b.key.compareTo(a.key));

    final result = groups
        .map(
          (entry) => (
            label: formatDonationGroupLabel(entry.key),
            donations: entry.value,
          ),
        )
        .toList();

    if (undated.isNotEmpty) {
      result.add((label: 'Recent', donations: undated));
    }

    return result;
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
                    ...grouped.map((group) {
                      final groupTotal = group.donations.fold<num>(
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
                                group.label,
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
                          ...group.donations.map(_buildHistoryCard),
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
