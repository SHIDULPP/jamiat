import 'package:flutter/material.dart';
import 'package:jamiat/src/data/constants/color_constants.dart';
import 'package:jamiat/src/data/constants/style_constants.dart';
import 'package:jamiat/src/data/services/haptic_helper.dart';
import 'package:jamiat/src/data/services/navigation_services.dart';

class AutopayViewScreen extends StatefulWidget {
  const AutopayViewScreen({super.key});

  @override
  State<AutopayViewScreen> createState() => _AutopayViewScreenState();
}

class _AutopayViewScreenState extends State<AutopayViewScreen> {
  bool _isOngoing = true; // default is Ongoing tab as in Figma mockup

  Widget _buildTabButton(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? kSecondaryColor : kWhite,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: kSecondaryColor, width: 1.25),
        ),
        child: Text(
          label,
          style: kStyle(
            isSelected ? kBold : kMedium,
            14,
            color: isSelected ? kTextColor : kMutedText,
          ),
        ),
      ),
    );
  }

  Widget _buildCampaignCard({
    required String title,
    required String description,
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: kScreenBg,
          borderRadius: BorderRadius.circular(kCardRadiusLg),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Icon Box
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(child: Icon(icon, color: iconColor, size: 26)),
            ),
            const SizedBox(width: 16),
            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: kBodyTitleB.copyWith(
                      color: kTextColor,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kWhite,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
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
                  Text(
                    'Autopay',
                    style: kHeadTitleB.copyWith(
                      color: kTextColor,
                      fontSize: 22,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Segmented Tabs Toggle
              Row(
                children: [
                  _buildTabButton('Ongoing', _isOngoing, () {
                    HapticHelper.impact(HapticImpact.light);
                    setState(() => _isOngoing = true);
                  }),
                  const SizedBox(width: 12),
                  _buildTabButton('Past', !_isOngoing, () {
                    HapticHelper.impact(HapticImpact.light);
                    setState(() => _isOngoing = false);
                  }),
                ],
              ),
              const SizedBox(height: 24),

              // Tab contents
              Expanded(
                child: _isOngoing
                    ? ListView(
                        children: [
                          _buildCampaignCard(
                            title: 'Building Mosque',
                            description:
                                'Contribute to building and maintaining holy spaces.',
                            icon: Icons.mosque,
                            iconBg: const Color(0xFFEFF6FF),
                            iconColor: const Color(0xFF2563EB),
                            onTap: () {
                              HapticHelper.impact(HapticImpact.light);
                              NavigationService().pushNamed(
                                'AutopayDetails',
                                arguments: {
                                  'title': 'Building Mosque',
                                  'description':
                                      'Contribute to building and maintaining holy spaces.',
                                  'icon': Icons.mosque,
                                  'iconBgColor': const Color(0xFFEFF6FF),
                                  'iconColor': const Color(0xFF2563EB),
                                  'status': 'Auto Pay Active',
                                  'mandateAmount': '₹1,000',
                                  'period': 'Weekly',
                                  'startDate': '15 Jan,2025',
                                  'endDate': '15 Jan,2026',
                                  'history': [
                                    {
                                      'date': '8 Jul, 2026',
                                      'amount': '₹ 1,000',
                                    },
                                    {
                                      'date': '1 Jul, 2026',
                                      'amount': '₹ 1,000',
                                    },
                                    {
                                      'date': '24 Jun, 2026',
                                      'amount': '₹ 1,000',
                                    },
                                  ],
                                },
                              );
                            },
                          ),
                          const SizedBox(height: 16),
                          _buildCampaignCard(
                            title: 'Medical Releif',
                            description:
                                'Support underprivileged families facing urgent health crises.',
                            icon: Icons.monitor_heart_outlined,
                            iconBg: const Color(0xFFFFF5F5),
                            iconColor: const Color(0xFFEF4444),
                            onTap: () {
                              HapticHelper.impact(HapticImpact.light);
                              NavigationService().pushNamed(
                                'AutopayDetails',
                                arguments: {
                                  'title': 'Medical Releif',
                                  'description':
                                      'Support underprivileged families facing urgent health crises.',
                                  'icon': Icons.monitor_heart_outlined,
                                  'iconBgColor': const Color(0xFFFFF5F5),
                                  'iconColor': const Color(0xFFEF4444),
                                  'status': 'Auto Pay Active',
                                  'mandateAmount': '₹300',
                                  'period': 'Daily',
                                  'startDate': '1 Feb,2025',
                                  'endDate': '1 Feb,2026',
                                  'history': [
                                    {'date': '15 Jul, 2026', 'amount': '₹ 300'},
                                    {'date': '14 Jul, 2026', 'amount': '₹ 300'},
                                    {'date': '13 Jul, 2026', 'amount': '₹ 300'},
                                  ],
                                },
                              );
                            },
                          ),
                        ],
                      )
                    : Center(
                        child: Text('No past autopays', style: kEmptyStateM),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
