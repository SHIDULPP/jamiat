import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jamiat/src/data/constants/color_constants.dart';
import 'package:jamiat/src/data/constants/style_constants.dart';
import 'package:jamiat/src/data/models/enquiry_model.dart';
import 'package:jamiat/src/data/providers/enquiry_provider.dart';
import 'package:jamiat/src/data/services/haptic_helper.dart';
import 'package:jamiat/src/interfaces/components/async_content.dart';
import 'package:url_launcher/url_launcher.dart';

class EnquiriesScreen extends ConsumerWidget {
  const EnquiriesScreen({super.key});

  static const _headerBg = Color(0xFFFFFBEB);
  static const _emailIconColor = Color(0xFF2563EB);
  static const _phoneIconColor = Color(0xFF16A34A);

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${date.day} ${months[date.month - 1]}, ${date.year}';
  }

  Future<void> _launchUri(BuildContext context, Uri uri) async {
    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to open'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to open'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _email(BuildContext context, EnquiryModel enquiry) async {
    if (enquiry.email.isEmpty) return;
    HapticHelper.impact(HapticImpact.light);
    await _launchUri(
      context,
      Uri(
        scheme: 'mailto',
        path: enquiry.email,
        queryParameters: {'subject': 'Re: Your enquiry'},
      ),
    );
  }

  Future<void> _call(BuildContext context, EnquiryModel enquiry) async {
    final phone = enquiry.phone?.trim();
    if (phone == null || phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No phone number available'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    HapticHelper.impact(HapticImpact.light);
    await _launchUri(context, Uri(scheme: 'tel', path: phone));
  }

  Widget _actionIcon({
    required IconData icon,
    required Color color,
    required VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: color.withValues(alpha: 0.35)),
        ),
        child: Icon(icon, color: color, size: 18),
      ),
    );
  }

  Widget _enquiryCard(BuildContext context, EnquiryModel enquiry) {
    final hasPhone =
        enquiry.phone != null && enquiry.phone!.trim().isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kBorder),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            color: _headerBg,
            padding: const EdgeInsets.fromLTRB(16, 14, 14, 14),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        enquiry.name.isEmpty ? 'Unknown' : enquiry.name,
                        style: kBodyTitleSB.copyWith(
                          color: kTextColor,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatDate(enquiry.createdAt),
                        style: kCaption12R.copyWith(
                          color: kSecondaryTextColor,
                        ),
                      ),
                    ],
                  ),
                ),
                if (enquiry.email.isNotEmpty)
                  _actionIcon(
                    icon: Icons.mail_outline,
                    color: _emailIconColor,
                    onTap: () => _email(context, enquiry),
                  ),
                if (enquiry.email.isNotEmpty && hasPhone)
                  const SizedBox(width: 10),
                if (hasPhone)
                  _actionIcon(
                    icon: Icons.phone_outlined,
                    color: _phoneIconColor,
                    onTap: () => _call(context, enquiry),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              decoration: BoxDecoration(
                color: kScreenBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Message',
                    style: kCaption12R.copyWith(color: kMutedText),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    enquiry.message.isEmpty ? '—' : enquiry.message,
                    style: kBodyTitleR.copyWith(
                      color: kTextColor,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enquiriesAsync = ref.watch(receivedEnquiriesProvider);

    return Scaffold(
      backgroundColor: kWhite,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
              child: Row(
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
                    'Enquiries',
                    style: kHeadTitleB.copyWith(
                      color: kTextColor,
                      fontSize: 22,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: AsyncContent(
                asyncValue: enquiriesAsync,
                onRetry: () => ref.invalidate(receivedEnquiriesProvider),
                builder: (page) {
                  if (page.items.isEmpty) {
                    return Center(
                      child: Text(
                        'No enquiries yet',
                        style: kEmptyStateM,
                      ),
                    );
                  }

                  return RefreshIndicator(
                    color: kPrimaryColor,
                    onRefresh: () async {
                      ref.invalidate(receivedEnquiriesProvider);
                      await ref.read(receivedEnquiriesProvider.future);
                    },
                    child: ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics(),
                      ),
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                      itemCount: page.items.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        return _enquiryCard(context, page.items[index]);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
