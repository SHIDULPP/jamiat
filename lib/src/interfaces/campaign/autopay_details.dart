import 'package:flutter/material.dart';
import 'package:jamiat/src/data/constants/color_constants.dart';
import 'package:jamiat/src/data/constants/style_constants.dart';
import 'package:jamiat/src/data/services/haptic_helper.dart';
import 'package:jamiat/src/interfaces/campaign/campaign_details.dart';

class AutopayDetailsScreen extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;
  final String status;
  final String mandateAmount;
  final String period;
  final String startDate;
  final String endDate;
  final List<Map<String, String>>? history;

  const AutopayDetailsScreen({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
    this.status = 'Auto Pay Cancelled',
    this.mandateAmount = '₹500',
    this.period = 'Daily',
    this.startDate = '28 Mar,2025',
    this.endDate = '1 Apr,2026',
    this.history,
  });

  List<Map<String, String>> get _effectiveHistory {
    if (history != null && history!.isNotEmpty) return history!;
    // Default list matching Zakat mock history in Figma design
    return const [
      {'date': '1 Apr, 2026', 'amount': '₹ 500'},
      {'date': '31 Mar, 2026', 'amount': '₹ 500'},
      {'date': '30 Mar, 2026', 'amount': '₹ 500'},
      {'date': '29 Mar, 2026', 'amount': '₹ 500'},
    ];
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: kCaption14R.copyWith(color: kMutedText, fontSize: 14),
          ),
          Text(
            value,
            style: kBodyTitleSB.copyWith(color: kTextColor, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(String date, String amount) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Debited on',
                style: kCaption12R.copyWith(color: kSecondaryTextColor),
              ),
              const SizedBox(height: 4),
              Text(
                date,
                style: kBodyTitleSB.copyWith(color: kTextColor, fontSize: 15),
              ),
            ],
          ),
          Text(
            amount,
            style: kBodyTitleB.copyWith(color: kTextColor, fontSize: 16),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isCancelled = status.toLowerCase().contains('cancel');

    return Scaffold(
      backgroundColor: kWhite,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row (Back Button)
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
              const SizedBox(height: 24),

              // Category Summary Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: kScreenBg,
                  borderRadius: BorderRadius.circular(kCardRadiusLg),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Icon Box
                        Container(
                          width: 58,
                          height: 58,
                          decoration: BoxDecoration(
                            color: iconBgColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: title.toLowerCase() == 'zakat'
                                ? CustomPaint(
                                    size: const Size(36, 36),
                                    painter: ZakatBagPainter(),
                                  )
                                : Icon(icon, color: iconColor, size: 26),
                          ),
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
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12.0),
                      child: Divider(color: kBorder, height: 1),
                    ),
                    Text(
                      status,
                      style: kCaption14M.copyWith(
                        color: isCancelled ? kRed : kPrimaryColor,
                        fontWeight: kMedium,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Mandate Details Section
              Text(
                'Details',
                style: kBodyTitleB.copyWith(color: kTextColor, fontSize: 16),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: kWhite,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: kBorder),
                ),
                child: Column(
                  children: [
                    _buildDetailRow('Mandate Amount', mandateAmount),
                    _buildDetailRow('Period', period),
                    _buildDetailRow('Start Date', startDate),
                    _buildDetailRow('End date', endDate),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Transaction Debit History Section
              Text(
                'History',
                style: kBodyTitleB.copyWith(color: kTextColor, fontSize: 16),
              ),
              const SizedBox(height: 12),
              Column(
                children: _effectiveHistory.map((item) {
                  return _buildHistoryItem(
                    item['date'] ?? '',
                    item['amount'] ?? '',
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
