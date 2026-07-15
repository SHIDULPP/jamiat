import 'package:flutter/material.dart';
import 'package:jamiat/src/data/constants/color_constants.dart';
import 'package:jamiat/src/data/constants/style_constants.dart';
import 'package:jamiat/src/data/services/haptic_helper.dart';
import 'package:jamiat/src/data/services/navigation_services.dart';

class EmpowermentProgramsScreen extends StatefulWidget {
  const EmpowermentProgramsScreen({super.key});

  // Local state for applied and saved programs
  static final Set<String> appliedProgramIds = {};
  static final Set<String> savedProgramIds = {};

  static const List<Map<String, String>> programs = [
    {
      'id': '1',
      'title': 'Tailoring & Fashion',
      'subtitle':
          'Lorem ipsum dolor sit amet consectetur. Turpis cursus et quisque enim sit leo vitae.',
      'date': 'Starts 15 Jul',
      'location': 'Ernakulam Town Hall',
      'image': 'assets/jpgs/campaign_welfare.jpg',
    },
    {
      'id': '2',
      'title': 'Small Business startup program',
      'subtitle':
          'Lorem ipsum dolor sit amet consectetur. Turpis cursus et quisque enim sit leo vitae.',
      'date': 'Starts 30 Aug',
      'location': 'Kozhikode Jamiat Hall',
      'image': 'assets/jpgs/campaign_education.jpg',
    },
    {
      'id': '3',
      'title': 'Digital Skill Bootcamp',
      'subtitle':
          'For skill building, coding, UI/UX design, and cyber security courses.',
      'date': 'Starts 10 Oct',
      'location': 'Cochin Tech Hub',
      'image': 'assets/jpgs/campaign_education.jpg',
    },
  ];

  @override
  State<EmpowermentProgramsScreen> createState() =>
      _EmpowermentProgramsScreenState();
}

class _EmpowermentProgramsScreenState extends State<EmpowermentProgramsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

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
    final filtered = EmpowermentProgramsScreen.programs.where((item) {
      if (_searchQuery.isEmpty) return true;
      final title = item['title']!.toLowerCase();
      final subtitle = item['subtitle']!.toLowerCase();
      return title.contains(_searchQuery) || subtitle.contains(_searchQuery);
    }).toList();

    return Scaffold(
      backgroundColor: kWhite,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
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
                  Expanded(
                    child: Text(
                      'Empowerment Programs',
                      style: kHeadTitleB.copyWith(
                        color: kTextColor,
                        fontSize: 20,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: kBorder, width: 1.25),
                      ),
                      child: const Icon(
                        Icons.more_vert,
                        color: kTextColor,
                        size: 20,
                      ),
                    ),
                    color: kWhite,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 3,
                    onSelected: (value) {
                      HapticHelper.impact(HapticImpact.light);
                      if (value == 'applied') {
                        NavigationService().pushNamed(
                          'AppliedPrograms',
                          arguments: {'initialTab': 0},
                        );
                      } else if (value == 'saved') {
                        NavigationService().pushNamed(
                          'AppliedPrograms',
                          arguments: {'initialTab': 1},
                        );
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'applied',
                        child: Text(
                          'Applied Programs',
                          style: kBodyTitleR.copyWith(
                            color: kTextColor,
                            fontSize: 14.5,
                          ),
                        ),
                      ),
                      PopupMenuItem(
                        value: 'saved',
                        child: Text(
                          'Saved',
                          style: kBodyTitleR.copyWith(
                            color: kTextColor,
                            fontSize: 14.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Search programs bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Container(
                decoration: BoxDecoration(
                  color: kWhite,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: kBorder, width: 1.25),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    const Icon(Icons.search, color: kMutedText, size: 22),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        style: kBodyTitleR.copyWith(color: kTextColor),
                        decoration: InputDecoration(
                          hintText: 'Search for programs',
                          hintStyle: kBodyTitleR.copyWith(
                            color: kMutedText,
                            fontSize: 15,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Scrollable programs list
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Text('No programs found', style: kEmptyStateM),
                    )
                  : ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final program = filtered[index];
                        final isApplied = EmpowermentProgramsScreen
                            .appliedProgramIds
                            .contains(program['id']);
                        final isSaved = EmpowermentProgramsScreen
                            .savedProgramIds
                            .contains(program['id']);

                        return GestureDetector(
                          onTap: () {
                            HapticHelper.impact(HapticImpact.light);
                            NavigationService()
                                .pushNamed(
                                  'ProgramDetails',
                                  arguments: {'programId': program['id']},
                                )
                                .then((_) {
                                  // Trigger reload in case they applied inside details
                                  setState(() {});
                                });
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 20),
                            decoration: BoxDecoration(
                              color: kWhite,
                              borderRadius: BorderRadius.circular(
                                kCardRadiusLg,
                              ),
                              border: Border.all(color: kBorder),
                              boxShadow: [
                                BoxShadow(
                                  color: kBlack.withValues(alpha: 0.03),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Cover Image with Action Overlays
                                SizedBox(
                                  height: 150,
                                  width: double.infinity,
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      Image.asset(
                                        program['image']!,
                                        fit: BoxFit.cover,
                                      ),
                                      Positioned(
                                        top: 12,
                                        right: 12,
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 36,
                                              height: 36,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: kBlack.withValues(
                                                  alpha: 0.4,
                                                ),
                                              ),
                                              child: const Icon(
                                                Icons.share_outlined,
                                                color: kWhite,
                                                size: 18,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            GestureDetector(
                                              onTap: () {
                                                HapticHelper.impact(
                                                  HapticImpact.light,
                                                );
                                                setState(() {
                                                  if (isSaved) {
                                                    EmpowermentProgramsScreen
                                                        .savedProgramIds
                                                        .remove(program['id']!);
                                                  } else {
                                                    EmpowermentProgramsScreen
                                                        .savedProgramIds
                                                        .add(program['id']!);
                                                  }
                                                });
                                              },
                                              child: Container(
                                                width: 36,
                                                height: 36,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: kBlack.withValues(
                                                    alpha: 0.4,
                                                  ),
                                                ),
                                                child: Icon(
                                                  isSaved
                                                      ? Icons.bookmark
                                                      : Icons.bookmark_border,
                                                  color: isSaved
                                                      ? const Color(0xFF10B981)
                                                      : kWhite,
                                                  size: 18,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Details area
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        program['title']!,
                                        style: kBodyTitleB.copyWith(
                                          fontSize: 16,
                                          color: kTextColor,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        program['subtitle']!,
                                        style: kCaption12R.copyWith(
                                          color: kSecondaryTextColor,
                                        ),
                                      ),
                                      const SizedBox(height: 14),

                                      // Row showing Date and CTA Apply button
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.calendar_today_outlined,
                                            size: 16,
                                            color: kMutedText,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            program['date']!,
                                            style: kCaption12R.copyWith(
                                              color: kTextColor,
                                              fontWeight: kMedium,
                                            ),
                                          ),
                                          const Spacer(),
                                          SizedBox(
                                            height: 36,
                                            child: ElevatedButton(
                                              onPressed: isApplied
                                                  ? null
                                                  : () {
                                                      HapticHelper.impact(
                                                        HapticImpact.light,
                                                      );
                                                      _applyProgram(program);
                                                    },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: kPrimaryColor,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 20,
                                                    ),
                                                elevation: 0,
                                              ),
                                              child: Text(
                                                isApplied ? 'Applied' : 'Apply',
                                                style: kCaption12M.copyWith(
                                                  color: isApplied
                                                      ? kMutedText
                                                      : kWhite,
                                                  fontWeight: kBold,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
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
    );
  }
}
