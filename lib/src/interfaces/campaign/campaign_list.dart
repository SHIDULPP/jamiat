import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:jamiat/src/data/apis/user_api.dart';
import 'package:jamiat/src/data/constants/color_constants.dart';
import 'package:jamiat/src/data/constants/style_constants.dart';
import 'package:jamiat/src/data/router/nav_router.dart';
import 'package:jamiat/src/data/services/haptic_helper.dart';
import 'package:jamiat/src/data/services/navigation_services.dart';

class _DonationCategory {
  final String title;
  final String description;
  final String iconAsset;
  final Color iconBgColor;
  final IconData fallbackIcon;

  const _DonationCategory({
    required this.title,
    required this.description,
    required this.iconAsset,
    required this.iconBgColor,
    required this.fallbackIcon,
  });
}

class DonationListScreen extends ConsumerStatefulWidget {
  const DonationListScreen({super.key});

  @override
  ConsumerState<DonationListScreen> createState() =>
      _DonationListScreenState();
}

class _DonationListScreenState extends ConsumerState<DonationListScreen> {
  static const _jamiatOnlyCategories = {'Zakat', 'Building Mosque'};

  late TextEditingController _searchController;

  final List<_DonationCategory> _categories = const [
    _DonationCategory(
      title: 'General Campaign',
      description:
          'All active fundraisers, including specific, targeted campaigns.',
      iconAsset: 'assets/svg/generalcampaign.svg',
      iconBgColor: Color(0xFFFFF7ED),
      fallbackIcon: Icons.volunteer_activism_outlined,
    ),
    _DonationCategory(
      title: 'General Funding',
      description: 'Empower our ongoing community projects.',
      iconAsset: 'assets/svg/generalfunding.svg',
      iconBgColor: Color(0xFFFEF2F2),
      fallbackIcon: Icons.savings_outlined,
    ),
    _DonationCategory(
      title: 'Zakat',
      description: 'Fulfill your obligatory charity safely and securely.',
      iconAsset: 'assets/svg/zakat.svg',
      iconBgColor: Color(0xFFF0FDF4),
      fallbackIcon: Icons.payments_outlined,
    ),
    _DonationCategory(
      title: 'Orphan',
      description: 'Provide daily essentials and learning for children.',
      iconAsset: 'assets/svg/orphan.svg',
      iconBgColor: Color(0xFFFDF4FF),
      fallbackIcon: Icons.favorite_border_outlined,
    ),
    _DonationCategory(
      title: 'Building Mosque',
      description: 'Contribute to building and maintaining holy spaces.',
      iconAsset: 'assets/svg/buildingmosque.svg',
      iconBgColor: Color(0xFFEFF6FF),
      fallbackIcon: Icons.mosque,
    ),
    _DonationCategory(
      title: 'Medical Releif',
      description:
          'Support underprivileged families facing urgent health crises.',
      iconAsset: 'assets/svg/medicalreif.svg',
      iconBgColor: Color(0xFFFFF5EB),
      fallbackIcon: Icons.monitor_heart_outlined,
    ),
  ];

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

  List<_DonationCategory> _categoriesForRole(String role) {
    if (role == 'jamiat_member') return _categories;
    return _categories
        .where((category) => !_jamiatOnlyCategories.contains(category.title))
        .toList();
  }

  List<_DonationCategory> _getFilteredCategories(String role) {
    final categories = _categoriesForRole(role);
    final query = _searchController.text.toLowerCase().trim();
    if (query.isEmpty) return categories;
    return categories.where((item) {
      return item.title.toLowerCase().contains(query) ||
          item.description.toLowerCase().contains(query);
    }).toList();
  }

  void _viewActive() {
    HapticHelper.impact(HapticImpact.light);
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
    ref.read(selectedIndexProvider.notifier).updateIndex(1);
  }

  Widget _buildBackButton() {
    return GestureDetector(
      onTap: () {
        HapticHelper.impact(HapticImpact.light);
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }
      },
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: kWhite,
          border: Border.all(color: kBorder, width: 1.25),
        ),
        child: const Icon(Icons.arrow_back, color: kTextColor, size: 20),
      ),
    );
  }

  Widget _buildSearchField() {
    return Container(
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kBorder, width: 1),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          const Icon(Icons.search, color: kSecondaryTextColor, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _searchController,
              style: kBodyTitleR.copyWith(color: kTextColor),
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Search for services',
                hintStyle: kBodyTitleR.copyWith(color: kSecondaryTextColor),
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(_DonationCategory item) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticHelper.impact(HapticImpact.light);
          NavigationService().pushNamed(
            'CampaignDetails',
            arguments: {
              'title': item.title,
              'description': item.description,
              'icon': item.fallbackIcon,
              'iconBgColor': item.iconBgColor,
              'iconColor': kTextColor,
              'category': item.title,
            },
          );
        },
        borderRadius: BorderRadius.circular(kCardRadiusMd),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: kScreenBg,
            borderRadius: BorderRadius.circular(kCardRadiusMd),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: item.iconBgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: SvgPicture.asset(
                    item.iconAsset,
                    width: 32,
                    height: 32,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: kBodyTitleSB.copyWith(
                        color: kTextColor,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.description,
                      style: kCaption12R.copyWith(
                        color: kSecondaryTextColor,
                        height: 1.25,
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

  @override
  Widget build(BuildContext context) {
    final role = ref.watch(userProfileProvider).maybeWhen(
          data: (user) => user.role,
          orElse: () => 'normal_member',
        );
    final filteredCategories = _getFilteredCategories(role);

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
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildBackButton(),
                      GestureDetector(
                        onTap: _viewActive,
                        child: Text(
                          'View Active',
                          style: kCaption14M.copyWith(
                            color: kBlue,
                            fontWeight: kBold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'Donations',
                    style: kHeadTitleB.copyWith(
                      color: kTextColor,
                      fontSize: 22,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                kScreenPaddingH,
                20,
                kScreenPaddingH,
                0,
              ),
              child: _buildSearchField(),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(
                  kScreenPaddingH,
                  0,
                  kScreenPaddingH,
                  24,
                ),
                itemCount: filteredCategories.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  return _buildCategoryCard(filteredCategories[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
