import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:jamiat/src/data/constants/color_constants.dart';
import 'package:jamiat/src/data/constants/style_constants.dart';
import 'package:jamiat/src/data/services/haptic_helper.dart';
import 'package:jamiat/src/data/services/navigation_services.dart';

/// Dummy home data — replace with API models later.
class _HomeDummyData {
  static const userName = 'Muhammed Rashid';
  static const greeting = 'As- salamu alaykum';
  static const avatarAsset = 'assets/pngs/dummy_avatar.png';
  static const totalDonated = 68000;
  static const participatedCampaigns = 102;

  static const quickAccess = <_QuickAccessItem>[
    _QuickAccessItem(
      label: 'Welfare',
      icon: 'assets/svg/quick_welfare.svg',
      background: kQuickWelfareBg,
    ),
    _QuickAccessItem(
      label: 'Events',
      icon: 'assets/svg/quick_events.svg',
      background: kQuickEventsBg,
    ),
    _QuickAccessItem(
      label: 'Market',
      icon: 'assets/svg/quick_market.svg',
      background: kQuickMarketBg,
    ),
    _QuickAccessItem(
      label: 'News',
      icon: 'assets/svg/quick_news.svg',
      background: kQuickNewsBg,
    ),
  ];

  static const campaigns = <_CampaignItem>[
    _CampaignItem(
      title: 'Maktab support fund 2026',
      category: 'Education',
      image: 'assets/jpgs/campaign_education.jpg',
    ),
    _CampaignItem(
      title: 'Medical Aid for Fatima',
      category: 'Welfare',
      image: 'assets/jpgs/campaign_welfare.jpg',
    ),
  ];
}

class _QuickAccessItem {
  final String label;
  final String icon;
  final Color background;

  const _QuickAccessItem({
    required this.label,
    required this.icon,
    required this.background,
  });
}

class _CampaignItem {
  final String title;
  final String category;
  final String image;

  const _CampaignItem({
    required this.title,
    required this.category,
    required this.image,
  });
}

