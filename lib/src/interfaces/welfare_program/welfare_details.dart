import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jamiat/src/data/apis/campaign_api.dart';
import 'package:jamiat/src/data/constants/color_constants.dart';
import 'package:jamiat/src/data/constants/style_constants.dart';
import 'package:jamiat/src/data/models/campaign_model.dart';
import 'package:jamiat/src/data/models/welfare_model.dart';
import 'package:jamiat/src/data/providers/campaign_provider.dart';
import 'package:jamiat/src/data/providers/welfare_provider.dart';
import 'package:jamiat/src/data/services/haptic_helper.dart';
import 'package:jamiat/src/data/services/navigation_services.dart';
import 'package:jamiat/src/interfaces/components/async_content.dart';
import 'package:jamiat/src/interfaces/components/campaign_card.dart';

class WelfareDetailsScreen extends ConsumerStatefulWidget {
  final String welfareId;

  const WelfareDetailsScreen({super.key, required this.welfareId});

  @override
  ConsumerState<WelfareDetailsScreen> createState() =>
      _WelfareDetailsScreenState();
}

class _WelfareDetailsScreenState extends ConsumerState<WelfareDetailsScreen> {
  final Map<String, bool> _bookmarkOverrides = {};
  String? _bookmarkLoadingId;
  String? _shareLoadingId;

  bool _isBookmarked(CampaignModel campaign) {
    return _bookmarkOverrides[campaign.id] ?? campaign.isBookmarked;
  }

  Future<void> _toggleBookmark(CampaignModel campaign) async {
    if (_bookmarkLoadingId != null) return;
    final currently = _isBookmarked(campaign);
    setState(() => _bookmarkLoadingId = campaign.id);
    try {
      final api = ref.read(campaignApiProvider);
      final res = currently
          ? await api.removeBookmark(campaign.id)
          : await api.bookmarkCampaign(campaign.id);
      if (!mounted) return;
      if (!res.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res.message ?? 'Bookmark failed')),
        );
        return;
      }
      setState(() => _bookmarkOverrides[campaign.id] = !currently);
      ref.invalidate(savedCampaignsProvider);
      ref.invalidate(welfareDetailProvider(widget.welfareId));
    } finally {
      if (mounted) setState(() => _bookmarkLoadingId = null);
    }
  }

  Future<void> _shareCampaign(CampaignModel campaign) async {
    if (_shareLoadingId != null) return;
    setState(() => _shareLoadingId = campaign.id);
    try {
      final res = await ref
          .read(campaignApiProvider)
          .shareCampaign(campaign.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            res.success
                ? 'Thanks for sharing ${campaign.title}'
                : (res.message ?? 'Share failed'),
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _shareLoadingId = null);
    }
  }

  void _openDonate(CampaignModel campaign) {
    HapticHelper.impact(HapticImpact.medium);
    NavigationService().pushNamed(
      'CampaignDetails',
      arguments: {'campaignId': campaign.id},
    );
  }

  Widget _heroImage(String? url) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: url != null && url.startsWith('http')
          ? Image.network(
              url,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Image.asset(
                'assets/jpgs/campaign_welfare.jpg',
                fit: BoxFit.cover,
              ),
            )
          : Image.asset(
              'assets/jpgs/campaign_welfare.jpg',
              fit: BoxFit.cover,
            ),
    );
  }

  Widget _buildBody(WelfareServiceModel service) {
    final hasTarget =
        (service.targetLabel != null && service.targetLabel!.isNotEmpty) ||
        service.targetYear != null;
    final targetTitle = service.targetYear != null
        ? 'Target for ${service.targetYear} Years'
        : 'Target';
    final targetSub =
        service.targetLabel?.isNotEmpty == true ? service.targetLabel! : '';

    return RefreshIndicator(
      color: kPrimaryColor,
      onRefresh: () async {
        ref.invalidate(welfareDetailProvider(widget.welfareId));
        await ref.read(welfareDetailProvider(widget.welfareId).future);
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: _heroImage(service.icon),
            ),
            const SizedBox(height: 16),
            Text(
              service.shortDescription,
              style: kBodyTitleSB.copyWith(fontSize: 15, height: 1.45),
            ),
            if (service.fullDescription != null &&
                service.fullDescription!.trim().isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                service.fullDescription!,
                style: kCaption14R.copyWith(color: kText2Color, height: 1.5),
              ),
            ],
            for (final block in service.statements) ...[
              const SizedBox(height: 20),
              Text(block.heading, style: kSectionTitleSB),
              const SizedBox(height: 8),
              Text(
                block.description,
                style: kCaption14R.copyWith(color: kText2Color, height: 1.5),
              ),
            ],
            if (service.impactStatus.isNotEmpty) ...[
              const SizedBox(height: 24),
              Text('Journey so far', style: kSectionTitleSB),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: service.impactStatus.map((stat) {
                  return Container(
                    width: (MediaQuery.sizeOf(context).width - 48 - 10) / 2,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF8E7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          stat.title,
                          style: kCaption12R.copyWith(color: kMutedText),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          stat.status,
                          style: kBodyTitleSB.copyWith(
                            color: const Color(0xFFD97706),
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
            if (hasTarget) ...[
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFFDBEAFE),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.track_changes,
                        color: Color(0xFF2563EB),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            targetTitle,
                            style: kBodyTitleB.copyWith(
                              color: const Color(0xFF1E3A8A),
                              fontSize: 13,
                            ),
                          ),
                          if (targetSub.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              targetSub,
                              style: kCaption12R.copyWith(
                                color: const Color(0xFF2563EB),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 24),
            Text(
              'Donate for ${service.name}',
              style: kSectionTitleSB.copyWith(fontSize: 16),
            ),
            const SizedBox(height: 14),
            if (service.linkedCampaigns.isEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 32),
                child: Text(
                  'No active campaigns for this program yet.',
                  style: kEmptyStateM,
                ),
              )
            else
              ...service.linkedCampaigns.map(
                (campaign) => CampaignListCard(
                  campaign: campaign,
                  isBookmarked: _isBookmarked(campaign),
                  isBookmarkLoading: _bookmarkLoadingId == campaign.id,
                  isShareLoading: _shareLoadingId == campaign.id,
                  onDonate: () => _openDonate(campaign),
                  onBookmark: () {
                    HapticHelper.impact(HapticImpact.light);
                    _toggleBookmark(campaign);
                  },
                  onShare: () {
                    HapticHelper.impact(HapticImpact.light);
                    _shareCampaign(campaign);
                  },
                ),
              ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final detailAsync = ref.watch(welfareDetailProvider(widget.welfareId));
    final title = detailAsync.value?.name ?? 'Welfare';

    return Scaffold(
      backgroundColor: kWhite,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
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
                      title,
                      style: kHeadTitleB.copyWith(
                        color: kTextColor,
                        fontSize: 20,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: AsyncContent(
                asyncValue: detailAsync,
                onRetry: () =>
                    ref.invalidate(welfareDetailProvider(widget.welfareId)),
                builder: _buildBody,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
