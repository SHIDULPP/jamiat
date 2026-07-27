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

  Widget _circleButton({required Widget child, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: kWhite,
          border: Border.all(color: kStrokeColor, width: 1.25),
        ),
        alignment: Alignment.center,
        child: child,
      ),
    );
  }

  Widget _buildRow(String label, String value, {bool isGreen = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: kCaption12R.copyWith(color: kMutedText),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: kCaption12SB.copyWith(
                color: isGreen ? kPrimaryColor : kTextColor,
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
    final displayAmount = amount.startsWith('₹') ? amount : '₹$amount';

    return Scaffold(
      backgroundColor: kWhite,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: kScreenPaddingH,
            vertical: 16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _circleButton(
                onTap: () {
                  HapticHelper.impact(HapticImpact.light);
                  Navigator.pop(context);
                },
                child: const Icon(
                  Icons.arrow_back,
                  color: kTextColor,
                  size: 20,
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 88,
                      height: 88,
                      decoration: const BoxDecoration(
                        color: kPrimaryColor,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.check_rounded,
                        color: kWhite,
                        size: 48,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text('Sucess', style: kSectionTitle19SB),
                    const SizedBox(height: 8),
                    Text(
                      'Thank you for Your generous Support!',
                      textAlign: TextAlign.center,
                      style: kCaption12R.copyWith(color: kSecondaryTextColor),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Text('Donation Receipt', style: kBodyTitleSB),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: kWhite,
                  borderRadius: BorderRadius.circular(kCardRadiusMd),
                  border: Border.all(color: kCardBorder),
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
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Divider(color: kLineGrey, height: 1),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Amount Paid', style: kBodyTitleSB),
                          Text(
                            displayAmount,
                            style: kBodyTitleSB.copyWith(color: kPrimaryColor),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              if (message != null && message!.isNotEmpty) ...[
                Text('Your Message', style: kBodyTitleSB),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: kWhite,
                    borderRadius: BorderRadius.circular(kCardRadiusMd),
                    border: Border.all(color: kCardBorder),
                  ),
                  child: Text(
                    message!,
                    style: kCaption14R.copyWith(
                      color: kTextColor,
                      height: 1.45,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ] else ...[
                const SizedBox(height: 16),
              ],
              SizedBox(
                height: 52,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    HapticHelper.impact(HapticImpact.medium);
                    NavigationService().pushNamedAndRemoveUntil('navBar');
                    if (isAutopay) {
                      NavigationService().pushNamed('AutopayView');
                    } else {
                      NavigationService().pushNamed('DonationsView');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryColor,
                    foregroundColor: kWhite,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(kCardRadiusSm),
                    ),
                  ),
                  child: Text('View my donations', style: kButtonLabelSB),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 52,
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    HapticHelper.impact(HapticImpact.light);
                    NavigationService().pushNamedAndRemoveUntil('navBar');
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: kTextColor,
                    side: const BorderSide(color: kStrokeColor, width: 1.25),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(kCardRadiusSm),
                    ),
                  ),
                  child: Text(
                    'Back to Home',
                    style: kButtonLabelSB.copyWith(color: kTextColor),
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