String _formatRupee(int amount) {
  final raw = amount.toString();
  final buf = StringBuffer();
  final len = raw.length;
  for (var i = 0; i < len; i++) {
    if (i > 0 && (len - i) % 3 == 0) buf.write(',');
    buf.write(raw[i]);
  }
  return '₹ $buf';
}

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: kWhite,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  kScreenPaddingH,
                  8,
                  kScreenPaddingH,
                  0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _HomeHeader(),
                    const SizedBox(height: 20),
                    const _ContributionsCard(),
                    const SizedBox(height: 24),
                    Text('Quick Access', style: kSectionTitleSB),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
            const _QuickAccessList(),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  kScreenPaddingH,
                  24,
                  kScreenPaddingH,
                  12,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text('Active Campaigns', style: kSectionTitleSB),
                    ),
                    GestureDetector(
                      onTap: () {
                        HapticHelper.impact(HapticImpact.light);
                        // TODO: navigate to campaigns list
                      },
                      child: Text('See all', style: kLinkM),
                    ),
                  ],
                ),
              ),
            ),
            const SliverToBoxAdapter(child: _ActiveCampaignsSection()),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
      floatingActionButton: _ContributeButton(
        onTap: () {
          HapticHelper.impact(HapticImpact.light);
          NavigationService().pushNamed('DonationList');
        },
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ClipOval(
          child: Image.asset(
            _HomeDummyData.avatarAsset,
            width: 48,
            height: 48,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _HomeDummyData.greeting,
                style: kCaption12R.copyWith(color: kSecondaryTextColor),
              ),
              const SizedBox(height: 2),
              Text(
                _HomeDummyData.userName,
                style: kBodyTitleSB.copyWith(fontSize: kSize16),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Material(
          color: kWhite,
          shape: const CircleBorder(side: BorderSide(color: kStrokeColor)),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: () {
              HapticHelper.impact(HapticImpact.light);
              // TODO: open notifications
            },
            child: SizedBox(
              width: 44,
              height: 44,
              child: Center(
                child: SvgPicture.asset(
                  'assets/svg/bell.svg',
                  width: 22,
                  height: 22,
                  colorFilter: const ColorFilter.mode(
                    kIconMuted,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ContributionsCard extends StatelessWidget {
  const _ContributionsCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kContributionsBg,
        borderRadius: BorderRadius.circular(kCardRadiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('My Contributions', style: kBodyTitleSB),
          const SizedBox(height: 4),
          Text(
            'Members-only deals & services',
            style: kCaption12R.copyWith(color: kMutedText),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _StatTile(
                  label: 'TOTAL DONATED',
                  value: _formatRupee(_HomeDummyData.totalDonated),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StatTile(
                  label: 'PARTICIPATED CAMPAIGNS',
                  value: '${_HomeDummyData.participatedCampaigns}',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;

  const _StatTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(kCardRadiusSm),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: kCaption10R.copyWith(
              color: kSecondaryTextColor,
              letterSpacing: 0.2,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: kLabel22B.copyWith(color: kPrimaryColor, height: 1.1),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _QuickAccessList extends StatelessWidget {
  const _QuickAccessList();

  static const double _cardWidth = 108;
  static const double _cardHeight = 132;

  @override
  Widget build(BuildContext context) {
    final items = _HomeDummyData.quickAccess;
    return SliverToBoxAdapter(
      child: SizedBox(
        height: _cardHeight,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: kScreenPaddingH),
          itemCount: items.length,
          separatorBuilder: (_, _) => const SizedBox(width: 10),
          itemBuilder: (context, index) {
            final item = items[index];
            return _QuickAccessCard(
              width: _cardWidth,
              height: _cardHeight,
              item: item,
              onTap: () {
                HapticHelper.impact(HapticImpact.light);
                // TODO: route per quick-access item
              },
            );
          },
        ),
      ),
    );
  }
}

class _QuickAccessCard extends StatelessWidget {
  final double width;
  final double height;
  final _QuickAccessItem item;
  final VoidCallback onTap;

  const _QuickAccessCard({
    required this.width,
    required this.height,
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Material(
        color: item.background,
        borderRadius: BorderRadius.circular(kCardRadiusLg),
        child: InkWell(
          borderRadius: BorderRadius.circular(kCardRadiusLg),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 14, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.label,
                  style: kCaption14B,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const Spacer(),
                Center(
                  child: SvgPicture.asset(
                    item.icon,
                    width: 44,
                    height: 44,
                    colorFilter: const ColorFilter.mode(
                      kIconDark,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ActiveCampaignsSection extends StatelessWidget {
  const _ActiveCampaignsSection();

  static const double _cardWidth = 200;
  static const double _cardHeight = 280;

  @override
  Widget build(BuildContext context) {
    final campaigns = _HomeDummyData.campaigns;

    return SizedBox(
      height: _cardHeight,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: kScreenPaddingH),
        itemCount: campaigns.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          return _CampaignCard(
            width: _cardWidth,
            height: _cardHeight,
            campaign: campaigns[index],
            onTap: () {
              HapticHelper.impact(HapticImpact.light);
              // TODO: open campaign detail
            },
          );
        },
      ),
    );
  }
}

class _CampaignCard extends StatelessWidget {
  final double width;
  final double height;
  final _CampaignItem campaign;
  final VoidCallback onTap;

  const _CampaignCard({
    required this.width,
    required this.height,
    required this.campaign,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: width,
        height: height,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(kCardRadiusLg),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(campaign.image, fit: BoxFit.cover),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0x00000000), Color(0x99000000)],
                    stops: [0.45, 1],
                  ),
                ),
              ),
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: kWhite.withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(kPillRadius),
                  ),
                  child: Text(
                    campaign.category,
                    style: kCaption10M.copyWith(color: kTextColor),
                  ),
                ),
              ),
              Positioned(
                left: 12,
                right: 12,
                bottom: 14,
                child: Text(
                  campaign.title,
                  style: kBodyTitleSB.copyWith(color: kWhite, height: 1.25),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ContributeButton extends StatelessWidget {
  final VoidCallback onTap;

  const _ContributeButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: kSecondaryColor,
      borderRadius: BorderRadius.circular(kPillRadius),
      elevation: 2,
      shadowColor: kBlack.withValues(alpha: 0.18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(kPillRadius),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Contribute', style: kCaption14B.copyWith(color: kDarkText)),
              const SizedBox(width: 8),
              SvgPicture.asset(
                'assets/svg/donate.svg',
                width: 18,
                height: 18,
                colorFilter: const ColorFilter.mode(kDarkText, BlendMode.srcIn),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
