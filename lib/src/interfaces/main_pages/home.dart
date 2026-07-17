import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:jamiat/src/data/constants/color_constants.dart';
import 'package:jamiat/src/data/constants/style_constants.dart';
import 'package:jamiat/src/data/models/campaign_model.dart';
import 'package:jamiat/src/data/providers/campaign_provider.dart';
import 'package:jamiat/src/data/providers/home_provider.dart';
import 'package:jamiat/src/data/providers/news_provider.dart';
import 'package:jamiat/src/data/services/haptic_helper.dart';
import 'package:jamiat/src/data/services/navigation_services.dart';
import 'package:jamiat/src/data/utils/category_mapper.dart';
import 'package:jamiat/src/data/utils/format_helpers.dart';
import 'package:jamiat/src/interfaces/components/async_content.dart';
import 'package:jamiat/src/interfaces/welfare_program/welfare_program.dart';

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
  _QuickAccessItem(label: 'Autopay', icon: '', background: Color(0xFFECFDF5)),
  _QuickAccessItem(
    label: 'Welfare',
    icon: 'assets/svg/quick_welfare.svg',
    background: Color(0xFFF3E8FF),
  ),
  _QuickAccessItem(
    label: 'Events',
    icon: 'assets/svg/quick_events.svg',
    background: Color(0xFFFFF7ED),
  ),
  _QuickAccessItem(
    label: 'Market',
    icon: 'assets/svg/quick_market.svg',
    background: Color(0xFFFCE7F3),
  ),
  _QuickAccessItem(label: 'News', icon: '', background: Color(0xFFF0FDF4)),
  _QuickAccessItem(label: 'Programs', icon: '', background: Color(0xFFF5EBE6)),
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

            // Redesigned: Marketplace Promo Card
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: kScreenPaddingH,
                  vertical: 20,
                ),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFFF9FAFB), Color(0xFFF3F4F6)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: kBorder),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Jamiat Market Place',
                              style: kBodyTitleB.copyWith(
                                color: kTextColor,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Discover exclusive deals & items',
                              style: kCaption12R.copyWith(color: kMutedText),
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton(
                              onPressed: () {
                                HapticHelper.impact(HapticImpact.light);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: kPrimaryColor,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                  vertical: 8,
                                ),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                'Explore',
                                style: kCaption12M.copyWith(
                                  color: kWhite,
                                  fontWeight: kBold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(
                        Icons.inventory_2_outlined,
                        size: 64,
                        color: kPrimaryColor.withValues(alpha: 0.15),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Redesigned: Welfare Grid Section
            const SliverToBoxAdapter(child: _WelfareGridSection()),

            // Redesigned: Medical Relief promo card
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: kScreenPaddingH,
                  vertical: 20,
                ),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7), // Yellow background
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFFDE68A)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: kWhite,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Medical Relief Fund',
                          style: kCaption10M.copyWith(
                            color: const Color(0xFFD97706),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Millions lack healthcare; fund life-saving medicine today.',
                        style: kBodyTitleB.copyWith(
                          color: const Color(0xFF78350F),
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 14),
                      ElevatedButton(
                        onPressed: () {
                          HapticHelper.impact(HapticImpact.light);
                          NavigationService().pushNamed('DonationList');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD97706),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Donate Now',
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

class _QuickAccessList extends StatelessWidget {
  const _QuickAccessList();

  static const double _cardWidth = 108;
  static const double _cardHeight = 132;

  @override
  Widget build(BuildContext context) {
    final items = _quickAccessItems;
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
                if (item.label == 'Events') {
                  NavigationService().pushNamed('Events');
                } else if (item.label == 'Welfare') {
                  NavigationService().pushNamed('WelfareProgram');
                } else if (item.label == 'Autopay') {
                  NavigationService().pushNamed('AutopayView');
                } else if (item.label == 'News') {
                  NavigationService().pushNamed('NewsList');
                } else if (item.label == 'Programs') {
                  NavigationService().pushNamed('EmpowermentPrograms');
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

  IconData _getIconForLabel(String label) {
    switch (label) {
      case 'Autopay':
        return Icons.touch_app_outlined;
      case 'News':
        return Icons.newspaper_outlined;
      case 'Programs':
        return Icons.shield_outlined;
      default:
        return Icons.sync_rounded;
    }
  }

  Color _getIconColorForLabel(String label) {
    switch (label) {
      case 'Autopay':
        return const Color(0xFF059669);
      case 'News':
        return const Color(0xFF16A34A);
      case 'Programs':
        return const Color(0xFF9A3412);
      default:
        return const Color(0xFF059669);
    }
  }

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
                  style: kCaption14B.copyWith(color: kTextColor),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const Spacer(),
                Center(
                  child: item.icon.isEmpty
                      ? Icon(
                          _getIconForLabel(item.label),
                          size: 40,
                          color: _getIconColorForLabel(item.label),
                        )
                      : SvgPicture.asset(
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

  static const List<Map<String, dynamic>> _welfareItems = [
    {
      'key': 'maktab',
      'title': 'Maktab',
      'bgColor': Color(0xFFFFFBEB),
      'painter': MaktabBookPainter(),
    },
    {
      'key': 'youth_club',
      'title': 'Youth Club',
      'bgColor': Color(0xFFF0FDF4),
      'painter': YouthClubFlagPainter(),
    },
    {
      'key': 'study_center',
      'title': 'Study Center',
      'bgColor': Color(0xFFFDF4FF),
      'painter': StudyCenterBooksPainter(),
    },
    {
      'key': 'ulama',
      'title': 'Ulama',
      'bgColor': Color(0xFFFFF1F2),
      'painter': UlamaTurbanPainter(),
    },
    {
      'key': 'model_village',
      'title': 'Model Village',
      'bgColor': Color(0xFFEFF6FF),
      'painter': ModelVillageHousesPainter(),
    },
    {
      'key': 'jem',
      'title': 'JEM',
      'bgColor': Color(0xFFF5EBE6),
      'painter': JemCourtPainter(),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: kScreenPaddingH),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Explore our Social & Welfare Services.',
                style: kSectionTitleSB.copyWith(fontSize: 16),
              ),
              const SizedBox(height: 4),
              Text(
                'Dedicated programs focused on supporting and empowering our community.',
                style: kCaption12R.copyWith(color: kMutedText),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {
                  HapticHelper.impact(HapticImpact.light);
                  NavigationService().pushNamed('WelfareProgram');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Explore All',
                  style: kCaption12M.copyWith(color: kWhite, fontWeight: kBold),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: kScreenPaddingH),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final cardWidth = (constraints.maxWidth - 24) / 3;
              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: _welfareItems.map((item) {
                  return GestureDetector(
                    onTap: () {
                      HapticHelper.impact(HapticImpact.light);
                      NavigationService().pushNamed(
                        'WelfareDetails',
                        arguments: {'serviceId': item['key']},
                      );
                    },
                    child: Container(
                      width: cardWidth,
                      height: 110,
                      decoration: BoxDecoration(
                        color: item['bgColor'] as Color,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: (item['bgColor'] as Color).withValues(
                            alpha: 0.15,
                          ),
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            item['title'] as String,
                            style: kCaption12R.copyWith(
                              color: kTextColor,
                              fontWeight: kBold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: 50,
                            height: 50,
                            child: CustomPaint(
                              painter: item['painter'] as CustomPainter,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ContributeButton extends StatelessWidget {
  final VoidCallback onTap;

  const _ContributeButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFFBBF24), // Yellow background matching mockup
      borderRadius: BorderRadius.circular(24),
      elevation: 4,
      shadowColor: kBlack.withValues(alpha: 0.18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Contribute',
                style: kCaption14B.copyWith(
                  color: const Color(0xFF78350F), // Dark brown/amber text
                  fontWeight: kBold,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.volunteer_activism,
                size: 18,
                color: Color(0xFF78350F),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
