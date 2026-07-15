import 'package:flutter/material.dart';
import 'package:jamiat/src/data/constants/color_constants.dart';
import 'package:jamiat/src/data/constants/style_constants.dart';
import 'package:jamiat/src/data/services/haptic_helper.dart';

class DonationHistoryScreen extends StatelessWidget {
  const DonationHistoryScreen({super.key});

  Widget _buildStatCard(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: kCaption14M.copyWith(color: kMutedText, fontSize: 13),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: kHeadTitleB.copyWith(color: kPrimaryColor, fontSize: 22),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard({
    required String title,
    required String transactionId,
    required String amount,
    required String dateTime,
    required String imagePath,
    bool isAutopay = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left Cover Image
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              imagePath,
              width: 64,
              height: 64,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 64,
                  height: 64,
                  color: kScreenBg,
                  child: const Icon(
                    Icons.image_outlined,
                    color: kMutedText,
                    size: 24,
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 14),
          // Middle Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Transaction ID Badge Capsule
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEEEEE),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    transactionId,
                    style: kStyle(kMedium, 10, color: kSecondaryTextColor),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: kBodyTitleB.copyWith(color: kTextColor, fontSize: 15),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  dateTime,
                  style: kCaption12R.copyWith(color: kSecondaryTextColor),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Right Price & Optional Tag
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                amount,
                style: kBodyTitleB.copyWith(color: kTextColor, fontSize: 16),
              ),
              if (isAutopay) ...[
                const SizedBox(height: 4),
                Text('Autopay', style: kStyle(kBold, 11, color: kPrimaryColor)),
              ],
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kWhite,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back Button
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
                  Text(
                    'My Donations',
                    style: kHeadTitleB.copyWith(
                      color: kTextColor,
                      fontSize: 20,
                    ),
                  ),
                  // Download Button
                  GestureDetector(
                    onTap: () {
                      HapticHelper.impact(HapticImpact.medium);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Downloading donation statement receipt...',
                            style: kCaption14M.copyWith(color: kWhite),
                          ),
                          backgroundColor: kPrimaryColor,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      );
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
                        Icons.download_outlined,
                        color: kTextColor,
                        size: 22,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Stats Row
              Row(
                children: [
                  Expanded(child: _buildStatCard('Total Donated', '₹ 8,000')),
                  const SizedBox(width: 14),
                  Expanded(child: _buildStatCard('Campaigns', '6')),
                ],
              ),
              const SizedBox(height: 32),

              // Group Today
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Today',
                    style: kBodyTitleB.copyWith(
                      color: kTextColor,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    '₹ 1250',
                    style: kCaption14R.copyWith(color: kTextColor),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildHistoryCard(
                title: 'Maktab support fund 2026',
                transactionId: 'TR12451BHGF',
                amount: '₹ 500',
                dateTime: '07 Jun, 2026 • 10:45 am',
                imagePath: 'assets/jpgs/campaign_education.jpg',
              ),
              _buildHistoryCard(
                title: 'Medical Aid for Patient',
                transactionId: 'TR12451BHGF',
                amount: '₹ 750',
                dateTime: '07 Jun, 2026 • 10:45 am',
                imagePath: 'assets/jpgs/campaign_welfare.jpg',
              ),
              const SizedBox(height: 24),

              // Group May 26
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'May 26',
                    style: kBodyTitleB.copyWith(
                      color: kTextColor,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    '₹ 1000',
                    style: kCaption14R.copyWith(color: kTextColor),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildHistoryCard(
                title: 'Maktab support fund 2026',
                transactionId: 'TR12451BHGF',
                amount: '₹ 500',
                dateTime: '07 Jun, 2026 • 10:45 am',
                imagePath: 'assets/jpgs/campaign_education.jpg',
              ),
              _buildHistoryCard(
                title: 'Orphan',
                transactionId: 'TR12451BHGF',
                amount: '₹ 500',
                dateTime: '01 Jun, 2026 • 10:45 am',
                imagePath: 'assets/jpgs/campaign_welfare.jpg',
                isAutopay: true,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
