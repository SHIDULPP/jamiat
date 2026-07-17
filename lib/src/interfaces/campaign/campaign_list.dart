import 'package:flutter/material.dart';
import 'package:jamiat/src/data/constants/color_constants.dart';
import 'package:jamiat/src/data/constants/style_constants.dart';
import 'package:jamiat/src/data/services/haptic_helper.dart';
import 'package:jamiat/src/data/services/navigation_services.dart';

class _DonationCategory {
  final String title;
  final String description;
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;

  const _DonationCategory({
    required this.title,
    required this.description,
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
  });
}

class DonationListScreen extends StatefulWidget {
  const DonationListScreen({super.key});

  @override
  State<DonationListScreen> createState() => _DonationListScreenState();
}

class _DonationListScreenState extends State<DonationListScreen> {
  late TextEditingController _searchController;

  final List<_DonationCategory> _categories = const [
    _DonationCategory(
      title: 'General Campaign',
      description:
          'All active fundraisers, including specific, targeted campaigns.',
      icon: Icons.volunteer_activism_outlined,
      iconBgColor: Color(0xFFFFF7ED), // Soft orange/peach
      iconColor: Color(0xFFEA580C),
    ),
    _DonationCategory(
      title: 'General Funding',
      description: 'Empower our ongoing community projects.',
      icon: Icons.savings_outlined,
      iconBgColor: Color(0xFFFEF2F2), // Soft red/pink
      iconColor: Color(0xFFDC2626),
    ),
    _DonationCategory(
      title: 'Zakat',
      description: 'Fulfill your obligatory charity safely and securely.',
      icon: Icons.payments_outlined,
      iconBgColor: Color(0xFFF0FDF4), // Soft green
      iconColor: Color(0xFF16A34A),
    ),
    _DonationCategory(
      title: 'Orphan',
      description: 'Provide daily essentials and learning for children.',
      icon: Icons.favorite_border_outlined,
      iconBgColor: Color(0xFFFDF4FF), // Soft purple/pink
      iconColor: Color(0xFFC084FC),
    ),
    _DonationCategory(
      title: 'Building Mosque',
      description: 'Contribute to building and maintaining holy spaces.',
      icon: Icons.mosque,
      iconBgColor: Color(0xFFEFF6FF), // Soft blue
      iconColor: Color(0xFF2563EB),
    ),
    _DonationCategory(
      title: 'Medical Releif',
      description:
          'Support underprivileged families facing urgent health crises.',
      icon: Icons.monitor_heart_outlined,
      iconBgColor: Color(0xFFFFF5F5), // Soft red
      iconColor: Color(0xFFEF4444),
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

  List<_DonationCategory> _getFilteredCategories() {
    final query = _searchController.text.toLowerCase().trim();
    if (query.isEmpty) return _categories;
    return _categories.where((item) {
      return item.title.toLowerCase().contains(query) ||
          item.description.toLowerCase().contains(query);
    }).toList();
  }

  Widget _buildSearchField() {
    return Container(
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        style: kBodyTitleR.copyWith(color: kTextColor),
        onChanged: (val) {
          setState(() {});
        },
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.search, color: kSecondaryTextColor),
          hintText: 'Search for services',
          hintStyle: kBodyTitleR.copyWith(color: kSecondaryTextColor),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 18,
            horizontal: 16,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: kBorder, width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: kBorder, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: kPrimaryColor, width: 1.5),
          ),
        ),
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
              'icon': item.icon,
              'iconBgColor': item.iconBgColor,
              'iconColor': item.iconColor,
            },
          );
        },

        borderRadius: BorderRadius.circular(kCardRadiusLg),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: kScreenBg,
            borderRadius: BorderRadius.circular(kCardRadiusLg),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Icon Container
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: item.iconBgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Icon(item.icon, color: item.iconColor, size: 26),
                ),
              ),
              const SizedBox(width: 16),
              // Details
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
    final filteredCategories = _getFilteredCategories();

    return Scaffold(
      backgroundColor: kWhite,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
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
                          child: const Icon(
                            Icons.arrow_back,
                            color: kTextColor,
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        'Donations',
                        style: kHeadTitleB.copyWith(
                          color: kTextColor,
                          fontSize: 22,
                        ),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: () {
                      HapticHelper.impact(HapticImpact.light);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Viewing active campaigns...'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: kBlue,
                      textStyle: kCaption14M.copyWith(fontWeight: kBold),
                    ),
                    child: const Text('View Active'),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Search Bar
              _buildSearchField(),
              const SizedBox(height: 24),

              // Categories List
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filteredCategories.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  return _buildCategoryCard(filteredCategories[index]);
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
