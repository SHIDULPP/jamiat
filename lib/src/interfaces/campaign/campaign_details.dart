import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:jamiat/src/data/apis/campaign_api.dart';
import 'package:jamiat/src/data/constants/color_constants.dart';
import 'package:jamiat/src/data/constants/style_constants.dart';
import 'package:jamiat/src/data/models/campaign_model.dart';
import 'package:jamiat/src/data/providers/campaign_provider.dart';
import 'package:jamiat/src/data/services/haptic_helper.dart';
import 'package:jamiat/src/data/utils/category_mapper.dart';
import 'package:jamiat/src/data/utils/format_helpers.dart';
import 'package:jamiat/src/interfaces/components/async_content.dart';
import 'package:jamiat/src/interfaces/components/donation_sheet.dart';

class CampaignDetailsScreen extends ConsumerStatefulWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;
  final String? campaignId;
  final String? image;
  final String? category;
  final int? raised;
  final int? goal;
  final int? daysLeft;

  const CampaignDetailsScreen({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
    this.campaignId,
    this.image,
    this.category,
    this.raised,
    this.goal,
    this.daysLeft,
  });

  @override
  ConsumerState<CampaignDetailsScreen> createState() =>
      _CampaignDetailsScreenState();
}

class _CampaignDetailsScreenState extends ConsumerState<CampaignDetailsScreen> {
  bool _bookmarkLoading = false;
  bool _shareLoading = false;

  bool get hasCampaignId =>
      widget.campaignId != null && widget.campaignId!.isNotEmpty;

  bool get isCampaignMode => hasCampaignId || widget.image != null;

  IconData _getCategoryIcon(String? categoryName) {
    switch (categoryName?.toLowerCase() ?? '') {
      case 'general campaign':
        return Icons.volunteer_activism_outlined;
      case 'general funding':
        return Icons.savings_outlined;
      case 'zakat':
      case 'zakath':
        return Icons.payments_outlined;
      case 'orphan':
        return Icons.favorite_border_outlined;
      case 'building mosque':
        return Icons.mosque;
      case 'medical relief':
      case 'medical aid':
        return Icons.monitor_heart_outlined;
      default:
        return widget.icon;
    }
  }

  Color _getCategoryBgColor(String? categoryName) {
    switch (categoryName?.toLowerCase() ?? '') {
      case 'general campaign':
        return const Color(0xFFFFF7ED);
      case 'general funding':
        return const Color(0xFFFEF2F2);
      case 'zakat':
      case 'zakath':
        return const Color(0xFFF0FDF4);
      case 'orphan':
        return const Color(0xFFFDF4FF);
      case 'building mosque':
        return const Color(0xFFEFF6FF);
      case 'medical relief':
      case 'medical aid':
        return const Color(0xFFFFF5F5);
      default:
        return widget.iconBgColor;
    }
  }

  Color _getCategoryIconColor(String? categoryName) {
    switch (categoryName?.toLowerCase() ?? '') {
      case 'general campaign':
        return const Color(0xFFEA580C);
      case 'general funding':
        return const Color(0xFFDC2626);
      case 'zakat':
      case 'zakath':
        return const Color(0xFF16A34A);
      case 'orphan':
        return const Color(0xFFC084FC);
      case 'building mosque':
        return const Color(0xFF2563EB);
      case 'medical relief':
      case 'medical aid':
        return const Color(0xFFEF4444);
      default:
        return widget.iconColor;
    }
  }

