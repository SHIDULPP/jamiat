import 'package:flutter/material.dart';
import 'package:jamiat/src/data/constants/color_constants.dart';
import 'package:jamiat/src/data/constants/style_constants.dart';
import 'package:jamiat/src/data/services/haptic_helper.dart';
import 'package:jamiat/src/interfaces/components/donation_sheet.dart';

class CampaignDetailsScreen extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;

  // Extra properties for Active Campaign Details mode
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
    this.image,
    this.category,
    this.raised,
    this.goal,
    this.daysLeft,
  });

  bool get isCampaignMode => image != null;

  double get progress {
    final g = goal ?? 0;
    if (g <= 0) return 0.0;
    return ((raised ?? 0) / g).clamp(0.0, 1.0);
  }

  String _formatRupee(int amount) {
    final raw = amount.toString();
    final buf = StringBuffer();
    final len = raw.length;
    if (len <= 3) return '₹$raw';
    final last3 = raw.substring(len - 3);
    var rest = raw.substring(0, len - 3);
    final parts = <String>[];
    while (rest.length > 2) {
      parts.insert(0, rest.substring(rest.length - 2));
      rest = rest.substring(0, rest.length - 2);
    }
    if (rest.isNotEmpty) parts.insert(0, rest);
    buf.writeAll(parts, ',');
    buf.write(',$last3');
    return '₹$buf';
  }

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
        return icon;
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
        return iconBgColor;
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
        return iconColor;
    }
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
              // Custom Header / Top Bar
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
                    isCampaignMode ? 'Campaign details' : 'Donation details',
                    style: kHeadTitleB.copyWith(
                      color: kTextColor,
                      fontSize: 22,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              if (isCampaignMode) ...[
                // Banner Image Container
                Container(
                  height: 190,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(kCardRadiusLg),
                    boxShadow: [
                      BoxShadow(
                        color: kBlack.withValues(alpha: 0.04),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Image.asset(image!, fit: BoxFit.cover),
                ),
                const SizedBox(height: 20),

                // Category tag chip
                if (category != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: _getCategoryBgColor(category),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Text(
                      category!,
                      style: kCaption10SB.copyWith(
                        color: _getCategoryIconColor(category),
                        fontWeight: kBold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],

                // Campaign title
                Text(title, style: kSectionTitleSB.copyWith(fontSize: 20)),
                const SizedBox(height: 16),

                // Progress Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: kScreenBg,
                    borderRadius: BorderRadius.circular(kCardRadiusLg),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(kPillRadius),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 8,
                          backgroundColor: kGreyLight,
                          color: kSecondaryColor,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _formatRupee(raised ?? 0),
                                style: kBodyTitleSB.copyWith(fontSize: 16),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'raised of ${_formatRupee(goal ?? 0)}',
                                style: kCaption12R.copyWith(
                                  color: kSecondaryTextColor,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${(progress * 100).round()}%',
                                style: kBodyTitleSB.copyWith(fontSize: 16),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${daysLeft ?? 0} days left',
                                style: kCaption12M.copyWith(
                                  color: kDaysLeftWarning,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Campaign description
                Text(
                  description,
                  style: kBodyTitleR.copyWith(
                    color: kText2Color,
                    height: 1.5,
                    fontSize: 14,
                  ),
                ),
              ] else ...[
                // Category Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: kScreenBg,
                    borderRadius: BorderRadius.circular(kCardRadiusLg),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Icon Container / Custom Illustration
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
                      // Details Text (Title & Description)
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
                ),
                const SizedBox(height: 24),

                // Description Text Paragraph
                Text(
                  'Lorem ipsum dolor sit amet consectetur. Volutpat ultricies sed proin tristique augue erat felis eu. Pharetra feugiat molestie tincidunt fames nec malesuada vulputate. Facilisis fermentum non cras orci. Eget nec in sed netus at in blandit. Elementum vestibulum pellentesque faucibus quam elit viverra. Dictum semper netus a arcu volutpat pretium eu. At nec in duis elementum dolor. Magna fermentum parturient tincidunt lorem aliquet non. Mauris non pellentesque turpis quis ut. Volutpat vitae lacus ultrices ullamcorper nullam placerat dignissim.',
                  style: kBodyTitleR.copyWith(
                    color: kText2Color,
                    height: 1.5,
                    fontSize: 14,
                  ),
                ),
              ],
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
          child: ElevatedButton(
            onPressed: () {
              HapticHelper.impact(HapticImpact.medium);
              final displayTitle = isCampaignMode ? category ?? title : title;
              final sheetIcon = _getCategoryIcon(
                isCampaignMode ? category : title,
              );
              final sheetBg = _getCategoryBgColor(
                isCampaignMode ? category : title,
              );
              final sheetColor = _getCategoryIconColor(
                isCampaignMode ? category : title,
              );

              DonationSheet.show(
                context: context,
                categoryTitle: displayTitle,
                icon: sheetIcon,
                iconBgColor: sheetBg,
                iconColor: sheetColor,
                isAutopay: !isCampaignMode,
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
      ),
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

    // Draw background coin first
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

    // Coin 1 inner pattern (horizontal lines)
    canvas.drawLine(
      Offset(size.width * 0.65, size.height * 0.73),
      Offset(size.width * 0.81, size.height * 0.73),
      strokePaint,
    );

    // Draw foreground/overlay coin
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

    // Coin 2 inner pattern (star/dot)
    canvas.drawCircle(
      Offset(size.width * 0.67, size.height * 0.59),
      1.5,
      Paint()
        ..color = const Color(0xFF1E1E1E)
        ..style = PaintingStyle.fill,
    );

    // Main bag path
    final bagPath = Path();
    // Neck ruffles (top waves)
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

    // Neck tie constriction
    bagPath.quadraticBezierTo(
      size.width * 0.55,
      size.height * 0.34,
      size.width * 0.52,
      size.height * 0.36,
    );

    // Bulbous body
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

    // Fill the bag with white solid fill to mask the background coin
    canvas.drawPath(
      bagPath,
      Paint()
        ..color = const Color(0xFFFFFFFF)
        ..style = PaintingStyle.fill,
    );
    canvas.drawPath(bagPath, strokePaint);

    // Draw the tie string/band at the neck
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

    // Draw crescent and star emblem in the center of the bag
    final emblemCenter = Offset(size.width * 0.44, size.height * 0.63);
    canvas.drawCircle(emblemCenter, size.width * 0.14, strokePaint);

    // Crescent path
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

    // Star dot
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
