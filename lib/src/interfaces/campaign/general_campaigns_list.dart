import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jamiat/src/data/constants/color_constants.dart';
import 'package:jamiat/src/data/constants/style_constants.dart';
import 'package:jamiat/src/data/models/campaign_model.dart';
import 'package:jamiat/src/data/providers/campaign_provider.dart';
import 'package:jamiat/src/data/services/haptic_helper.dart';
import 'package:jamiat/src/data/services/navigation_services.dart';
import 'package:jamiat/src/data/utils/format_helpers.dart';
import 'package:jamiat/src/interfaces/components/async_content.dart';
import 'package:jamiat/src/interfaces/components/campaign_card.dart';

/// Lists all active **General Campaign** items for autopay setup.
class GeneralCampaignsListScreen extends ConsumerStatefulWidget {
  const GeneralCampaignsListScreen({super.key});

  @override
  ConsumerState<GeneralCampaignsListScreen> createState() =>
      _GeneralCampaignsListScreenState();
}

class _GeneralCampaignsListScreenState
    extends ConsumerState<GeneralCampaignsListScreen> {
  late final TextEditingController _searchController;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<CampaignModel> _filter(List<CampaignModel> items) {
    if (_query.isEmpty) return items;
    final q = _query.toLowerCase();
    return items.where((c) {
      return c.title.toLowerCase().contains(q) ||
          c.description.toLowerCase().contains(q);
    }).toList();
  }

  void _openCampaign(CampaignModel campaign) {
    HapticHelper.impact(HapticImpact.light);
    NavigationService().pushNamed(
      'CampaignDetails',
      arguments: {
        'campaignId': campaign.id,
        'title': campaign.title,
        'description': campaign.description,
        'category': campaign.category,
        'isAutopay': true,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final listAsync = ref.watch(
      campaignsByCategoryProvider('General Campaign'),
    );

    return Scaffold(
      backgroundColor: kWhite,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: Row(
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
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'General Campaigns',
                      style: kHeadTitleB.copyWith(
                        color: kTextColor,
                        fontSize: 22,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
              child: Text(
                'Pick a campaign to set up recurring donations.',
                style: kCaption14R.copyWith(color: kSecondaryTextColor),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: Container(
                decoration: BoxDecoration(
                  color: kWhite,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: kBorder, width: 1),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    const Icon(
                      Icons.search,
                      color: kSecondaryTextColor,
                      size: 22,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        style: kBodyTitleR.copyWith(color: kTextColor),
                        onChanged: (v) =>
                            setState(() => _query = v.trim()),
                        decoration: InputDecoration(
                          hintText: 'Search campaigns',
                          hintStyle: kBodyTitleR.copyWith(
                            color: kSecondaryTextColor,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: AsyncContent(
                asyncValue: listAsync,
                onRetry: () => ref.invalidate(
                  campaignsByCategoryProvider('General Campaign'),
                ),
                builder: (items) {
                  final filtered = _filter(items);
                  if (filtered.isEmpty) {
                    return Center(
                      child: Text(
                        'No general campaigns found',
                        style: kEmptyStateM,
                      ),
                    );
                  }
                  return RefreshIndicator(
                    color: kPrimaryColor,
                    onRefresh: () async {
                      ref.invalidate(
                        campaignsByCategoryProvider('General Campaign'),
                      );
                      await ref.read(
                        campaignsByCategoryProvider('General Campaign').future,
                      );
                    },
                    child: ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics(),
                      ),
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final campaign = filtered[index];
                        return _GeneralCampaignCard(
                          campaign: campaign,
                          onTap: () => _openCampaign(campaign),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GeneralCampaignCard extends StatelessWidget {
  const _GeneralCampaignCard({
    required this.campaign,
    required this.onTap,
  });

  final CampaignModel campaign;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final progress = campaign.targetAmount <= 0
        ? 0.0
        : (campaign.collectedAmount / campaign.targetAmount).clamp(0.0, 1.0);
    final daysLeft = campaign.remainingDays;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.circular(kCardRadiusLg),
        border: Border.all(color: kCardBorder),
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: 16 / 9,
                child: campaignCoverImage(campaign.coverImage),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      campaign.title,
                      style: kBodyTitleSB.copyWith(fontSize: 15),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${formatRupee(campaign.collectedAmount)} of '
                      '${formatRupee(campaign.targetAmount)}',
                      style: kCaption12M.copyWith(color: kMutedText),
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 6,
                        backgroundColor: kBorder,
                        color: kPrimaryColor,
                      ),
                    ),
                    if (daysLeft != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        daysLeft <= 0
                            ? 'Ended'
                            : '$daysLeft days left',
                        style: kCaption12R.copyWith(
                          color: daysLeft <= 7
                              ? kDaysLeftWarning
                              : kMutedText,
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: onTap,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kPrimaryColor,
                          foregroundColor: kWhite,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          'Set up Autopay',
                          style: kButtonLabelSB.copyWith(fontSize: 13),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