  Future<void> _toggleBookmark(CampaignModel campaign) async {
    if (_bookmarkLoading) return;
    setState(() => _bookmarkLoading = true);
    try {
      final api = ref.read(campaignApiProvider);
      final res = campaign.isBookmarked
          ? await api.removeBookmark(campaign.id)
          : await api.bookmarkCampaign(campaign.id);
      if (!mounted) return;
      if (!res.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res.message ?? 'Bookmark failed')),
        );
        return;
      }
      ref.invalidate(campaignDetailProvider(campaign.id));
      ref.invalidate(savedCampaignsProvider);
      ref.invalidate(campaignListProvider(1));
      ref.invalidate(featuredCampaignsProvider);
    } finally {
      if (mounted) setState(() => _bookmarkLoading = false);
    }
  }

  Future<void> _shareCampaign(String campaignId, String title) async {
    if (_shareLoading) return;
    setState(() => _shareLoading = true);
    try {
      final res = await ref.read(campaignApiProvider).shareCampaign(campaignId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            res.success
                ? 'Thanks for sharing $title'
                : (res.message ?? 'Share failed'),
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _shareLoading = false);
    }
  }

  Widget _headerCircleButton({
    required Widget child,
    required VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: kWhite,
          border: Border.all(color: kBorder, width: 1.25),
        ),
        alignment: Alignment.center,
        child: child,
      ),
    );
  }

  Widget _coverImage(String? url) {
    if (url != null && url.startsWith('http')) {
      return Image.network(
        url,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (_, _, _) => Container(
          color: kScreenBg,
          child: const Icon(Icons.image_outlined, color: kMutedText, size: 40),
        ),
      );
    }
    return Image.asset(
      url ?? 'assets/jpgs/campaign_education.jpg',
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      errorBuilder: (_, _, _) => Container(
        color: kScreenBg,
        child: const Icon(Icons.image_outlined, color: kMutedText, size: 40),
      ),
    );
  }

  Widget _buildCampaignBody({
    required BuildContext context,
    required String displayTitle,
    required String displayDescription,
    required String? displayCategory,
    required String? displayImage,
    required num displayRaised,
    required num displayGoal,
    required int displayDaysLeft,
    DateTime? targetDate,
  }) {
    final progress = displayGoal <= 0
        ? 0.0
        : (displayRaised / displayGoal).clamp(0.0, 1.0);
    final percent = (progress * 100).round();
    final categoryLabel = CategoryMapper.toUi(displayCategory);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AspectRatio(
          aspectRatio: 16 / 9,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: _coverImage(displayImage),
          ),
        ),
        const SizedBox(height: 16),
        if (displayCategory != null) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFEEEEEE),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              categoryLabel,
              style: kCaption12M.copyWith(color: kTextColor),
            ),
          ),
          const SizedBox(height: 12),
        ],
        Text(
          displayTitle,
          style: kSectionTitleSB.copyWith(fontSize: 22, height: 1.25),
        ),
        const SizedBox(height: 16),
        ClipRRect(
          borderRadius: BorderRadius.circular(kPillRadius),
          child: LinearProgressIndicator(
            value: progress.toDouble(),
            minHeight: 8,
            backgroundColor: kGreyLight,
            color: kSecondaryColor,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    formatRupee(displayRaised),
                    style: kBodyTitleSB.copyWith(fontSize: 16),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'of ${formatRupee(displayGoal)}',
                    style: kCaption12R.copyWith(color: kSecondaryTextColor),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('$percent%', style: kBodyTitleSB.copyWith(fontSize: 16)),
                const SizedBox(height: 2),
                Text(
                  '$displayDaysLeft days left',
                  style: kCaption12R.copyWith(color: kSecondaryTextColor),
                ),
              ],
            ),
          ],
        ),
        if (targetDate != null) ...[
          const SizedBox(height: 16),
          Text.rich(
            TextSpan(
              style: kCaption14R.copyWith(color: kSecondaryTextColor),
              children: [
                const TextSpan(text: 'Target Date: '),
                TextSpan(
                  text: formatTargetDate(targetDate),
                  style: kCaption14M.copyWith(color: kTextColor),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 16),
        Text(
          displayDescription,
          style: kBodyTitleR.copyWith(
            color: kText2Color,
            height: 1.5,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildCategoryMode(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: kScreenBg,
            borderRadius: BorderRadius.circular(kCardRadiusLg),
          ),
          child: Row(
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
                  child: widget.title.toLowerCase() == 'zakat'
                      ? CustomPaint(
                          size: const Size(36, 36),
                          painter: ZakatBagPainter(),
                        )
                      : Icon(widget.icon, color: widget.iconColor, size: 26),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: kBodyTitleB.copyWith(
                        color: kTextColor,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.description,
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
        const SizedBox(height: 24),
        Text(
          widget.description,
          style: kBodyTitleR.copyWith(
            color: kText2Color,
            height: 1.5,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _donateButton({
    required String title,
    required String? category,
    required String? campaignId,
    required num raised,
    required num goal,
  }) {
    final displayCat = CategoryMapper.toUi(category);
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
        child: ElevatedButton(
          onPressed: () {
            HapticHelper.impact(HapticImpact.medium);
            DonationSheet.show(
              context: context,
              categoryTitle: title,
              icon: _getCategoryIcon(displayCat),
              iconBgColor: _getCategoryBgColor(displayCat),
              iconColor: _getCategoryIconColor(displayCat),
              isAutopay: false,
              campaignId: campaignId,
              categoryLabel: displayCat,
              raised: raised,
              goal: goal,
            );
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
            'Donate Now',
            style: kButtonLabelSB.copyWith(fontSize: 16),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isBookmarked = hasCampaignId
        ? (ref
                  .watch(campaignDetailProvider(widget.campaignId!))
                  .value
                  ?.isBookmarked ??
              false)
        : false;

    return Scaffold(
      backgroundColor: kWhite,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
              child: Row(
                children: [
                  _headerCircleButton(
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
                  Expanded(
                    child: Text(
                      isCampaignMode ? 'Campaign details' : 'Donation details',
                      textAlign: TextAlign.center,
                      style: kHeadTitleB.copyWith(
                        color: kTextColor,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  if (hasCampaignId) ...[
                    _headerCircleButton(
                      onTap: _shareLoading
                          ? null
                          : () {
                              HapticHelper.impact(HapticImpact.light);
                              final campaign = ref
                                  .read(
                                    campaignDetailProvider(widget.campaignId!),
                                  )
                                  .value;
                              _shareCampaign(
                                widget.campaignId!,
                                campaign?.title ?? widget.title,
                              );
                            },
                      child: _shareLoading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : SvgPicture.asset(
                              'assets/svg/share.svg',
                              width: 18,
                              height: 18,
                              colorFilter: const ColorFilter.mode(
                                kTextColor,
                                BlendMode.srcIn,
                              ),
                            ),
                    ),
                    const SizedBox(width: 8),
                    _headerCircleButton(
                      onTap: _bookmarkLoading
                          ? null
                          : () {
                              HapticHelper.impact(HapticImpact.light);
                              final campaign = ref
                                  .read(
                                    campaignDetailProvider(widget.campaignId!),
                                  )
                                  .value;
                              if (campaign != null) {
                                _toggleBookmark(campaign);
                              }
                            },
                      child: _bookmarkLoading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : SvgPicture.asset(
                              'assets/svg/bookmark.svg',
                              width: 18,
                              height: 18,
                              colorFilter: ColorFilter.mode(
                                isBookmarked ? kPrimaryColor : kTextColor,
                                BlendMode.srcIn,
                              ),
                            ),
                    ),
                  ] else
                    const SizedBox(width: 40),
                ],
              ),
            ),
            Expanded(
              child: hasCampaignId
                  ? AsyncContent<CampaignModel>(
                      asyncValue: ref.watch(
                        campaignDetailProvider(widget.campaignId!),
                      ),
                      onRetry: () => ref.invalidate(
                        campaignDetailProvider(widget.campaignId!),
                      ),
                      builder: (campaign) => SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: _buildCampaignBody(
                          context: context,
                          displayTitle: campaign.title,
                          displayDescription: campaign.description,
                          displayCategory: campaign.category,
                          displayImage: campaign.coverImage,
                          displayRaised: campaign.collectedAmount,
                          displayGoal: campaign.targetAmount,
                          displayDaysLeft: campaign.remainingDays ?? 0,
                          targetDate: campaign.targetDate,
                        ),
                      ),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: isCampaignMode
                          ? _buildCampaignBody(
                              context: context,
                              displayTitle: widget.title,
                              displayDescription: widget.description,
                              displayCategory: widget.category,
                              displayImage: widget.image,
                              displayRaised: widget.raised ?? 0,
                              displayGoal: widget.goal ?? 0,
                              displayDaysLeft: widget.daysLeft ?? 0,
                            )
                          : _buildCategoryMode(context),
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: () {
        if (hasCampaignId) {
          final campaign = ref
              .watch(campaignDetailProvider(widget.campaignId!))
              .value;
          if (campaign == null) return null;
          return _donateButton(
            title: campaign.title,
            category: campaign.category,
            campaignId: campaign.id,
            raised: campaign.collectedAmount,
            goal: campaign.targetAmount,
          );
        }
        if (isCampaignMode) {
          return _donateButton(
            title: widget.title,
            category: widget.category,
            campaignId: widget.campaignId,
            raised: widget.raised ?? 0,
            goal: widget.goal ?? 0,
          );
        }
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
            child: ElevatedButton(
              onPressed: () {
                HapticHelper.impact(HapticImpact.medium);
                DonationSheet.show(
                  context: context,
                  categoryTitle: widget.title,
                  icon: _getCategoryIcon(widget.title),
                  iconBgColor: _getCategoryBgColor(widget.title),
                  iconColor: _getCategoryIconColor(widget.title),
                  isAutopay: false,
                  campaignId: widget.campaignId,
                );
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
                'Donate Now',
                style: kButtonLabelSB.copyWith(fontSize: 16),
              ),
            ),
          ),
        );
      }(),
    );
  }
}

class ZakatBagPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final strokePaint = Paint()
      ..color = const Color(0xFF1E1E1E)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.75
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final coin1Path = Path();
    coin1Path.addOval(
      Rect.fromLTRB(
        size.width * 0.58,
        size.height * 0.58,
        size.width * 0.88,
        size.height * 0.88,
      ),
    );
    canvas.drawPath(
      coin1Path,
      Paint()
        ..color = const Color(0xFFFFFFFF)
        ..style = PaintingStyle.fill,
    );
    canvas.drawPath(coin1Path, strokePaint);

    canvas.drawLine(
      Offset(size.width * 0.65, size.height * 0.73),
      Offset(size.width * 0.81, size.height * 0.73),
      strokePaint,
    );

    final coin2Path = Path();
    coin2Path.addOval(
      Rect.fromLTRB(
        size.width * 0.52,
        size.height * 0.44,
        size.width * 0.82,
        size.height * 0.74,
      ),
    );
    canvas.drawPath(
      coin2Path,
      Paint()
        ..color = const Color(0xFFFFFFFF)
        ..style = PaintingStyle.fill,
    );
    canvas.drawPath(coin2Path, strokePaint);

    canvas.drawCircle(
      Offset(size.width * 0.67, size.height * 0.59),
      1.5,
      Paint()
        ..color = const Color(0xFF1E1E1E)
        ..style = PaintingStyle.fill,
    );

    final bagPath = Path();
    bagPath.moveTo(size.width * 0.32, size.height * 0.32);
    bagPath.quadraticBezierTo(
      size.width * 0.28,
      size.height * 0.20,
      size.width * 0.22,
      size.height * 0.22,
    );
    bagPath.quadraticBezierTo(
      size.width * 0.28,
      size.height * 0.12,
      size.width * 0.38,
      size.height * 0.15,
    );
    bagPath.quadraticBezierTo(
      size.width * 0.48,
      size.height * 0.12,
      size.width * 0.55,
      size.height * 0.20,
    );
    bagPath.quadraticBezierTo(
      size.width * 0.62,
      size.height * 0.22,
      size.width * 0.58,
      size.height * 0.32,
    );
    bagPath.quadraticBezierTo(
      size.width * 0.55,
      size.height * 0.34,
      size.width * 0.52,
      size.height * 0.36,
    );
    bagPath.quadraticBezierTo(
      size.width * 0.76,
      size.height * 0.55,
      size.width * 0.70,
      size.height * 0.75,
    );
    bagPath.quadraticBezierTo(
      size.width * 0.65,
      size.height * 0.90,
      size.width * 0.44,
      size.height * 0.90,
    );
    bagPath.quadraticBezierTo(
      size.width * 0.18,
      size.height * 0.90,
      size.width * 0.16,
      size.height * 0.72,
    );
    bagPath.quadraticBezierTo(
      size.width * 0.14,
      size.height * 0.50,
      size.width * 0.36,
      size.height * 0.36,
    );
    bagPath.close();

    canvas.drawPath(
      bagPath,
      Paint()
        ..color = const Color(0xFFFFFFFF)
        ..style = PaintingStyle.fill,
    );
    canvas.drawPath(bagPath, strokePaint);

    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(size.width * 0.44, size.height * 0.35),
        width: size.width * 0.18,
        height: size.height * 0.05,
      ),
      0,
      3.14,
      false,
      strokePaint,
    );

    final emblemCenter = Offset(size.width * 0.44, size.height * 0.63);
    canvas.drawCircle(emblemCenter, size.width * 0.14, strokePaint);

    final crescentPath = Path();
    crescentPath.addArc(
      Rect.fromCircle(
        center: Offset(emblemCenter.dx - 1.5, emblemCenter.dy),
        radius: 3.0,
      ),
      -1.5,
      3.0,
    );
    canvas.drawPath(crescentPath, strokePaint);

    canvas.drawCircle(
      Offset(emblemCenter.dx + 2.0, emblemCenter.dy),
      0.8,
      Paint()
        ..color = const Color(0xFF1E1E1E)
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
