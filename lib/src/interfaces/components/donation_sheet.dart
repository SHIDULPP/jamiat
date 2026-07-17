import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jamiat/src/data/apis/autopay_api.dart';
import 'package:jamiat/src/data/apis/donation_api.dart';
import 'package:jamiat/src/data/constants/color_constants.dart';
import 'package:jamiat/src/data/constants/style_constants.dart';
import 'package:jamiat/src/data/providers/autopay_provider.dart';
import 'package:jamiat/src/data/providers/campaign_provider.dart';
import 'package:jamiat/src/data/providers/donation_provider.dart';
import 'package:jamiat/src/data/services/haptic_helper.dart';
import 'package:jamiat/src/data/services/navigation_services.dart';
import 'package:jamiat/src/data/services/razorpay_service.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class DonationSheet extends ConsumerStatefulWidget {
  final String categoryTitle;
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;
  final bool isAutopay;
  final String? campaignId;

  const DonationSheet({
    super.key,
    required this.categoryTitle,
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
    this.isAutopay = false,
    this.campaignId,
  });

  static Future<void> show({
    required BuildContext context,
    required String categoryTitle,
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    bool isAutopay = false,
    String? campaignId,
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
        campaignId: campaignId,
      ),
    );
  }

  @override
  ConsumerState<DonationSheet> createState() => _DonationSheetState();
}

class _DonationSheetState extends ConsumerState<DonationSheet> {
  final List<int> _presetAmounts = [100, 250, 500, 1000, 2500, 5000];
  final List<String> _periods = ['daily', 'weekly', 'monthly', 'yearly'];
  final _amountController = TextEditingController();
  final _messageController = TextEditingController();
  int? _selectedPresetIndex;
  String _selectedPeriod = 'monthly';
  bool _isProcessing = false;
  RazorpayService? _razorpay;
  String? _pendingDonationId;
  String? _pendingAutopayId;
  String? _pendingSubscriptionId;

  @override
  void dispose() {
    _amountController.dispose();
    _messageController.dispose();
    _razorpay?.dispose();
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

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: kCaption14M.copyWith(color: kWhite)),
        backgroundColor: kRed,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _initRazorpay() {
    _razorpay?.dispose();
    _razorpay = RazorpayService();
    _razorpay!.init(onSuccess: _onPaymentSuccess, onError: _onPaymentError);
  }

