import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jamiat/src/data/apis/autopay_api.dart';
import 'package:jamiat/src/data/constants/color_constants.dart';
import 'package:jamiat/src/data/constants/style_constants.dart';
import 'package:jamiat/src/data/models/autopay_model.dart';
import 'package:jamiat/src/data/providers/autopay_provider.dart';
import 'package:jamiat/src/data/services/haptic_helper.dart';
import 'package:jamiat/src/data/utils/format_helpers.dart';
import 'package:jamiat/src/interfaces/campaign/campaign_details.dart';
import 'package:jamiat/src/interfaces/components/async_content.dart';

class AutopayDetailsScreen extends ConsumerStatefulWidget {
  final String? autopayId;
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
    this.autopayId,
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

  @override
  ConsumerState<AutopayDetailsScreen> createState() =>
      _AutopayDetailsScreenState();
}

class _AutopayDetailsScreenState extends ConsumerState<AutopayDetailsScreen> {
  String? _actionLoading;

  Future<void> _runAction(
    String action,
    Future<dynamic> Function() call,
  ) async {
    if (_actionLoading != null) return;
    setState(() => _actionLoading = action);
    try {
      final res = await call();
      if (!mounted) return;
      if (res.success != true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res.message?.toString() ?? 'Action failed')),
        );
        return;
      }
      if (widget.autopayId != null) {
        ref.invalidate(autopayDetailProvider(widget.autopayId!));
        ref.invalidate(autopayHistoryProvider(widget.autopayId!));
      }
      ref.invalidate(myAutopaysProvider);
      final label = switch (action) {
        'pause' => 'paused',
        'resume' => 'resumed',
        'cancel' => 'cancelled',
        _ => action,
      };
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Autopay $label successfully')));
    } finally {
      if (mounted) setState(() => _actionLoading = null);
    }
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

  Widget _actionButtons(AutopayModel autopay) {
    final status = autopay.status.toLowerCase();
    final canPause = status == 'active';
    final canResume = status == 'paused';
    final canCancel = status == 'active' || status == 'paused';

    if (!canPause && !canResume && !canCancel) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        if (canPause)
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: _actionLoading != null
                  ? null
                  : () {
                      HapticHelper.impact(HapticImpact.medium);
                      _runAction(
                        'pause',
                        () => ref
                            .read(autopayApiProvider)
                            .pauseAutopay(autopay.id),
                      );
                    },
              child: Text(
                _actionLoading == 'pause' ? 'Pausing…' : 'Pause Autopay',
              ),
            ),
          ),
        if (canResume)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _actionLoading != null
                  ? null
                  : () {
                      HapticHelper.impact(HapticImpact.medium);
                      _runAction(
                        'resume',
                        () => ref
                            .read(autopayApiProvider)
                            .resumeAutopay(autopay.id),
                      );
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryColor,
                foregroundColor: kWhite,
              ),
              child: Text(
                _actionLoading == 'resume' ? 'Resuming…' : 'Resume Autopay',
              ),
            ),
          ),
        if (canCancel) ...[
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: _actionLoading != null
                  ? null
                  : () async {
                      HapticHelper.impact(HapticImpact.medium);
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Cancel Autopay?'),
                          content: const Text(
                            'This will stop future automatic donations for this campaign.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: const Text('Keep'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              child: const Text('Cancel Autopay'),
                            ),
                          ],
                        ),
                      );
                      if (confirm == true) {
                        _runAction(
                          'cancel',
                          () => ref
                              .read(autopayApiProvider)
                              .cancelAutopay(autopay.id),
                        );
                      }
                    },
              child: Text(
                _actionLoading == 'cancel' ? 'Cancelling…' : 'Cancel Autopay',
                style: kCaption14M.copyWith(color: kRed),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _body({
    required String title,
    required String description,
    required String status,
    required String mandateAmount,
    required String period,
    required String startDate,
    required String endDate,
    required List<Map<String, String>> history,
    AutopayModel? autopay,
  }) {
    final isCancelled = status.toLowerCase().contains('cancel');

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
              child: const Icon(Icons.arrow_back, color: kTextColor, size: 20),
            ),
          ),
          const SizedBox(height: 24),
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
                    Container(
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        color: widget.iconBgColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: title.toLowerCase() == 'zakat'
                            ? CustomPaint(
                                size: const Size(36, 36),
                                painter: ZakatBagPainter(),
                              )
                            : Icon(
                                widget.icon,
                                color: widget.iconColor,
                                size: 26,
                              ),
                      ),
                    ),
                    const SizedBox(width: 16),
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
          Text(
            'Details',
            style: kBodyTitleB.copyWith(color: kTextColor, fontSize: 16),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                _buildDetailRow('Next payment', endDate),
              ],
            ),
          ),
          if (autopay != null) ...[
            const SizedBox(height: 24),
            _actionButtons(autopay),
          ],
          const SizedBox(height: 32),
          Text(
            'History',
            style: kBodyTitleB.copyWith(color: kTextColor, fontSize: 16),
          ),
          const SizedBox(height: 12),
          if (history.isEmpty)
            Text('No payment history yet', style: kEmptyStateM)
          else
            Column(
              children: history
                  .map(
                    (item) => _buildHistoryItem(
                      item['date'] ?? '',
                      item['amount'] ?? '',
                    ),
                  )
                  .toList(),
            ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final id = widget.autopayId;
    if (id == null || id.isEmpty) {
      return Scaffold(
        backgroundColor: kWhite,
        body: SafeArea(
          child: _body(
            title: widget.title,
            description: widget.description,
            status: widget.status,
            mandateAmount: widget.mandateAmount,
            period: widget.period,
            startDate: widget.startDate,
            endDate: widget.endDate,
            history: widget.history ?? const [],
          ),
        ),
      );
    }

    final detailAsync = ref.watch(autopayDetailProvider(id));
    final historyAsync = ref.watch(autopayHistoryProvider(id));

    return Scaffold(
      backgroundColor: kWhite,
      body: SafeArea(
        child: AsyncContent(
          asyncValue: detailAsync,
          onRetry: () {
            ref.invalidate(autopayDetailProvider(id));
            ref.invalidate(autopayHistoryProvider(id));
          },
          builder: (autopay) {
            final history =
                historyAsync.value?.transactions
                    .map(
                      (tx) => {
                        'date': formatDateLabel(tx.createdAt),
                        'amount': formatRupee(tx.amount),
                      },
                    )
                    .toList() ??
                const <Map<String, String>>[];

            return _body(
              title: autopay.campaignName ?? widget.title,
              description: '${formatRupee(autopay.amount)} • ${autopay.period}',
              status: autopay.status,
              mandateAmount: formatRupee(autopay.amount),
              period: autopay.period,
              startDate: formatDateLabel(autopay.createdAt),
              endDate: formatDateLabel(autopay.nextPayment),
              history: history,
              autopay: autopay,
            );
          },
        ),
      ),
    );
  }
}
