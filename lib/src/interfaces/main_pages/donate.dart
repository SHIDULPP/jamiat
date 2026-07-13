import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:jamiat/src/data/constants/color_constants.dart';
import 'package:jamiat/src/data/constants/style_constants.dart';
import 'package:jamiat/src/data/services/haptic_helper.dart';
import 'package:jamiat/src/interfaces/components/primarybutton.dart';

/// Dummy campaigns data — replace with API models later.
class _DonateDummyData {
  static const categories = <String>[
    'All',
    'General Funding',
    'Zakath',
    'Orphan',
  ];

  static const activeCount = 12;
  static const raisedTotalLabel = '₹ 8.4L';
  static const donorsCount = 3240;
  static const endingSoonCount = 2;

  static const campaigns = <_CampaignListItem>[
    _CampaignListItem(
      id: '1',
      title: 'Maktab support fund 2026',
      description:
          'Providing resources and infrastructure for Islamic education centers in rural areas.',
      category: 'General Funding',
      image: 'assets/jpgs/campaign_education.jpg',
      raised: 68000,
      goal: 100000,
      daysLeft: 2,
    ),
    _CampaignListItem(
      id: '2',
      title: 'Medical Aid for Fatima',
      description:
          'Urgent medical support for a patient requiring surgery and post-operative care.',
      category: 'General Funding',
      image: 'assets/jpgs/campaign_welfare.jpg',
      raised: 42000,
      goal: 150000,
      daysLeft: 5,
    ),
    _CampaignListItem(
      id: '3',
      title: 'Zakath distribution drive',
      description:
          'Seasonal Zakath collection and distribution for eligible families in the community.',
      category: 'Zakath',
      image: 'assets/jpgs/campaign_education.jpg',
      raised: 125000,
      goal: 200000,
      daysLeft: 12,
    ),
    _CampaignListItem(
      id: '4',
      title: 'Orphan sponsorship 2026',
      description:
          'Monthly sponsorship covering education, food, and healthcare for orphaned children.',
      category: 'Orphan',
      image: 'assets/jpgs/campaign_welfare.jpg',
      raised: 89000,
      goal: 120000,
      daysLeft: 8,
    ),
  ];
}

class _CampaignListItem {
  final String id;
  final String title;
  final String description;
  final String category;
  final String image;
  final int raised;
  final int goal;
  final int daysLeft;

  const _CampaignListItem({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.image,
    required this.raised,
    required this.goal,
    required this.daysLeft,
  });

  double get progress => goal <= 0 ? 0 : (raised / goal).clamp(0.0, 1.0);

  int get percent => (progress * 100).round();
}

String _formatRupee(int amount) {
  final raw = amount.toString();
  final buf = StringBuffer();
  final len = raw.length;
  // Indian grouping: last 3, then pairs
  if (len <= 3) return '₹ $raw';
  final last3 = raw.substring(len - 3);
  var rest = raw.substring(0, len - 3);
  final parts = <String>[];
  while (rest.length > 2) {
    parts.insert(0, rest.substring(rest.length - 2));
    rest = rest.substring(0, rest.length - 2);
  }
  if (rest.isNotEmpty) parts.insert(0, rest);
  buf.writeAll(parts, ',');
  buf.write(',$last3');
  return '₹ $buf';
}

String _formatCount(int value) {
  final raw = value.toString();
  final buf = StringBuffer();
  final len = raw.length;
  for (var i = 0; i < len; i++) {
    if (i > 0 && (len - i) % 3 == 0) buf.write(',');
    buf.write(raw[i]);
  }
  return buf.toString();
}

class DonatePage extends StatefulWidget {
  const DonatePage({super.key});

  @override
  State<DonatePage> createState() => _DonatePageState();
}

