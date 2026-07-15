import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jamiat/src/data/constants/color_constants.dart';
import 'package:jamiat/src/data/constants/style_constants.dart';
import 'package:jamiat/src/data/services/haptic_helper.dart';
import 'package:jamiat/src/data/services/navigation_services.dart';

class DonationSheet extends StatefulWidget {
  final String categoryTitle;
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;
  final bool isAutopay;

  const DonationSheet({
    super.key,
    required this.categoryTitle,
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
    this.isAutopay = false,
  });

  static Future<void> show({
    required BuildContext context,
    required String categoryTitle,
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    bool isAutopay = false,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DonationSheet(
        categoryTitle: categoryTitle,
        icon: icon,
        iconBgColor: iconBgColor,
        iconColor: iconColor,
        isAutopay: isAutopay,
      ),
    );
  }

  @override
  State<DonationSheet> createState() => _DonationSheetState();
}

class _DonationSheetState extends State<DonationSheet> {
  final List<int> _presetAmounts = [100, 250, 500, 1000, 2500, 5000];
  final _amountController = TextEditingController();
  final _messageController = TextEditingController();
  int? _selectedPresetIndex;
  bool _isProcessing = false;

  @override
  void dispose() {
    _amountController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _onPresetSelected(int index, int amount) {
    HapticHelper.impact(HapticImpact.light);
    setState(() {
      _selectedPresetIndex = index;
      _amountController.text = amount.toString();
    });
  }

  void _onCustomAmountChanged(String val) {
    final parsed = int.tryParse(val.trim());
    setState(() {
      if (parsed != null && _presetAmounts.contains(parsed)) {
        _selectedPresetIndex = _presetAmounts.indexOf(parsed);
      } else {
        _selectedPresetIndex = null;
      }
    });
  }

  bool get _hasValidAmount {
    final amount = int.tryParse(_amountController.text.trim());
    return amount != null && amount > 0;
  }

  Future<void> _handlePayment() async {
    if (!_hasValidAmount) return;

    HapticHelper.impact(HapticImpact.medium);
    setState(() {
      _isProcessing = true;
    });

    // Simulate payment process delay for premium experience
    await Future.delayed(const Duration(milliseconds: 1500));

    if (!mounted) return;

    setState(() {
      _isProcessing = false;
    });

    final finalAmount = _amountController.text.trim();
    final message = _messageController.text.trim();

    Navigator.of(context).pop();

    NavigationService().pushNamed(
      'DonationSuccess',
      arguments: {
        'isAutopay': widget.isAutopay,
        'amount': finalAmount,
        'message': message.isEmpty ? null : message,
        'campaignName': widget.categoryTitle,
        'date':
            '${DateTime.now().day.toString().padLeft(2, '0')}/${DateTime.now().month.toString().padLeft(2, '0')}/${DateTime.now().year}',
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        decoration: const BoxDecoration(
          color: kWhite,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Drag Handle
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: kBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Header (Icon & Title)
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: widget.iconBgColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Icon(widget.icon, color: widget.iconColor, size: 24),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    widget.categoryTitle,
                    style: kStyle(kSemiBold, 20, color: kTextColor),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            const Divider(color: kLineGrey, height: 1),
            const SizedBox(height: 20),

            // Select Amount Title
            Text(
              'Select amount',
              style: kStyle(kSemiBold, 16, color: kTextColor),
            ),
            const SizedBox(height: 16),

            // Preset Amount Grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _presetAmounts.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 16,
                childAspectRatio: 2.1,
              ),
              itemBuilder: (context, index) {
                final amount = _presetAmounts[index];
                final isSelected = _selectedPresetIndex == index;
                final isPopular = amount == 500;

                final chipWidget = Container(
                  decoration: BoxDecoration(
                    color: isSelected ? kLightGreen : kChipGreyBg,
                    border: Border.all(
                      color: isSelected ? kPrimaryColor : Colors.transparent,
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: InkWell(
                    onTap: () => _onPresetSelected(index, amount),
                    borderRadius: BorderRadius.circular(14),
                    child: Center(
                      child: Text(
                        '₹$amount',
                        style: kStyle(
                          isSelected ? kSemiBold : kMedium,
                          16,
                          color: isSelected ? kPrimaryColor : kTextColor,
                        ),
                      ),
                    ),
                  ),
                );

                if (isPopular) {
                  return Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned.fill(child: chipWidget),
                      Positioned(
                        top: -8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: kSecondaryColor,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Popular',
                            style: kStyle(kBold, 8, color: kWhite),
                          ),
                        ),
                      ),
                    ],
                  );
                }

                return chipWidget;
              },
            ),
            const SizedBox(height: 20),

            // Custom Amount Label
            Text(
              'or enter custom amount',
              style: kCaption13R.copyWith(color: kMutedText),
            ),
            const SizedBox(height: 8),

            // Custom Amount Text Field
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: _onCustomAmountChanged,
              style: kStyle(kMedium, 16, color: kTextColor),
              decoration: InputDecoration(
                prefixIcon: const Padding(
                  padding: EdgeInsets.only(left: 16, right: 8, top: 12),
                  child: Text(
                    '₹',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: kMedium,
                      color: kTextColor,
                    ),
                  ),
                ),
                prefixIconConstraints: const BoxConstraints(
                  minWidth: 0,
                  minHeight: 0,
                ),
                hintText: 'Enter amount',
                hintStyle: kStyle(kRegular, 16, color: kSecondaryTextColor),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 16,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: kBorder, width: 1),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: kBorder, width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(
                    color: kPrimaryColor,
                    width: 1.5,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Add a message section
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Add a message ',
                  style: kStyle(kSemiBold, 16, color: kTextColor),
                ),
                Text(
                  '(optional)',
                  style: kStyle(kRegular, 14, color: kSecondaryTextColor),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _messageController,
              maxLines: 3,
              minLines: 3,
              style: kStyle(kMedium, 16, color: kTextColor),
              decoration: InputDecoration(
                hintText: 'Enter message',
                hintStyle: kStyle(kRegular, 16, color: kSecondaryTextColor),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: kBorder, width: 1),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: kBorder, width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(
                    color: kPrimaryColor,
                    width: 1.5,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Continue to payment Button
            ElevatedButton(
              onPressed: (_hasValidAmount && !_isProcessing)
                  ? _handlePayment
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryColor,
                disabledBackgroundColor: kChipGreyBg,
                foregroundColor: kWhite,
                disabledForegroundColor: kMutedText,
                minimumSize: const Size.fromHeight(52),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: _isProcessing
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(kWhite),
                        strokeWidth: 2.5,
                      ),
                    )
                  : Text(
                      'Continue to payment',
                      style: kStyle(
                        kSemiBold,
                        16,
                        color: _hasValidAmount ? kWhite : kMutedText,
                      ),
                    ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
