import 'package:flutter/material.dart';
import 'package:jamiat/src/data/constants/color_constants.dart';
import 'package:jamiat/src/data/constants/style_constants.dart';
import 'package:jamiat/src/data/services/haptic_helper.dart';

class WelfareProgramScreen extends StatefulWidget {
  const WelfareProgramScreen({super.key});

  @override
  State<WelfareProgramScreen> createState() => _WelfareProgramScreenState();
}

class _WelfareProgramScreenState extends State<WelfareProgramScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<Map<String, dynamic>> _welfareServices = [
    {
      'key': 'maktab',
      'title': 'Maktab (Deeni ta’alimi Board)',
      'description':
          'Providing foundational Islamic and moral education to millions of children through a statewide network of local Maktabs.',
      'bgColor': const Color(0xFFFFFBEB), // Soft yellow-orange amber
      'titleColor': const Color(0xFF78350F),
      'descColor': const Color(0xFF92400E),
      'painter': const MaktabBookPainter(),
    },
    {
      'key': 'ulama',
      'title': 'Ulama',
      'description':
          'Empowering young Islamic scholars with modern, social, and economic skills to uplift and serve the community.',
      'bgColor': const Color(0xFFFFF1F2), // Soft pink rose
      'titleColor': const Color(0xFF9F1239),
      'descColor': const Color(0xFFBE123C),
      'painter': const UlamaTurbanPainter(),
    },
    {
      'key': 'youth_club',
      'title': 'Youth Club',
      'description':
          'Inculcating humanitarian spirit and leadership skills in youth under the world-renowned "Bharat Scouts & Guides" umbrella.',
      'bgColor': const Color(0xFFF0FDF4), // Soft green
      'titleColor': const Color(0xFF166534),
      'descColor': const Color(0xFF15803D),
      'painter': const YouthClubFlagPainter(),
    },
    {
      'key': 'study_center',
      'title': 'Study Center',
      'description':
          'Providing secondary education coaching and NIOS certifications to modernize learning for madrasa students.',
      'bgColor': const Color(0xFFFDF4FF), // Soft purple fuchsia
      'titleColor': const Color(0xFF86198F),
      'descColor': const Color(0xFFA21CAF),
      'painter': const StudyCenterBooksPainter(),
    },
    {
      'key': 'model_village',
      'title': 'Model Village',
      'description':
          'Developing sustainable model villages and emergency housing infrastructure for rehabilitation and community growth.',
      'bgColor': const Color(0xFFEFF6FF), // Soft blue sky
      'titleColor': const Color(0xFF1E40AF),
      'descColor': const Color(0xFF1D4ED8),
      'painter': const ModelVillageHousesPainter(),
    },
    {
      'key': 'jem',
      'title': 'JEM',
      'description':
          'Safeguarding human rights and protecting constitutional liberties by documenting hate crimes and providing essential legal aid.',
      'bgColor': const Color(0xFFF5EBE6), // Soft warm beige/cream
      'titleColor': const Color(0xFF7C2D12),
      'descColor': const Color(0xFF9A3412),
      'painter': const JemCourtPainter(),
    },
  ];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _welfareServices.where((service) {
      final title = (service['title'] as String).toLowerCase();
      final desc = (service['description'] as String).toLowerCase();
      return title.contains(_searchQuery) || desc.contains(_searchQuery);
    }).toList();

    return Scaffold(
      backgroundColor: kWhite,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
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
                    'Welfare Services',
                    style: kHeadTitleB.copyWith(
                      color: kTextColor,
                      fontSize: 22,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Search Bar
              Container(
                decoration: BoxDecoration(
                  color: kWhite,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: kBorder, width: 1.25),
                  boxShadow: [
                    BoxShadow(
                      color: kBlack.withValues(alpha: 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search for services',
                    hintStyle: kCaption14M.copyWith(color: kMutedText),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: kMutedText,
                      size: 22,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                  ),
                  style: kBodyTitleB.copyWith(color: kTextColor, fontSize: 15),
                ),
              ),
              const SizedBox(height: 24),

              // Scrollable welfare services cards list
              Expanded(
                child: filtered.isEmpty
                    ? Center(
                        child: Text('No services found', style: kEmptyStateM),
                      )
                    : ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final service = filtered[index];

                          return GestureDetector(
                            onTap: () {
                              HapticHelper.impact(HapticImpact.light);
                              Navigator.pushNamed(
                                context,
                                'WelfareDetails',
                                arguments: {'serviceKey': service['key']},
                              );
                            },
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 20),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: service['bgColor'] as Color,
                                borderRadius: BorderRadius.circular(
                                  kCardRadiusLg,
                                ),
                                border: Border.all(
                                  color: (service['bgColor'] as Color)
                                      .withValues(alpha: 0.15),
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Programmatic Illustration image fallback wrapper
                                  Container(
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      color: kWhite,
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: kBlack.withValues(alpha: 0.03),
                                          blurRadius: 6,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: CustomPaint(
                                      painter:
                                          service['painter'] as CustomPainter,
                                    ),
                                  ),
                                  const SizedBox(width: 16),

                                  // Title and Description Column
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          service['title'] as String,
                                          style: kBodyTitleB.copyWith(
                                            color: kTextColor,
                                            fontSize: 16,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          service['description'] as String,
                                          style: kCaption12R.copyWith(
                                            color: kMutedText,
                                            height: 1.4,
                                            fontSize: 12.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// 1. Maktab Book Painter (Quran book on rehal wooden stand & blackboard)
class MaktabBookPainter extends CustomPainter {
  const MaktabBookPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..isAntiAlias = true;

    // Blackboard shape in background
    paint.color = const Color(0xFF374151); // Charcoal blackboard
    final boardRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        size.width * 0.25,
        size.height * 0.15,
        size.width * 0.5,
        size.height * 0.35,
      ),
      const Radius.circular(4),
    );
    canvas.drawRRect(boardRect, paint);

    // Board wood borders
    paint.color = const Color(0xFFB45309); // Wood brown
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 2.5;
    canvas.drawRRect(boardRect, paint);

    // Chalk marks
    paint.color = Colors.white.withValues(alpha: 0.8);
    paint.strokeWidth = 1.5;
    canvas.drawLine(
      Offset(size.width * 0.35, size.height * 0.25),
      Offset(size.width * 0.45, size.height * 0.3),
      paint,
    );
    canvas.drawLine(
      Offset(size.width * 0.45, size.height * 0.3),
      Offset(size.width * 0.55, size.height * 0.2),
      paint,
    );

    // Wooden rehal base
    paint.style = PaintingStyle.fill;
    paint.color = const Color(0xFFD97706); // Warm Wood amber

    // Left leg
    final pathLeft = Path()
      ..moveTo(size.width * 0.3, size.height * 0.75)
      ..lineTo(size.width * 0.7, size.height * 0.55)
      ..lineTo(size.width * 0.75, size.height * 0.6)
      ..lineTo(size.width * 0.35, size.height * 0.8)
      ..close();
    canvas.drawPath(pathLeft, paint);

    // Right leg
    final pathRight = Path()
      ..moveTo(size.width * 0.7, size.height * 0.75)
      ..lineTo(size.width * 0.3, size.height * 0.55)
      ..lineTo(size.width * 0.25, size.height * 0.6)
      ..lineTo(size.width * 0.65, size.height * 0.8)
      ..close();
    canvas.drawPath(pathRight, paint);

    // Open book pages on top of rehal
    paint.color = const Color(0xFFFEF3C7); // Cream/yellow pages
    final leftPage = Path()
      ..moveTo(size.width * 0.5, size.height * 0.53)
      ..quadraticBezierTo(
        size.width * 0.4,
        size.height * 0.46,
        size.width * 0.28,
        size.height * 0.52,
      )
      ..lineTo(size.width * 0.32, size.height * 0.64)
      ..quadraticBezierTo(
        size.width * 0.42,
        size.height * 0.58,
        size.width * 0.5,
        size.height * 0.65,
      )
      ..close();
    canvas.drawPath(leftPage, paint);

    final rightPage = Path()
      ..moveTo(size.width * 0.5, size.height * 0.53)
      ..quadraticBezierTo(
        size.width * 0.6,
        size.height * 0.46,
        size.width * 0.72,
        size.height * 0.52,
      )
      ..lineTo(size.width * 0.68, size.height * 0.64)
      ..quadraticBezierTo(
        size.width * 0.58,
        size.height * 0.58,
        size.width * 0.5,
        size.height * 0.65,
      )
      ..close();
    canvas.drawPath(rightPage, paint);

    // Book lines/text details
    paint.color = const Color(0xFFB45309).withValues(alpha: 0.35);
    paint.strokeWidth = 1.25;
    paint.style = PaintingStyle.stroke;

    canvas.drawLine(
      Offset(size.width * 0.36, size.height * 0.54),
      Offset(size.width * 0.46, size.height * 0.57),
      paint,
    );
    canvas.drawLine(
      Offset(size.width * 0.35, size.height * 0.58),
      Offset(size.width * 0.45, size.height * 0.61),
      paint,
    );
    canvas.drawLine(
      Offset(size.width * 0.64, size.height * 0.54),
      Offset(size.width * 0.54, size.height * 0.57),
      paint,
    );
    canvas.drawLine(
      Offset(size.width * 0.65, size.height * 0.58),
      Offset(size.width * 0.55, size.height * 0.61),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// 2. Ulama Turban Painter (Turban coils, rolled scroll with tie ribbon)
class UlamaTurbanPainter extends CustomPainter {
  const UlamaTurbanPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..isAntiAlias = true;

    // Scroll base parchment
    paint.color = const Color(0xFFFEF3C7); // Parchment cream
    final scrollRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        size.width * 0.25,
        size.height * 0.65,
        size.width * 0.5,
        size.height * 0.16,
      ),
      const Radius.circular(4),
    );
    canvas.drawRRect(scrollRect, paint);

    // Scroll red ribbon tie
    paint.color = const Color(0xFFEF4444); // Red ribbon
    canvas.drawRect(
      Rect.fromLTWH(
        size.width * 0.46,
        size.height * 0.65,
        size.width * 0.08,
        size.height * 0.16,
      ),
      paint,
    );

    // Parchment scroll ends (coiled circle)
    paint.color = const Color(0xFFD97706); // Dark wood roll borders
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 1.5;
    canvas.drawCircle(
      Offset(size.width * 0.25, size.height * 0.73),
      size.height * 0.08,
      paint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.75, size.height * 0.73),
      size.height * 0.08,
      paint,
    );

    // Turban dome shape base
    paint.style = PaintingStyle.fill;
    paint.color = const Color(0xFFECEFF1); // Off-white turban cloth
    canvas.drawOval(
      Rect.fromLTWH(
        size.width * 0.2,
        size.height * 0.22,
        size.width * 0.6,
        size.height * 0.38,
      ),
      paint,
    );

    // Turban wrap folds
    paint.color = const Color(0xFFFFFBEB); // Inner wraps
    canvas.drawOval(
      Rect.fromLTWH(
        size.width * 0.25,
        size.height * 0.32,
        size.width * 0.5,
        size.height * 0.22,
      ),
      paint,
    );

    // Turban center fold gem/feather base
    paint.color = const Color(0xFFFBBF24); // Golden wrap
    canvas.drawOval(
      Rect.fromLTWH(
        size.width * 0.44,
        size.height * 0.18,
        size.width * 0.12,
        size.height * 0.2,
      ),
      paint,
    );

    // Feathers plume
    paint.color = const Color(0xFFB0BEC5); // Grey feather lines
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 1.5;
    final feather = Path()
      ..moveTo(size.width * 0.5, size.height * 0.18)
      ..quadraticBezierTo(
        size.width * 0.47,
        size.height * 0.06,
        size.width * 0.42,
        size.height * 0.04,
      );
    canvas.drawPath(feather, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// 3. Youth Club Flag Painter (Scouts green flag & compass layout)
class YouthClubFlagPainter extends CustomPainter {
  const YouthClubFlagPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..isAntiAlias = true;

    // Flag pole
    paint.color = const Color(0xFFB45309); // Wood brown pole
    paint.strokeWidth = 3;
    paint.style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(size.width * 0.3, size.height * 0.1),
      Offset(size.width * 0.3, size.height * 0.85),
      paint,
    );

    // Green Flag shape
    paint.color = const Color(0xFF047857); // Scouts green
    paint.style = PaintingStyle.fill;
    final flag = Path()
      ..moveTo(size.width * 0.3, size.height * 0.15)
      ..lineTo(size.width * 0.72, size.height * 0.26)
      ..lineTo(size.width * 0.62, size.height * 0.38)
      ..lineTo(size.width * 0.72, size.height * 0.48)
      ..lineTo(size.width * 0.3, size.height * 0.55)
      ..close();
    canvas.drawPath(flag, paint);

    // Flag symbol (Lily/Fleur-de-lis star logo center)
    paint.color = const Color(0xFFFBBF24); // Golden scouts emblem
    canvas.drawCircle(Offset(size.width * 0.45, size.height * 0.35), 5, paint);

    // Mini compass layout
    paint.color = const Color(0xFF90A4AE); // Steel grey compass
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 2;
    canvas.drawCircle(
      Offset(size.width * 0.75, size.height * 0.7),
      size.width * 0.15,
      paint,
    );

    // Compass hands
    paint.style = PaintingStyle.fill;
    paint.color = const Color(0xFFEF4444); // Red north hand
    final handRed = Path()
      ..moveTo(size.width * 0.75, size.height * 0.7)
      ..lineTo(size.width * 0.71, size.height * 0.7)
      ..lineTo(size.width * 0.75, size.height * 0.6)
      ..close();
    canvas.drawPath(handRed, paint);

    paint.color = const Color(0xFF78909C); // Blue/grey south hand
    final handSouth = Path()
      ..moveTo(size.width * 0.75, size.height * 0.7)
      ..lineTo(size.width * 0.79, size.height * 0.7)
      ..lineTo(size.width * 0.75, size.height * 0.8)
      ..close();
    canvas.drawPath(handSouth, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// 4. Study Center Books Painter (Globe, monitor screen, books stack)
class StudyCenterBooksPainter extends CustomPainter {
  const StudyCenterBooksPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..isAntiAlias = true;

    // Books stack (Bottom)
    // Book 1 (Blue)
    paint.color = const Color(0xFF2563EB); // Royal blue
    final r1 = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        size.width * 0.25,
        size.height * 0.68,
        size.width * 0.5,
        size.height * 0.12,
      ),
      const Radius.circular(2),
    );
    canvas.drawRRect(r1, paint);

    // Pages edge for Book 1
    paint.color = const Color(0xFFECEFF1);
    canvas.drawRect(
      Rect.fromLTWH(
        size.width * 0.7,
        size.height * 0.69,
        size.width * 0.04,
        size.height * 0.1,
      ),
      paint,
    );

    // Book 2 (Green, rotated slightly)
    paint.color = const Color(0xFF10B981); // Emerald green
    final r2 = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        size.width * 0.2,
        size.height * 0.57,
        size.width * 0.48,
        size.height * 0.11,
      ),
      const Radius.circular(2),
    );
    canvas.drawRRect(r2, paint);

    // Monitor Screen in background
    paint.color = const Color(0xFF455A64); // Dark bezel
    final monitor = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        size.width * 0.38,
        size.height * 0.18,
        size.width * 0.45,
        size.height * 0.32,
      ),
      const Radius.circular(4),
    );
    canvas.drawRRect(monitor, paint);

    // Screen stand
    paint.color = const Color(0xFF263238);
    canvas.drawRect(
      Rect.fromLTWH(
        size.width * 0.56,
        size.height * 0.5,
        size.width * 0.08,
        size.height * 0.08,
      ),
      paint,
    );
    canvas.drawRect(
      Rect.fromLTWH(
        size.width * 0.48,
        size.height * 0.58,
        size.width * 0.24,
        size.height * 0.03,
      ),
      paint,
    );

    // Mini Globe (Left side)
    paint.color = const Color(0xFF60A5FA); // Globe water blue
    canvas.drawCircle(
      Offset(size.width * 0.24, size.height * 0.34),
      size.width * 0.15,
      paint,
    );

    // Globe stand
    paint.color = const Color(0xFFB45309); // Wood brown stand
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 2.25;
    canvas.drawArc(
      Rect.fromCircle(
        center: Offset(size.width * 0.24, size.height * 0.34),
        radius: size.width * 0.18,
      ),
      -0.2,
      3.5,
      false,
      paint,
    );
    canvas.drawLine(
      Offset(size.width * 0.24, size.height * 0.52),
      Offset(size.width * 0.24, size.height * 0.6),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// 5. Model Village Houses Painter (Isometric tiny houses, green trees)
class ModelVillageHousesPainter extends CustomPainter {
  const ModelVillageHousesPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..isAntiAlias = true;

    // Ground platform (Isometric oval)
    paint.color = const Color(0xFFD9F99D); // Light lime green ground
    final pathGround = Path()
      ..moveTo(size.width * 0.5, size.height * 0.8)
      ..lineTo(size.width * 0.88, size.height * 0.62)
      ..lineTo(size.width * 0.5, size.height * 0.44)
      ..lineTo(size.width * 0.12, size.height * 0.62)
      ..close();
    canvas.drawPath(pathGround, paint);

    // Ground thickness side (Wood style)
    paint.color = const Color(0xFFB45309); // Wood brown thickness
    final pathSide = Path()
      ..moveTo(size.width * 0.12, size.height * 0.62)
      ..lineTo(size.width * 0.5, size.height * 0.8)
      ..lineTo(size.width * 0.88, size.height * 0.62)
      ..lineTo(size.width * 0.88, size.height * 0.68)
      ..lineTo(size.width * 0.5, size.height * 0.86)
      ..lineTo(size.width * 0.12, size.height * 0.68)
      ..close();
    canvas.drawPath(pathSide, paint);

    // House 1 (Center)
    paint.color = const Color(0xFFFDBA74); // Orange walls
    final wallCenter = Path()
      ..moveTo(size.width * 0.4, size.height * 0.52)
      ..lineTo(size.width * 0.55, size.height * 0.45)
      ..lineTo(size.width * 0.55, size.height * 0.58)
      ..lineTo(size.width * 0.4, size.height * 0.65)
      ..close();
    canvas.drawPath(wallCenter, paint);

    paint.color = const Color(0xFFF97316); // Left dark wall
    final wallLeft = Path()
      ..moveTo(size.width * 0.4, size.height * 0.52)
      ..lineTo(size.width * 0.28, size.height * 0.47)
      ..lineTo(size.width * 0.28, size.height * 0.6)
      ..lineTo(size.width * 0.4, size.height * 0.65)
      ..close();
    canvas.drawPath(wallLeft, paint);

    // Roof (Red)
    paint.color = const Color(0xFFEF4444);
    final roof = Path()
      ..moveTo(size.width * 0.4, size.height * 0.42)
      ..lineTo(size.width * 0.58, size.height * 0.35)
      ..lineTo(size.width * 0.55, size.height * 0.45)
      ..lineTo(size.width * 0.4, size.height * 0.52)
      ..lineTo(size.width * 0.25, size.height * 0.47)
      ..close();
    canvas.drawPath(roof, paint);

    // Tiny trees (Green circles with brown stem)
    paint.color = const Color(0xFF059669); // Tree green
    canvas.drawCircle(
      Offset(size.width * 0.72, size.height * 0.5),
      size.width * 0.08,
      paint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.78, size.height * 0.53),
      size.width * 0.06,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// 6. JEM Court/Emblem Painter (Courthouse/masjid dome and columns)
class JemCourtPainter extends CustomPainter {
  const JemCourtPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..isAntiAlias = true;

    // Wooden stand/base
    paint.color = const Color(0xFFD97706); // Wood brown stand base
    paint.style = PaintingStyle.fill;
    final pathBase = Path()
      ..moveTo(size.width * 0.2, size.height * 0.72)
      ..lineTo(size.width * 0.5, size.height * 0.82)
      ..lineTo(size.width * 0.8, size.height * 0.72)
      ..lineTo(size.width * 0.5, size.height * 0.62)
      ..close();
    canvas.drawPath(pathBase, paint);

    // Thickness
    paint.color = const Color(0xFFB45309);
    final pathThick = Path()
      ..moveTo(size.width * 0.2, size.height * 0.72)
      ..lineTo(size.width * 0.5, size.height * 0.82)
      ..lineTo(size.width * 0.8, size.height * 0.72)
      ..lineTo(size.width * 0.8, size.height * 0.77)
      ..lineTo(size.width * 0.5, size.height * 0.87)
      ..lineTo(size.width * 0.2, size.height * 0.77)
      ..close();
    canvas.drawPath(pathThick, paint);

    // Building Base block (Cream/Beige)
    paint.color = const Color(0xFFF3EAE2); // Warm stone
    final pathBuilding = Path()
      ..moveTo(size.width * 0.3, size.height * 0.6)
      ..lineTo(size.width * 0.5, size.height * 0.67)
      ..lineTo(size.width * 0.7, size.height * 0.6)
      ..lineTo(size.width * 0.7, size.height * 0.48)
      ..lineTo(size.width * 0.5, size.height * 0.42)
      ..lineTo(size.width * 0.3, size.height * 0.48)
      ..close();
    canvas.drawPath(pathBuilding, paint);

    // Columns/Pillars (Wood dark accent)
    paint.color = const Color(0xFFD1C4E9); // Light purple stone accent
    paint.strokeWidth = 2.5;
    paint.style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(size.width * 0.36, size.height * 0.52),
      Offset(size.width * 0.36, size.height * 0.61),
      paint,
    );
    canvas.drawLine(
      Offset(size.width * 0.5, size.height * 0.55),
      Offset(size.width * 0.5, size.height * 0.66),
      paint,
    );
    canvas.drawLine(
      Offset(size.width * 0.64, size.height * 0.52),
      Offset(size.width * 0.64, size.height * 0.61),
      paint,
    );

    // Main Golden Dome on top
    paint.style = PaintingStyle.fill;
    paint.color = const Color(0xFFFBBF24); // Golden dome
    final domePath = Path()
      ..moveTo(size.width * 0.38, size.height * 0.45)
      ..quadraticBezierTo(
        size.width * 0.38,
        size.height * 0.24,
        size.width * 0.5,
        size.height * 0.22,
      )
      ..quadraticBezierTo(
        size.width * 0.62,
        size.height * 0.24,
        size.width * 0.62,
        size.height * 0.45,
      )
      ..close();
    canvas.drawPath(domePath, paint);

    // Dome tip/crescent
    paint.color = const Color(0xFFB45309);
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 1.5;
    canvas.drawLine(
      Offset(size.width * 0.5, size.height * 0.22),
      Offset(size.width * 0.5, size.height * 0.15),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