class _DonatePageState extends State<DonatePage> {
  final _searchController = TextEditingController();
  String _selectedCategory = 'All';
  final Set<String> _bookmarkedIds = {};

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<_CampaignListItem> get _filteredCampaigns {
    final query = _searchController.text.trim().toLowerCase();
    return _DonateDummyData.campaigns.where((c) {
      final matchesCategory =
          _selectedCategory == 'All' || c.category == _selectedCategory;
      final matchesQuery =
          query.isEmpty ||
          c.title.toLowerCase().contains(query) ||
          c.description.toLowerCase().contains(query) ||
          c.category.toLowerCase().contains(query);
      return matchesCategory && matchesQuery;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final campaigns = _filteredCampaigns;

    return Scaffold(
      backgroundColor: kWhite,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(
                kScreenPaddingH,
                8,
                kScreenPaddingH,
                0,
              ),
              child: _CampaignsHeader(),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: kScreenPaddingH),
              child: _SearchField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(height: 14),
            _CategoryChips(
              categories: _DonateDummyData.categories,
              selected: _selectedCategory,
              onSelected: (value) {
                HapticHelper.impact(HapticImpact.light);
                setState(() => _selectedCategory = value);
              },
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  kScreenPaddingH,
                  0,
                  kScreenPaddingH,
                  24,
                ),
                children: [
                  const _StatsRow(),
                  const SizedBox(height: 14),
                  const _EndingSoonBanner(),
                  const SizedBox(height: 16),
                  if (campaigns.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 48),
                      child: Center(
                        child: Text('No campaigns found', style: kEmptyStateM),
                      ),
                    )
                  else
                    ...campaigns.map(
                      (campaign) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _CampaignCard(
                          campaign: campaign,
                          isBookmarked: _bookmarkedIds.contains(campaign.id),
                          onBookmark: () {
                            HapticHelper.impact(HapticImpact.light);
                            setState(() {
                              if (_bookmarkedIds.contains(campaign.id)) {
                                _bookmarkedIds.remove(campaign.id);
                              } else {
                                _bookmarkedIds.add(campaign.id);
                              }
                            });
                          },
                          onShare: () {
                            HapticHelper.impact(HapticImpact.light);
                            // TODO: share campaign link
                          },
                          onDonate: () {
                            HapticHelper.impact(HapticImpact.medium);
                            // TODO: open donation flow
                          },
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CampaignsHeader extends StatelessWidget {
  const _CampaignsHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text('Campaigns', style: kSectionTitleSB)),
        Material(
          color: kWhite,
          shape: const CircleBorder(side: BorderSide(color: kStrokeColor)),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: () {
              HapticHelper.impact(HapticImpact.light);
              // TODO: campaigns menu
            },
            child: const SizedBox(
              width: 40,
              height: 40,
              child: Icon(Icons.more_vert, color: kIconMuted, size: 22),
            ),
          ),
        ),
      ],
    );
  }
}

class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _SearchField({required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(kPillRadius),
        border: Border.all(color: kStrokeColor),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          const Icon(Icons.search, color: kIconMuted, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              style: kBodyTitleR,
              cursorColor: kPrimaryColor,
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                hintText: 'Search for campaigns',
                hintStyle: kBodyTitleR.copyWith(color: kSecondaryTextColor),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryChips extends StatelessWidget {
  final List<String> categories;
  final String selected;
  final ValueChanged<String> onSelected;

  const _CategoryChips({
    required this.categories,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: kScreenPaddingH),
        itemCount: categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final label = categories[index];
          final isSelected = label == selected;
          return GestureDetector(
            onTap: () => onSelected(label),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? kSecondaryColor : kWhite,
                borderRadius: BorderRadius.circular(kPillRadius),
                border: Border.all(
                  color: isSelected
                      ? kSecondaryColor
                      : kSecondaryColor.withValues(alpha: 0.55),
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                label,
                style: kCaption12M.copyWith(
                  color: isSelected ? kTextColor : kMutedText,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            label: 'Active',
            value: '${_DonateDummyData.activeCount}',
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StatCard(
            label: 'Raised Total',
            value: _DonateDummyData.raisedTotalLabel,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StatCard(
            label: 'Donors',
            value: _formatCount(_DonateDummyData.donorsCount),
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;

  const _StatCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: kContributionsBg,
        borderRadius: BorderRadius.circular(kCardRadiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: kCaption10R.copyWith(color: kSecondaryTextColor),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: kLabel19SB.copyWith(color: kPrimaryColor, height: 1.1),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _EndingSoonBanner extends StatelessWidget {
  const _EndingSoonBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      decoration: BoxDecoration(
        color: kEndingSoonBg,
        borderRadius: BorderRadius.circular(kCardRadiusMd),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: const BoxDecoration(
              color: kRed,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.priority_high, color: kWhite, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_DonateDummyData.endingSoonCount} Campaigns ending in less than 3 days',
                  style: kCaption14M.copyWith(color: kTextColor, height: 1.35),
                ),
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: () {
                    HapticHelper.impact(HapticImpact.light);
                    // TODO: scroll/filter ending-soon campaigns
                  },
                  child: Text('Donate Now', style: kLinkSB),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CampaignCard extends StatelessWidget {
  final _CampaignListItem campaign;
  final bool isBookmarked;
  final VoidCallback onBookmark;
  final VoidCallback onShare;
  final VoidCallback onDonate;

  const _CampaignCard({
    required this.campaign,
    required this.isBookmarked,
    required this.onBookmark,
    required this.onShare,
    required this.onDonate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.circular(kCardRadiusLg),
        border: Border.all(color: kCardBorder),
        boxShadow: [
          BoxShadow(
            color: kBlack.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 180,
            width: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(campaign.image, fit: BoxFit.cover),
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: kBlack.withValues(alpha: 0.45),
                      borderRadius: BorderRadius.circular(kPillRadius),
                    ),
                    child: Text(
                      campaign.category,
                      style: kCaption10M.copyWith(color: kWhite),
                    ),
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: Row(
                    children: [
                      _OverlayIconButton(
                        asset: 'assets/svg/share.svg',
                        onTap: onShare,
                      ),
                      const SizedBox(width: 8),
                      _OverlayIconButton(
                        asset: 'assets/svg/bookmark.svg',
                        onTap: onBookmark,
                        filled: isBookmarked,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  campaign.title,
                  style: kBodyTitleSB.copyWith(fontSize: kSize16),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text(
                  campaign.description,
                  style: kCaption12R.copyWith(color: kMutedText, height: 1.4),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 14),
                ClipRRect(
                  borderRadius: BorderRadius.circular(kPillRadius),
                  child: LinearProgressIndicator(
                    value: campaign.progress,
                    minHeight: 8,
                    backgroundColor: kGreyLight,
                    color: kSecondaryColor,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _formatRupee(campaign.raised),
                            style: kBodyTitleSB,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'of ${_formatRupee(campaign.goal)}',
                            style: kCaption12R.copyWith(
                              color: kSecondaryTextColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('${campaign.percent}%', style: kBodyTitleSB),
                        const SizedBox(height: 2),
                        Text(
                          '${campaign.daysLeft} days left',
                          style: kCaption12M.copyWith(color: kDaysLeftWarning),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                primaryButton(
                  label: 'Donate Now',
                  onPressed: onDonate,
                  buttonHeight: 48,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OverlayIconButton extends StatelessWidget {
  final String asset;
  final VoidCallback onTap;
  final bool filled;

  const _OverlayIconButton({
    required this.asset,
    required this.onTap,
    this.filled = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: kBlack.withValues(alpha: 0.35),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 36,
          height: 36,
          child: Center(
            child: SvgPicture.asset(
              asset,
              width: 16,
              height: 16,
              colorFilter: ColorFilter.mode(
                filled ? kSecondaryColor : kWhite,
                BlendMode.srcIn,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
