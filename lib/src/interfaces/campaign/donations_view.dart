import 'package:flutter/material.dart';
import 'package:jamiat/src/data/constants/color_constants.dart';
import 'package:jamiat/src/data/constants/style_constants.dart';
import 'package:jamiat/src/data/services/haptic_helper.dart';
import 'package:jamiat/src/data/services/navigation_services.dart';
import 'package:jamiat/src/interfaces/campaign/campaign_details.dart';

class DonationsViewScreen extends StatefulWidget {
  const DonationsViewScreen({super.key});

  @override
  State<DonationsViewScreen> createState() => _DonationsViewScreenState();
}

class _DonationsViewScreenState extends State<DonationsViewScreen> {
  bool _isOngoing = false; // default is Past tab as in Figma mockup

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
                    'Donations',
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
                    ? Center(
                        child: Text(
                          'No ongoing donations',
                          style: kEmptyStateM,
                        ),
                      )
                    : SingleChildScrollView(
                        child: Column(
                          children: [
                            // Past Zakat Donation Card
                            GestureDetector(
                              onTap: () {
                                HapticHelper.impact(HapticImpact.light);
                                NavigationService().pushNamed(
                                  'AutopayDetails',
                                  arguments: {
                                    'title': 'Zakat',
                                    'description':
                                        'Fulfill your obligatory charity safely and securely.',
                                    'icon': Icons.payments_outlined,
                                    'iconBgColor': const Color(0xFFF0FDF4),
                                    'iconColor': const Color(0xFF16A34A),
                                    'status': 'Auto Pay Cancelled',
                                    'mandateAmount': '₹500',
                                    'period': 'Daily',
                                    'startDate': '28 Mar,2025',
                                    'endDate': '1 Apr,2026',
                                  },
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: kScreenBg,
                                  borderRadius: BorderRadius.circular(
                                    kCardRadiusLg,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        // Icon container showing the Zakat bag CustomPainter
                                        Container(
                                          width: 58,
                                          height: 58,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFF0FDF4),
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: Center(
                                            child: CustomPaint(
                                              size: const Size(36, 36),
                                              painter: ZakatBagPainter(),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        // Details text
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Zakat',
                                                style: kBodyTitleB.copyWith(
                                                  color: kTextColor,
                                                  fontSize: 16,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                'Fulfill your obligatory charity safely and securely.',
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
                                    const Padding(
                                      padding: EdgeInsets.symmetric(
                                        vertical: 12.0,
                                      ),
                                      child: Divider(color: kBorder, height: 1),
                                    ),
                                    Text(
                                      'Auto Pay Cancelled',
                                      style: kCaption14M.copyWith(
                                        color: kRed,
                                        fontWeight: kMedium,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
