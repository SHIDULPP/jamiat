import 'package:flutter/material.dart';
import 'package:jamiat/src/data/constants/color_constants.dart';
import 'package:jamiat/src/data/constants/style_constants.dart';
import 'package:jamiat/src/data/services/haptic_helper.dart';

class EventTicketScreen extends StatelessWidget {
  final String title;
  final String date;
  final String venue;

  const EventTicketScreen({
    super.key,
    required this.title,
    required this.date,
    required this.venue,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kWhite,
      body: SafeArea(
        child: Column(
          children: [
            // Header Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
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
                        'My Ticket',
                        style: kHeadTitleB.copyWith(
                          color: kTextColor,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                  // Download Icon Action
                  GestureDetector(
                    onTap: () {
                      HapticHelper.impact(HapticImpact.light);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Downloading your entry pass...',
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
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Scrollable Ticket Content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 8,
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Main Ticket structure (Yellow Top, Grey Bottom)
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: kBlack.withValues(alpha: 0.04),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        children: [
                          // Yellow Header Segment
                          Container(
                            width: double.infinity,
                            color: const Color(0xFFFBBF24), // Golden Amber
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title,
                                  style: kCaption14M.copyWith(
                                    color: const Color(0xFF78350F), // Amber 900
                                    fontWeight: kMedium,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'General Entry Pass',
                                  style: kHeadTitleB.copyWith(
                                    color: const Color(0xFF451A03), // Amber 950
                                    fontSize: 22,
                                  ),
                                ),
                                const SizedBox(height: 14),
                                Text(
                                  'ORGANIZERS',
                                  style: kCaption12M.copyWith(
                                    color: const Color(
                                      0xFF92400E,
                                    ).withValues(alpha: 0.75),
                                    fontSize: 10,
                                    letterSpacing: 0.75,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Jamait Welfare Committee',
                                  style: kCaption14M.copyWith(
                                    color: const Color(0xFF451A03),
                                    fontWeight: kBold,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Bottom Grey Details Segment
                          Container(
                            width: double.infinity,
                            color: const Color(0xFFF3F4F6), // Cool Grey 100
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 24,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Date & Time Row
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Date',
                                            style: kCaption12R.copyWith(
                                              color: kMutedText,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            date,
                                            style: kBodyTitleB.copyWith(
                                              color: kTextColor,
                                              fontSize: 15,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Time',
                                            style: kCaption12R.copyWith(
                                              color: kMutedText,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '9:00 AM',
                                            style: kBodyTitleB.copyWith(
                                              color: kTextColor,
                                              fontSize: 15,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),

                                // Venue/Location
                                Text(
                                  'Venue',
                                  style: kCaption12R.copyWith(
                                    color: kMutedText,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  venue,
                                  style: kBodyTitleB.copyWith(
                                    color: kTextColor,
                                    fontSize: 15,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 24),

                                // QR Code Box Container
                                Center(
                                  child: Container(
                                    padding: const EdgeInsets.all(18),
                                    decoration: BoxDecoration(
                                      color: kWhite,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: kBorder.withValues(alpha: 0.8),
                                      ),
                                    ),
                                    child: const SizedBox(
                                      width: 140,
                                      height: 140,
                                      child: CustomPaint(
                                        painter: QrCodePainter(),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),

                                // QR Caption
                                Center(
                                  child: Text(
                                    'Show this QR to the\nprogram coordinators',
                                    textAlign: TextAlign.center,
                                    style: kCaption12R.copyWith(
                                      color: kMutedText,
                                      height: 1.35,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Left cutout circle notch
                    Positioned(
                      left: -12,
                      top:
                          196, // Yellow header height is roughly 208, centered at separator
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: kWhite,
                        ),
                      ),
                    ),

                    // Right cutout circle notch
                    Positioned(
                      right: -12,
                      top: 196,
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: kWhite,
                        ),
                      ),
                    ),

                    // Tear-off Dashed Line Overlay
                    Positioned(
                      left: 18,
                      right: 18,
                      top: 208,
                      child: Row(
                        children: List.generate(
                          24,
                          (index) => Expanded(
                            child: Container(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 2.5,
                              ),
                              height: 1.25,
                              color: kMutedText.withValues(alpha: 0.35),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Buttons segment
            Container(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      HapticHelper.impact(HapticImpact.medium);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Pass saved successfully to downloads folder!',
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
                      'Download Tickets',
                      style: kButtonLabelSB.copyWith(fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () {
                      HapticHelper.impact(HapticImpact.light);
                      Navigator.of(
                        context,
                      ).popUntil((route) => route.settings.name == 'Events');
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: kTextColor,
                      minimumSize: const Size.fromHeight(54),
                      side: const BorderSide(color: kBorder),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      'View all my Ticktes',
                      style: kButtonLabelSB.copyWith(
                        color: kTextColor,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class QrCodePainter extends CustomPainter {
  const QrCodePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = kTextColor
      ..style = PaintingStyle.fill;

    // Draw finder patterns (outer and inner squares at top-left, top-right, bottom-left)
    _drawFinderPattern(canvas, 0, 0, paint);
    _drawFinderPattern(canvas, size.width - 40, 0, paint);
    _drawFinderPattern(canvas, 0, size.height - 40, paint);

    // Draw alignment pattern (bottom-right)
    _drawAlignmentPattern(canvas, size.width - 24, size.height - 24, paint);

    // Draw pseudo-random data blocks
    final double blockSize = 5;
    final int cols = (size.width / blockSize).floor();
    final int rows = (size.height / blockSize).floor();

    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        // Skip finder zones
        if ((r < 9 && c < 9) ||
            (r < 9 && c > cols - 10) ||
            (r > rows - 10 && c < 9)) {
          continue;
        }
        // Skip alignment zones
        if (r > rows - 6 && c > cols - 6) {
          continue;
        }
        // Pseudo-noise matrix mapping
        final val = (r * 31 + c * 47) % 11;
        if (val == 1 || val == 3 || val == 4 || val == 7 || val == 9) {
          canvas.drawRect(
            Rect.fromLTWH(c * blockSize, r * blockSize, blockSize, blockSize),
            paint,
          );
        }
      }
    }
  }

  void _drawFinderPattern(Canvas canvas, double x, double y, Paint paint) {
    // Outer square outline
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 4;
    canvas.drawRect(Rect.fromLTWH(x + 2, y + 2, 36, 36), paint);

    // Inner square fill
    paint.style = PaintingStyle.fill;
    canvas.drawRect(Rect.fromLTWH(x + 10, y + 10, 20, 20), paint);
  }

  void _drawAlignmentPattern(Canvas canvas, double x, double y, Paint paint) {
    // Outer small frame
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 2.5;
    canvas.drawRect(Rect.fromLTWH(x + 1, y + 1, 14, 14), paint);

    // Inner mini dot
    paint.style = PaintingStyle.fill;
    canvas.drawRect(Rect.fromLTWH(x + 5, y + 5, 6, 6), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
