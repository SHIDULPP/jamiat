import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jamiat/src/data/apis/empowerment_api.dart';
import 'package:jamiat/src/data/constants/color_constants.dart';
import 'package:jamiat/src/data/constants/style_constants.dart';
import 'package:jamiat/src/data/providers/empowerment_provider.dart';
import 'package:jamiat/src/data/services/haptic_helper.dart';
import 'package:jamiat/src/data/utils/format_helpers.dart';
import 'package:jamiat/src/interfaces/components/async_content.dart';

class ProgramDetailsScreen extends ConsumerWidget {
  final String programId;

  const ProgramDetailsScreen({super.key, required this.programId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final programAsync = ref.watch(empowermentProgramDetailProvider(programId));

    return Scaffold(
      backgroundColor: kWhite,
      body: SafeArea(
        child: Column(
          children: [
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
                  Text(
                    'Program details',
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
                asyncValue: programAsync,
                onRetry: () =>
                    ref.invalidate(empowermentProgramDetailProvider(programId)),
                builder: (program) => SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (program.image != null &&
                          program.image!.startsWith('http'))
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.network(
                            program.image!,
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        )
                      else
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.asset(
                            'assets/jpgs/campaign_welfare.jpg',
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                      const SizedBox(height: 16),
                      Text(
                        program.title,
                        style: kSectionTitleSB.copyWith(fontSize: 20),
                      ),
                      const SizedBox(height: 8),
                      if (program.startDate != null)
                        Text(
                          'Starts ${formatDateLabel(program.startDate)}',
                          style: kCaption12R.copyWith(
                            color: kSecondaryTextColor,
                          ),
                        ),
                      const SizedBox(height: 16),
                      Text(
                        program.description,
                        style: kBodyTitleR.copyWith(
                          color: kText2Color,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: program.isApplied
                            ? null
                            : () async {
                                HapticHelper.impact(HapticImpact.medium);
                                final res = await ref
                                    .read(empowermentApiProvider)
                                    .applyForProgram(program.id);
                                if (!context.mounted) return;
                                if (res.success) {
                                  ref.invalidate(
                                    empowermentProgramDetailProvider(programId),
                                  );
                                  ref.invalidate(
                                    empowermentProgramsProvider('all'),
                                  );
                                  ref.invalidate(
                                    empowermentProgramsProvider('applied'),
                                  );
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Application submitted'),
                                    ),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        res.message ?? 'Failed to apply',
                                      ),
                                    ),
                                  );
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kPrimaryColor,
                          foregroundColor: kWhite,
                          minimumSize: const Size.fromHeight(52),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Text(
                          program.isApplied ? 'Applied' : 'Apply Now',
                          style: kButtonLabelSB,
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
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
