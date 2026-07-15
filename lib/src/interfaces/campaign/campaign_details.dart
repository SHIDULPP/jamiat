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

  const CampaignDetailsScreen({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
  });

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
                    'Donation details',
                    style: kHeadTitleB.copyWith(
                      color: kTextColor,
                      fontSize: 22,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Campaign Info Card
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
              DonationSheet.show(
                context: context,
                categoryTitle: title,
                icon: icon,
                iconBgColor: iconBgColor,
                iconColor: iconColor,
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
