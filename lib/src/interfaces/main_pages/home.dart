import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:jamiat/src/data/constants/color_constants.dart';
import 'package:jamiat/src/data/constants/style_constants.dart';
import 'package:jamiat/src/data/models/campaign_model.dart';
import 'package:jamiat/src/data/providers/campaign_provider.dart';
import 'package:jamiat/src/data/providers/home_provider.dart';
import 'package:jamiat/src/data/providers/news_provider.dart';
import 'package:jamiat/src/data/router/nav_router.dart';
import 'package:jamiat/src/data/services/haptic_helper.dart';
import 'package:jamiat/src/data/services/navigation_services.dart';
import 'package:jamiat/src/data/utils/category_mapper.dart';
import 'package:jamiat/src/data/utils/format_helpers.dart';
import 'package:jamiat/src/interfaces/components/async_content.dart';

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

const _quickAccessItems = <_QuickAccessItem>[
  _QuickAccessItem(
    label: 'Autopay',
    icon: 'assets/svg/autopay.svg',
    background: Color(0xFFECFDF5),
  ),
  _QuickAccessItem(
    label: 'Welfare',
    icon: 'assets/svg/welfare.svg',
    background: kQuickWelfareBg,
  ),
  _QuickAccessItem(
    label: 'Events',
    icon: 'assets/svg/events.svg',
    background: kQuickEventsBg,
  ),
  _QuickAccessItem(
    label: 'Market',
    icon: 'assets/svg/market.svg',
    background: kQuickMarketBg,
  ),
  _QuickAccessItem(
    label: 'News',
    icon: 'assets/svg/news.svg',
    background: kQuickNewsBg,
  ),
  _QuickAccessItem(
    label: 'Programs',
    icon: 'assets/svg/programs.svg',
    background: Color(0xFFF5EBE6),
  ),
];

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: kWhite,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
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
                        NavigationService().pushNamed('DonationList');
                      },
                      child: Text('See all', style: kLinkM),
                    ),
                  ],
                ),
              ),
            ),
            const SliverToBoxAdapter(child: _ActiveCampaignsSection()),

            // Jamiat Market Place promo — Figma 2248:718
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: kScreenPaddingH,
                  vertical: 20,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: ColoredBox(
                    color: const Color(0xFFF4F4F4),
                    child: Stack(
                      clipBehavior: Clip.hardEdge,
                      children: [
                        Positioned(
                          right: -9,
                          top: 0,
                          bottom: 0,
                          width: 168,
                          child: Center(
                            child: SizedBox(
                              width: 168,
                              height: 112,
                              child: Image.asset(
                                'assets/pngs/market_banner.png',
                                fit: BoxFit.cover,
                                alignment: Alignment.center,
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Jamiat Market Place',
                                style: kLabel15SB.copyWith(height: 1.2),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Discover exclusive deals & items',
                                style: kCaption12R.copyWith(
                                  color: kTextColor,
                                  height: 1.2,
                                ),
                              ),
                              const SizedBox(height: 10),
                              GestureDetector(
                                onTap: () {
                                  HapticHelper.impact(HapticImpact.light);
                                  ref
                                      .read(selectedIndexProvider.notifier)
                                      .updateIndex(2);
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: kPrimaryColor,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    'Explore',
                                    style: kCaption12M.copyWith(
                                      color: kWhite,
                                      height: 1.2,
                                    ),
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
              ),
            ),

            // Redesigned: Welfare Grid Section
            const SliverToBoxAdapter(child: _WelfareGridSection()),

            // Medical Relief Fund banner — Figma 2248:756 / Frame 2001
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: kScreenPaddingH,
                  vertical: 20,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: ColoredBox(
                    color: const Color(0xFFFEF9E7),
                    child: SizedBox(
                      height: 162,
                      child: Stack(
                        clipBehavior: Clip.hardEdge,
                        children: [
                          // Decorative wavy vectors on the right
                          Positioned(
                            right: -30,
                            top: -20,
                            width: 180,
                            height: 140,
                            child: Opacity(
                              opacity: 0.85,
                              child: Image.asset(
                                'assets/pngs/medical_deco_1.png',
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                          Positioned(
                            right: -20,
                            bottom: -50,
                            width: 140,
                            height: 170,
                            child: Opacity(
                              opacity: 0.75,
                              child: Image.asset(
                                'assets/pngs/medical_deco_3.png',
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                          // Content
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: kWhite,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    'Medical Relief Fund',
                                    style: kCaption12M.copyWith(
                                      color: kTextColor,
                                      height: 1.2,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                SizedBox(
                                  width: 210,
                                  child: Text(
                                    'Millions lack healthcare; fund life-\nsaving medicine today.',
                                    style: kBodyTitleSB.copyWith(
                                      color: kTextColor,
                                      fontSize: 17,
                                      height: 1.2,
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                GestureDetector(
                                  onTap: () {
                                    HapticHelper.impact(HapticImpact.light);
                                    NavigationService().pushNamed(
                                      'DonationList',
                                    );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      color: kSecondaryColor,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      'Donate Now',
                                      style: kCaption12M.copyWith(
                                        color: kTextColor,
                                        height: 1.2,
                                      ),
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
                ),
              ),
            ),

            // Redesigned: Latest News List
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  kScreenPaddingH,
                  16,
                  kScreenPaddingH,
                  12,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Latest News', style: kSectionTitleSB),
                    GestureDetector(
                      onTap: () {
                        HapticHelper.impact(HapticImpact.light);
                        NavigationService().pushNamed('NewsList');
                      },
                      child: Text('See all', style: kLinkM),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 140,
                child: Consumer(
                  builder: (context, ref, _) {
                    final newsAsync = ref.watch(newsListProvider);
                    return AsyncContent(
                      asyncValue: newsAsync,
                      onRetry: () => ref.invalidate(newsListProvider),
                      builder: (page) {
                        final items = page.items.take(5).toList();
                        if (items.isEmpty) {
                          return Center(
                            child: Text('No news yet', style: kEmptyStateM),
                          );
                        }
                        return ListView.separated(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(
                            horizontal: kScreenPaddingH,
                          ),
                          itemCount: items.length,
                          separatorBuilder: (_, _) => const SizedBox(width: 12),
                          itemBuilder: (context, index) {
                            final item = items[index];
                            return GestureDetector(
                              onTap: () {
                                HapticHelper.impact(HapticImpact.light);
                                NavigationService().pushNamed(
                                  'NewsDetail',
                                  arguments: {'newsId': item.id},
                                );
                              },
                              child: Container(
                                width: 280,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: kWhite,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: kBorder),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.subTitle ?? 'Announcement',
                                      style: kCaption10M.copyWith(
                                        color: kMutedText,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      item.title,
                                      style: kBodyTitleB.copyWith(
                                        color: kTextColor,
                                        fontSize: 14,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      item.description,
                                      style: kCaption12R.copyWith(
                                        color: kSecondaryTextColor,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ),

            // Redesigned: Empowerment Programs blue card
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: kScreenPaddingH,
                  vertical: 24,
                ),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF), // Blue background
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFDBEAFE)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Empowerment Programs',
                        style: kBodyTitleB.copyWith(
                          color: const Color(0xFF1E3A8A),
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'For skill building, financial support, and active services.',
                        style: kCaption12R.copyWith(
                          color: const Color(0xFF2563EB),
                        ),
                      ),
                      const SizedBox(height: 14),
                      ElevatedButton(
                        onPressed: () {
                          HapticHelper.impact(HapticImpact.light);
                          NavigationService().pushNamed('EmpowermentPrograms');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Explore Programs',
                          style: kCaption12M.copyWith(
                            color: kWhite,
                            fontWeight: kBold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 48)),
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

class _HomeHeader extends ConsumerWidget {
  const _HomeHeader();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(homeStatsProvider);
    final user = statsAsync.value?.user;
    final userName = user?.displayName ?? 'Member';
    final image = user?.image;

    return Row(
      children: [
        ClipOval(
          child: image != null && image.startsWith('http')
              ? Image.network(
                  image,
                  width: 48,
                  height: 48,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Image.asset(
                    'assets/pngs/dummy_avatar.png',
                    width: 48,
                    height: 48,
                    fit: BoxFit.cover,
                  ),
                )
              : Image.asset(
                  'assets/pngs/dummy_avatar.png',
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
                'As-salamu alaykum',
                style: kCaption12R.copyWith(color: kSecondaryTextColor),
              ),
              const SizedBox(height: 2),
              Text(
                userName,
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
              NavigationService().pushNamed('Notifications');
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

class _ContributionsCard extends ConsumerWidget {
  const _ContributionsCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(homeStatsProvider);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFECFDF5),
        borderRadius: BorderRadius.circular(kCardRadiusLg),
      ),
      child: AsyncContent(
        asyncValue: statsAsync,
        onRetry: () => ref.invalidate(homeStatsProvider),
        builder: (stats) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'My Contributions',
              style: kBodyTitleSB.copyWith(color: const Color(0xFF065F46)),
            ),
            const SizedBox(height: 4),
            Text(
              'Welcome, ${stats.user.displayName}',
              style: kCaption12R.copyWith(color: const Color(0xFF047857)),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _StatTile(
                    label: 'TOTAL DONATED',
                    value: formatRupee(stats.totalDonated),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _StatTile(
                    label: 'PARTICIPATED CAMPAIGNS',
                    value: '${stats.participatedCampaigns}',
                  ),
                ),
              ],
            ),
          ],
        ),
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
            style: kLabel22B.copyWith(
              color: const Color(0xFF059669), // Green text matching mockup
              height: 1.1,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _QuickAccessList extends ConsumerWidget {
  const _QuickAccessList();

  // Figma 2320:688 — cards 100×126, gap 16
  static const double _cardWidth = 100;
  static const double _cardHeight = 126;
  static const double _cardGap = 16;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = _quickAccessItems;
    return SliverToBoxAdapter(
      child: SizedBox(
        height: _cardHeight,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: kScreenPaddingH),
          itemCount: items.length,
          separatorBuilder: (_, _) => const SizedBox(width: _cardGap),
          itemBuilder: (context, index) {
            final item = items[index];
            return _QuickAccessCard(
              width: _cardWidth,
              height: _cardHeight,
              item: item,
              onTap: () {
                HapticHelper.impact(HapticImpact.light);
                switch (item.label) {
                  case 'Events':
                    NavigationService().pushNamed('Events');
                  case 'Welfare':
                    NavigationService().pushNamed('WelfareProgram');
                  case 'Autopay':
                    NavigationService().pushNamed('AutopayView');
                  case 'News':
                    NavigationService().pushNamed('NewsList');
                  case 'Programs':
                    NavigationService().pushNamed('EmpowermentPrograms');
                  case 'Market':
                    ref.read(selectedIndexProvider.notifier).updateIndex(2);
                }
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
        borderRadius: BorderRadius.circular(kCardRadiusMd),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          borderRadius: BorderRadius.circular(kCardRadiusMd),
          onTap: onTap,
          child: Stack(
            children: [
              Positioned(
                top: 10,
                left: 12,
                right: 12,
                child: Text(
                  item.label,
                  style: kLabel15SB.copyWith(height: 1.2),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Positioned(
                right: 12,
                bottom: 10,
                width: 48,
                height: 48,
                child: SvgPicture.asset(
                  item.icon,
                  fit: BoxFit.contain,
                  alignment: Alignment.bottomRight,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActiveCampaignsSection extends ConsumerWidget {
  const _ActiveCampaignsSection();

  static const double _cardWidth = 200;
  static const double _cardHeight = 280;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final campaignsAsync = ref.watch(featuredCampaignsProvider);

    return SizedBox(
      height: _cardHeight,
      child: AsyncContent(
        asyncValue: campaignsAsync,
        onRetry: () => ref.invalidate(featuredCampaignsProvider),
        builder: (campaigns) {
          if (campaigns.isEmpty) {
            return Center(
              child: Text('No active campaigns', style: kEmptyStateM),
            );
          }
          return ListView.separated(
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
                  NavigationService().pushNamed(
                    'CampaignDetails',
                    arguments: {'campaignId': campaigns[index].id},
                  );
                },
              );
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
  final CampaignModel campaign;
  final VoidCallback onTap;

  const _CampaignCard({
    required this.width,
    required this.height,
    required this.campaign,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final progress = campaign.targetAmount <= 0
        ? 0.0
        : (campaign.collectedAmount / campaign.targetAmount).clamp(0.0, 1.0);
    final imageUrl = campaign.coverImage;

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
              if (imageUrl != null && imageUrl.startsWith('http'))
                Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Image.asset(
                    'assets/jpgs/campaign_education.jpg',
                    fit: BoxFit.cover,
                  ),
                )
              else
                Image.asset(
                  imageUrl ?? 'assets/jpgs/campaign_education.jpg',
                  fit: BoxFit.cover,
                ),
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
                    CategoryMapper.toUi(campaign.category),
                    style: kCaption10M.copyWith(color: kTextColor),
                  ),
                ),
              ),
              Positioned(
                left: 12,
                right: 12,
                bottom: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      campaign.title,
                      style: kBodyTitleSB.copyWith(color: kWhite, height: 1.25),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: LinearProgressIndicator(
                        value: progress.toDouble(),
                        minHeight: 3.5,
                        backgroundColor: kWhite.withValues(alpha: 0.3),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          kSecondaryColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${formatRupee(campaign.collectedAmount)} of ${formatRupee(campaign.targetAmount)}',
                      style: kCaption10M.copyWith(color: kWhite),
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

class _WelfareGridSection extends StatelessWidget {
  const _WelfareGridSection();

  // Figma Frame 39 / 2248:726 — card sizes at design width 113
  static const double _figmaCol = 113;
  static const double _figmaGap = 16;
  static const double _figmaMidOffset = 31;

  static const List<_WelfareCardData> _col1 = [
    _WelfareCardData(
      key: 'maktab',
      title: 'Maktab',
      imagePath: 'assets/pngs/maktab.png',
      bgColor: Color(0xFFFFFBEB),
      height: 128,
      imageRect: Rect.fromLTWH(8.08, 47.24, 97.08, 114.56),
    ),
    _WelfareCardData(
      key: 'ulama',
      title: 'Ulama',
      imagePath: 'assets/pngs/ulama.png',
      bgColor: Color(0xFFFFF1F2),
      height: 100,
      imageRect: Rect.fromLTWH(16, 32.72, 81.83, 96.56),
    ),
  ];

  static const List<_WelfareCardData> _col2 = [
    _WelfareCardData(
      key: 'youth_club',
      title: 'Youth Club',
      imagePath: 'assets/pngs/youth_club.png',
      bgColor: Color(0xFFF0FDF4),
      height: 135,
      imageRect: Rect.fromLTWH(1.08, 33.42, 110.34, 130.20),
    ),
    _WelfareCardData(
      key: 'model_village',
      title: 'Model Village',
      imagePath: 'assets/pngs/model_village.png',
      bgColor: Color(0xFFEFF6FF),
      height: 155,
      imageRect: Rect.fromLTWH(0.08, 55, 112.88, 133.20),
    ),
  ];

  static const List<_WelfareCardData> _col3 = [
    _WelfareCardData(
      key: 'study_center',
      title: 'Study Centre',
      imagePath: 'assets/pngs/study_center.png',
      bgColor: Color(0xFFFDF4FF),
      height: 100,
      imageRect: Rect.fromLTWH(6.08, 11, 100, 118),
    ),
    _WelfareCardData(
      key: 'jem',
      title: 'JEM',
      imagePath: 'assets/pngs/jem.png',
      bgColor: Color(0xFFF5EBE6),
      height: 128,
      imageRect: Rect.fromLTWH(-3.92, 28, 121.19, 143),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: kScreenPaddingH),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Explore our Social & Welfare Services.',
            textAlign: TextAlign.center,
            style: kSectionTitleSB.copyWith(height: 1.2),
          ),
          const SizedBox(height: 8),
          Text(
            'Dedicated programs focused on supporting and empowering our community.',
            textAlign: TextAlign.center,
            style: kCaption12R.copyWith(color: kMutedText, height: 1.35),
          ),
          const SizedBox(height: 16),
          Center(
            child: GestureDetector(
              onTap: () {
                HapticHelper.impact(HapticImpact.light);
                NavigationService().pushNamed('WelfareProgram');
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: kPrimaryColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Explore All',
                  style: kCaption12M.copyWith(color: kWhite, height: 1.2),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          LayoutBuilder(
            builder: (context, constraints) {
              final colWidth =
                  (constraints.maxWidth - _figmaGap * 2) / 3;
              final scale = colWidth / _figmaCol;
              final midOffset = _figmaMidOffset * scale;
              final gap = _figmaGap * scale;

              Widget buildCol(List<_WelfareCardData> items) {
                return Column(
                  children: [
                    for (var i = 0; i < items.length; i++) ...[
                      if (i > 0) SizedBox(height: gap),
                      _WelfareServiceCard(
                        data: items[i],
                        width: colWidth,
                        scale: scale,
                      ),
                    ],
                  ],
                );
              }

              return Padding(
                padding: EdgeInsets.only(bottom: 40 * scale),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: colWidth,
                      child: Padding(
                        padding: EdgeInsets.only(top: midOffset),
                        child: buildCol(_col1),
                      ),
                    ),
                    SizedBox(width: gap),
                    SizedBox(
                      width: colWidth,
                      child: buildCol(_col2),
                    ),
                    SizedBox(width: gap),
                    SizedBox(
                      width: colWidth,
                      child: Padding(
                        padding: EdgeInsets.only(top: midOffset),
                        child: buildCol(_col3),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _WelfareCardData {
  final String key;
  final String title;
  final String imagePath;
  final Color bgColor;
  final double height;
  final Rect imageRect;

  const _WelfareCardData({
    required this.key,
    required this.title,
    required this.imagePath,
    required this.bgColor,
    required this.height,
    required this.imageRect,
  });
}

class _WelfareServiceCard extends StatelessWidget {
  final _WelfareCardData data;
  final double width;
  final double scale;

  const _WelfareServiceCard({
    required this.data,
    required this.width,
    required this.scale,
  });

  @override
  Widget build(BuildContext context) {
    final height = data.height * scale;
    final imageRect = Rect.fromLTWH(
      data.imageRect.left * scale,
      data.imageRect.top * scale,
      data.imageRect.width * scale,
      data.imageRect.height * scale,
    );

    return GestureDetector(
      onTap: () {
        HapticHelper.impact(HapticImpact.light);
        NavigationService().pushNamed(
          'WelfareDetails',
          arguments: {'serviceId': data.key},
        );
      },
      child: SizedBox(
        width: width,
        height: height,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: data.bgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            Positioned(
              top: 10 * scale,
              left: 4,
              right: 4,
              child: Text(
                data.title,
                textAlign: TextAlign.center,
                style: kCaption12SB.copyWith(
                  color: kTextColor,
                  height: 1.2,
                  fontSize: 12 * scale.clamp(0.9, 1.15),
                ),
              ),
            ),
            Positioned(
              left: imageRect.left,
              top: imageRect.top,
              width: imageRect.width,
              height: imageRect.height,
              child: Image.asset(
                data.imagePath,
                fit: BoxFit.contain,
              ),
            ),
          ],
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
      borderRadius: BorderRadius.circular(22),
      elevation: 4,
      shadowColor: kBlack.withValues(alpha: 0.18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Contribute',
                style: kCaption12M.copyWith(
                  color: const Color(0xFF78350F),
                  height: 1.2,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.volunteer_activism,
                size: 20,
                color: Color(0xFF78350F),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
