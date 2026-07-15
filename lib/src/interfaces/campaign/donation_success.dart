import 'package:flutter/material.dart';
import 'package:jamiat/src/data/constants/color_constants.dart';
import 'package:jamiat/src/data/constants/style_constants.dart';
import 'package:jamiat/src/data/services/haptic_helper.dart';
import 'package:jamiat/src/data/services/navigation_services.dart';

class DonationSuccessScreen extends StatelessWidget {
  final bool isAutopay;
  final String amount;
  final String period;
  final String transactionId;
  final String date;
  final String campaignName;
  final String? message;

  const DonationSuccessScreen({
    super.key,
    required this.isAutopay,
    required this.amount,
    this.period = 'Daily',
    this.transactionId = 'TR12451BHGF',
    this.date = '20/06/2026',
    this.campaignName = 'Medical aid for patient',
    this.message,
  });

  Widget _buildRow(String label, String value, {bool isGreen = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: kCaption14R.copyWith(color: kMutedText, fontSize: 14),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: kBodyTitleSB.copyWith(
                color: isGreen ? kPrimaryColor : kTextColor,
                fontSize: 14,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Format currency display
    final displayAmount = amount.startsWith('₹') ? amount : '₹$amount';

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
              const SizedBox(height: 16),

              // Success Banner / Checkmark Section
              Center(
                child: Column(
                  children: [
                    // Green Checkmark Double Shade Circle
                    Container(
                      width: 90,
                      height: 90,
                      decoration: const BoxDecoration(
                        color: kPrimaryColor,
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [Color(0xFF00C853), Color(0xFF00A54F)],
                          center: Alignment.center,
                          radius: 0.85,
                        ),
                      ),
                      child: const Icon(Icons.check, color: kWhite, size: 48),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Sucess',
                      style: kHeadTitleB.copyWith(
                        color: kTextColor,
                        fontSize: 22,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Thank you for Your generous Support!',
                      style: kCaption14M.copyWith(color: kSecondaryTextColor),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Donation Receipt Section
              Text(
                'Donation Receipt',
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
                    if (isAutopay) ...[
                      _buildRow('Amount', displayAmount),
                      _buildRow('Period', period),
                      _buildRow('Transaction ID', transactionId),
                    ] else ...[
                      _buildRow('Date', date),
                      _buildRow('Campaign', campaignName),
                    ],
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: Divider(color: kLineGrey, height: 1),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Amount Paid',
                            style: kBodyTitleSB.copyWith(
                              color: kTextColor,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            displayAmount,
                            style: kBodyTitleB.copyWith(
                              color: kPrimaryColor,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Your Message Section (only if not empty)
              if (message != null && message!.isNotEmpty) ...[
                Text(
                  'Your Message',
                  style: kBodyTitleB.copyWith(color: kTextColor, fontSize: 16),
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: kWhite,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: kBorder),
                  ),
                  child: Text(
                    message!,
                    style: kBodyTitleR.copyWith(
                      color: kTextColor,
                      fontSize: 14,
                      height: 1.45,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ] else ...[
                const SizedBox(height: 16),
              ],

              // CTA Buttons at the bottom
              ElevatedButton(
                onPressed: () {
                  HapticHelper.impact(HapticImpact.medium);
                  NavigationService().pushNamedAndRemoveUntil('navBar');
                  NavigationService().pushNamed('DonationList');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryColor,
                  foregroundColor: kWhite,
                  minimumSize: const Size.fromHeight(54),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  'View my donations',
                  style: kButtonLabelSB.copyWith(fontSize: 16),
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () {
                  HapticHelper.impact(HapticImpact.light);
                  NavigationService().pushNamedAndRemoveUntil('navBar');
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: kTextColor,
                  side: const BorderSide(color: kBorder, width: 1.25),
                  minimumSize: const Size.fromHeight(54),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  'Back to Home',
                  style: kButtonLabelSB.copyWith(
                    color: kTextColor,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