  Future<void> _handlePayment() async {
    if (!_hasValidAmount) return;

    final campaignId = widget.campaignId;
    if (campaignId == null || campaignId.isEmpty) {
      _showError('Campaign is required to donate.');
      return;
    }

    HapticHelper.impact(HapticImpact.medium);
    setState(() => _isProcessing = true);

    final amount = num.parse(_amountController.text.trim());
    final message = _messageController.text.trim();

    try {
      if (widget.isAutopay) {
        await _startAutopay(
          campaignId: campaignId,
          amount: amount,
          message: message,
        );
      } else {
        await _startDonation(
          campaignId: campaignId,
          amount: amount,
          message: message,
        );
      }
    } catch (e) {
      if (mounted) setState(() => _isProcessing = false);
      _showError(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<void> _startDonation({
    required String campaignId,
    required num amount,
    required String message,
  }) async {
    final createResponse = await ref
        .read(donationApiProvider)
        .createDonation(
          campaignId: campaignId,
          amount: amount,
          message: message.isEmpty ? null : message,
        );

    if (!createResponse.success || createResponse.data == null) {
      if (mounted) setState(() => _isProcessing = false);
      _showError(createResponse.message ?? 'Failed to create donation');
      return;
    }

    final result = createResponse.data!;
    _pendingDonationId = result.donationId;
    _pendingAutopayId = null;
    _pendingSubscriptionId = null;

    _initRazorpay();
    _razorpay!.openCheckout(
      keyId: result.razorpayKeyId,
      orderId: result.razorpayOrderId,
      amount: result.amount,
      name: 'Jamiat',
      description: widget.categoryTitle,
    );
  }

  Future<void> _startAutopay({
    required String campaignId,
    required num amount,
    required String message,
  }) async {
    final createResponse = await ref
        .read(autopayApiProvider)
        .createAutopay(
          campaignId: campaignId,
          amount: amount,
          period: _selectedPeriod,
          message: message.isEmpty ? null : message,
        );

    if (!createResponse.success || createResponse.data == null) {
      if (mounted) setState(() => _isProcessing = false);
      _showError(createResponse.message ?? 'Failed to create autopay');
      return;
    }

    final result = createResponse.data!;
    _pendingAutopayId = result.autopayId;
    _pendingSubscriptionId = result.razorpaySubscriptionId;
    _pendingDonationId = null;

    _initRazorpay();
    _razorpay!.openSubscriptionCheckout(
      keyId: result.razorpayKeyId,
      subscriptionId: result.razorpaySubscriptionId,
      name: 'Jamiat',
      description: widget.categoryTitle,
    );
  }

  Future<void> _onPaymentSuccess(PaymentSuccessResponse response) async {
    try {
      if (_pendingAutopayId != null) {
        await _verifyAutopay(response);
      } else if (_pendingDonationId != null) {
        await _verifyDonation(response);
      } else if (mounted) {
        setState(() => _isProcessing = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isProcessing = false);
        _showError(e.toString().replaceFirst('Exception: ', ''));
      }
    }
  }

  Future<void> _verifyDonation(PaymentSuccessResponse response) async {
    final donationId = _pendingDonationId!;
    final verify = await ref
        .read(donationApiProvider)
        .verifyPayment(
          donationId: donationId,
          razorpayOrderId: response.orderId ?? '',
          razorpayPaymentId: response.paymentId ?? '',
          razorpaySignature: response.signature ?? '',
        );

    if (!mounted) return;
    setState(() => _isProcessing = false);

    if (!verify.success) {
      _showError(verify.message ?? 'Payment verification failed');
      return;
    }

    ref.invalidate(donationHistoryProvider);
    if (widget.campaignId != null) {
      ref.invalidate(campaignDetailProvider(widget.campaignId!));
      ref.invalidate(campaignListProvider(1));
      ref.invalidate(featuredCampaignsProvider);
      ref.invalidate(campaignMobileStatsProvider);
    }
    Navigator.of(context).pop();

    final now = DateTime.now();
    NavigationService().pushNamed(
      'DonationSuccess',
      arguments: {
        'isAutopay': false,
        'amount': _amountController.text.trim(),
        'message': _messageController.text.trim().isEmpty
            ? null
            : _messageController.text.trim(),
        'campaignName': widget.categoryTitle,
        'transactionId': response.paymentId ?? donationId,
        'date':
            '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}',
      },
    );
  }

  Future<void> _verifyAutopay(PaymentSuccessResponse response) async {
    final autopayId = _pendingAutopayId!;
    final subscriptionId = response.orderId ?? _pendingSubscriptionId ?? '';
    final verify = await ref
        .read(autopayApiProvider)
        .verifyAutopay(
          autopayId: autopayId,
          razorpaySubscriptionId: subscriptionId,
          razorpayPaymentId: response.paymentId ?? '',
          razorpaySignature: response.signature ?? '',
        );

    if (!mounted) return;
    setState(() => _isProcessing = false);

    if (!verify.success) {
      _showError(verify.message ?? 'Autopay verification failed');
      return;
    }

    ref.invalidate(myAutopaysProvider);
    Navigator.of(context).pop();

    final now = DateTime.now();
    NavigationService().pushNamed(
      'DonationSuccess',
      arguments: {
        'isAutopay': true,
        'amount': _amountController.text.trim(),
        'period': _selectedPeriod,
        'message': _messageController.text.trim().isEmpty
            ? null
            : _messageController.text.trim(),
        'campaignName': widget.categoryTitle,
        'transactionId': response.paymentId ?? autopayId,
        'date':
            '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}',
      },
    );
  }

  void _onPaymentError(PaymentFailureResponse response) {
    if (!mounted) return;
    setState(() => _isProcessing = false);
    _showError(response.message ?? 'Payment cancelled or failed');
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
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
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
                      child: Icon(
                        widget.icon,
                        color: widget.iconColor,
                        size: 24,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      widget.isAutopay
                          ? 'Set up Autopay'
                          : widget.categoryTitle,
                      style: kStyle(kSemiBold, 20, color: kTextColor),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(color: kLineGrey, height: 1),
              const SizedBox(height: 20),
              Text(
                'Select amount',
                style: kStyle(kSemiBold, 16, color: kTextColor),
              ),
              const SizedBox(height: 16),
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
              Text(
                'or enter custom amount',
                style: kCaption13R.copyWith(color: kMutedText),
              ),
              const SizedBox(height: 8),
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
              if (widget.isAutopay) ...[
                const SizedBox(height: 20),
                Text(
                  'Billing period',
                  style: kStyle(kSemiBold, 16, color: kTextColor),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _periods.map((period) {
                    final selected = _selectedPeriod == period;
                    return ChoiceChip(
                      label: Text(
                        period[0].toUpperCase() + period.substring(1),
                      ),
                      selected: selected,
                      onSelected: (_) {
                        HapticHelper.impact(HapticImpact.light);
                        setState(() => _selectedPeriod = period);
                      },
                      selectedColor: kLightGreen,
                      labelStyle: kCaption12M.copyWith(
                        color: selected ? kPrimaryColor : kTextColor,
                      ),
                      side: BorderSide(
                        color: selected ? kPrimaryColor : kBorder,
                      ),
                    );
                  }).toList(),
                ),
              ],
              const SizedBox(height: 20),
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
                        widget.isAutopay
                            ? 'Continue to Autopay'
                            : 'Continue to payment',
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
      ),
    );
  }
}
