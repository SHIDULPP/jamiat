import 'package:flutter/material.dart';
import 'package:jamiat/src/data/constants/color_constants.dart';
import 'package:jamiat/src/data/constants/style_constants.dart';
import 'package:jamiat/src/data/services/haptic_helper.dart';
import 'package:jamiat/src/interfaces/empowerment/empowerment_programs.dart';

class ProgramDetailsScreen extends StatefulWidget {
  final String programId;

  const ProgramDetailsScreen({super.key, required this.programId});

  @override
  State<ProgramDetailsScreen> createState() => _ProgramDetailsScreenState();
}

class _ProgramDetailsScreenState extends State<ProgramDetailsScreen> {
  // Mock data map
  Map<String, String> _getProgramData() {
    switch (widget.programId) {
      case '2':
        return {
          'id': '2',
          'title': 'Small Business startup program',
          'subtitle':
              'Lorem ipsum dolor sit amet consectetur. Turpis cursus et quisque enim sit leo vitae.',
          'date': 'Starts 30 Aug',
          'location': 'Kozhikode Jamiat Hall',
          'image': 'assets/jpgs/campaign_education.jpg',
        };
      case '3':
        return {
          'id': '3',
          'title': 'Digital Skill Bootcamp',
          'subtitle':
              'For skill building, coding, UI/UX design, and cyber security courses.',
          'date': 'Starts 10 Oct',
          'location': 'Cochin Tech Hub',
          'image': 'assets/jpgs/campaign_education.jpg',
        };
      case '1':
      default:
        return {
          'id': '1',
          'title': 'Tailoring & Fashion',
          'subtitle':
              'Lorem ipsum dolor sit amet consectetur. Turpis cursus et quisque enim sit leo vitae.',
          'date': 'Starts 15 Jul',
          'location': 'Ernakulam Town Hall',
          'image': 'assets/jpgs/campaign_welfare.jpg',
        };
    }
  }

  void _applyProgram(Map<String, String> program) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Application Submitted',
            style: kHeadTitleB.copyWith(color: kTextColor, fontSize: 18),
          ),
          content: Text(
            'You have successfully applied for ${program['title']}. We will notify you once your application is reviewed.',
            style: kCaption12R.copyWith(
              color: kSecondaryTextColor,
              fontSize: 13.5,
              height: 1.4,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  EmpowermentProgramsScreen.appliedProgramIds.add(
                    program['id']!,
                  );
                });
              },
              child: Text('OK', style: kLinkSB.copyWith(fontSize: 15)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final program = _getProgramData();
    final isApplied = EmpowermentProgramsScreen.appliedProgramIds.contains(
      program['id'],
    );
    final isSaved = EmpowermentProgramsScreen.savedProgramIds.contains(
      program['id'],
    );

    return Scaffold(
      backgroundColor: kWhite,
      body: SafeArea(
        child: Column(
          children: [
            // Custom Header Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                  Text(
                    'Program Details',
                    style: kHeadTitleB.copyWith(
                      color: kTextColor,
                      fontSize: 18,
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: kWhite,
                          border: Border.all(color: kBorder, width: 1.25),
                        ),
                        child: const Icon(
                          Icons.share_outlined,
                          color: kTextColor,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: () {
                          HapticHelper.impact(HapticImpact.light);
                          setState(() {
                            if (isSaved) {
                              EmpowermentProgramsScreen.savedProgramIds.remove(
                                program['id']!,
                              );
                            } else {
                              EmpowermentProgramsScreen.savedProgramIds.add(
                                program['id']!,
                              );
                            }
                          });
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: kWhite,
                            border: Border.all(color: kBorder, width: 1.25),
                          ),
                          child: Icon(
                            isSaved ? Icons.bookmark : Icons.bookmark_border,
                            color: isSaved
                                ? const Color(0xFF10B981)
                                : kTextColor,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Banner Image
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.asset(
                        program['image']!,
                        height: 220,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 220,
                            color: kScreenBg,
                            child: const Icon(
                              Icons.image_outlined,
                              color: kMutedText,
                              size: 40,
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Program Title
                    Text(
                      program['title']!,
                      style: kHeadTitleB.copyWith(
                        color: kTextColor,
                        fontSize: 22,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Starts Info Row
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today_outlined,
                          size: 18,
                          color: kMutedText,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Starts ',
                          style: kCaption12R.copyWith(
                            color: kSecondaryTextColor,
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          program['date']!.replaceAll('Starts ', ''),
                          style: kBodyTitleB.copyWith(
                            color: kTextColor,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Location Info Row
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 18,
                          color: kMutedText,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          program['location']!,
                          style: kCaption12R.copyWith(
                            color: kTextColor,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // About Program Section
                    Text(
                      'About Program',
                      style: kSectionTitleSB.copyWith(
                        color: kTextColor,
                        fontSize: 16,
                        fontWeight: kBold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Lorem ipsum dolor sit amet consectetur. Tortor cursus viverra convallis cursus. Morbi egestas dapibus scelerisque accumsan sed scelerisque.\n\nProviding comprehensive hands-on guidance under standard industry practices to boost vocational skills and enable self-reliance.',
                      style: kCaption12R.copyWith(
                        color: kSecondaryTextColor,
                        height: 1.5,
                        fontSize: 13.5,
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),

            // Sticky Bottom Apply Button
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: isApplied
                      ? null
                      : () {
                          HapticHelper.impact(HapticImpact.light);
                          _applyProgram(program);
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    isApplied ? 'Applied' : 'Apply',
                    style: kButtonLabelSB.copyWith(color: kWhite, fontSize: 16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
