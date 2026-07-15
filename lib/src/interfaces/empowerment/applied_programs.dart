import 'package:flutter/material.dart';
import 'package:jamiat/src/data/constants/color_constants.dart';
import 'package:jamiat/src/data/constants/style_constants.dart';
import 'package:jamiat/src/data/services/haptic_helper.dart';
import 'package:jamiat/src/data/services/navigation_services.dart';
import 'package:jamiat/src/interfaces/empowerment/empowerment_programs.dart';

class AppliedProgramsScreen extends StatefulWidget {
  final int initialTab;

  const AppliedProgramsScreen({super.key, this.initialTab = 0});

  @override
  State<AppliedProgramsScreen> createState() => _AppliedProgramsScreenState();
}

class _AppliedProgramsScreenState extends State<AppliedProgramsScreen> {
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

  Widget _buildProgramList(
    List<Map<String, String>> list,
    String emptyMessage,
  ) {
    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.assignment_outlined, size: 64, color: kMutedText),
            const SizedBox(height: 16),
            Text(
              emptyMessage,
              style: kEmptyStateM,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final program = list[index];
        final isApplied = EmpowermentProgramsScreen.appliedProgramIds.contains(
          program['id'],
        );
        final isSaved = EmpowermentProgramsScreen.savedProgramIds.contains(
          program['id'],
        );

        return GestureDetector(
          onTap: () {
            HapticHelper.impact(HapticImpact.light);
            NavigationService()
                .pushNamed(
                  'ProgramDetails',
                  arguments: {'programId': program['id']},
                )
                .then((_) {
                  setState(() {});
                });
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: kWhite,
              borderRadius: BorderRadius.circular(kCardRadiusLg),
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
                // Image with overlays
                SizedBox(
                  height: 150,
                  width: double.infinity,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset(program['image']!, fit: BoxFit.cover),
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
                                color: kBlack.withValues(alpha: 0.4),
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
                                HapticHelper.impact(HapticImpact.light);
                                setState(() {
                                  if (isSaved) {
                                    EmpowermentProgramsScreen.savedProgramIds
                                        .remove(program['id']!);
                                  } else {
                                    EmpowermentProgramsScreen.savedProgramIds
                                        .add(program['id']!);
                                  }
                                });
                              },
                              child: Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: kBlack.withValues(alpha: 0.4),
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

                // Card Details
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                        style: kCaption12R.copyWith(color: kSecondaryTextColor),
                      ),
                      const SizedBox(height: 14),
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
                                      HapticHelper.impact(HapticImpact.light);
                                      _applyProgram(program);
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: kPrimaryColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                ),
                                elevation: 0,
                              ),
                              child: Text(
                                isApplied ? 'Applied' : 'Apply',
                                style: kCaption12M.copyWith(
                                  color: isApplied ? kMutedText : kWhite,
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final appliedProgramsList = EmpowermentProgramsScreen.programs
        .where(
          (p) => EmpowermentProgramsScreen.appliedProgramIds.contains(p['id']),
        )
        .toList();

    final savedProgramsList = EmpowermentProgramsScreen.programs
        .where(
          (p) => EmpowermentProgramsScreen.savedProgramIds.contains(p['id']),
        )
        .toList();

    return DefaultTabController(
      initialIndex: widget.initialTab,
      length: 2,
      child: Scaffold(
        backgroundColor: kWhite,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
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
                      'Empowerment Programs',
                      style: kHeadTitleB.copyWith(
                        color: kTextColor,
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
              ),

              // TabBar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: TabBar(
                  labelColor: kPrimaryColor,
                  unselectedLabelColor: kSecondaryTextColor,
                  labelStyle: kLabel15SB,
                  unselectedLabelStyle: kLabel15M,
                  indicatorColor: kPrimaryColor,
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicatorWeight: 2.5,
                  dividerColor: kBorder,
                  tabs: const [
                    Tab(text: 'Applied Programs'),
                    Tab(text: 'Saved'),
                  ],
                ),
              ),

              // TabBarView content
              Expanded(
                child: TabBarView(
                  children: [
                    _buildProgramList(
                      appliedProgramsList,
                      'No applied programs yet',
                    ),
                    _buildProgramList(
                      savedProgramsList,
                      'No saved programs yet',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
