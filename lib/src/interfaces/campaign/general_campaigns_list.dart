import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jamiat/src/data/constants/color_constants.dart';
import 'package:jamiat/src/data/constants/style_constants.dart';
import 'package:jamiat/src/data/models/campaign_model.dart';
import 'package:jamiat/src/data/providers/campaign_provider.dart';
import 'package:jamiat/src/data/services/haptic_helper.dart';
import 'package:jamiat/src/data/services/navigation_services.dart';
import 'package:jamiat/src/interfaces/components/async_content.dart';
import 'package:jamiat/src/interfaces/components/campaign_card.dart';

/// Lists all active **General Campaign** items for autopay setup.
/// Card chrome matches Figma Campaigns list (636:1338).
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
              padding: const EdgeInsets.fromLTRB(
                kScreenPaddingH,
                16,
                kScreenPaddingH,
                0,
              ),
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
                        border: Border.all(color: kStrokeColor, width: 1.25),
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        color: kTextColor,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'General Campaigns',
                      style: kSectionTitleSB,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                kScreenPaddingH,
                12,
                kScreenPaddingH,
                0,
              ),
              child: Text(
                'Pick a campaign to set up recurring donations.',
                style: kCaption12R.copyWith(color: kSecondaryTextColor),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                kScreenPaddingH,
                16,
                kScreenPaddingH,
                0,
              ),
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: kWhite,
                  borderRadius: BorderRadius.circular(kPillRadius),
                  border: Border.all(color: kStrokeColor),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Row(
                  children: [
                    const Icon(
                      Icons.search,
                      color: kIconMuted,
                      size: 22,
                    ),
                    const SizedBox(width: 10),
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
                          contentPadding: EdgeInsets.zero,
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
                      padding: const EdgeInsets.fromLTRB(
                        kScreenPaddingH,
                        0,
                        kScreenPaddingH,
                        24,
                      ),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final campaign = filtered[index];
                        return CampaignListCard(
                          campaign: campaign,
                          donateLabel: 'Set up Autopay',
                          showOverlayActions: false,
                          onDonate: () => _openCampaign(campaign),
                          onBookmark: () {},
                          onShare: () {},
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
