import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jamiat/src/data/constants/color_constants.dart';
import 'package:jamiat/src/data/constants/style_constants.dart';
import 'package:jamiat/src/data/models/empowerment_model.dart';
import 'package:jamiat/src/data/providers/empowerment_provider.dart';
import 'package:jamiat/src/data/services/haptic_helper.dart';
import 'package:jamiat/src/data/services/navigation_services.dart';
import 'package:jamiat/src/data/utils/format_helpers.dart';
import 'package:jamiat/src/interfaces/components/async_content.dart';

class AppliedProgramsScreen extends ConsumerWidget {
  final int initialTab;

  const AppliedProgramsScreen({super.key, this.initialTab = 0});

  Widget _buildProgramList(
    BuildContext context,
    List<EmpowermentProgramModel> list,
    String emptyMessage,
  ) {
    if (list.isEmpty) {
      return Center(child: Text(emptyMessage, style: kEmptyStateM));
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final program = list[index];
        return GestureDetector(
          onTap: () {
            HapticHelper.impact(HapticImpact.light);
            NavigationService().pushNamed(
              'ProgramDetails',
              arguments: {'programId': program.id},
            );
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: kWhite,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: kBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(program.title, style: kBodyTitleB),
                const SizedBox(height: 6),
                Text(
                  program.description,
                  style: kCaption12R.copyWith(color: kSecondaryTextColor),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (program.startDate != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Starts ${formatDateLabel(program.startDate)}',
                    style: kCaption12R,
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appliedAsync = ref.watch(empowermentProgramsProvider('applied'));
    final savedAsync = ref.watch(empowermentProgramsProvider('saved'));

    return DefaultTabController(
      initialIndex: initialTab,
      length: 2,
      child: Scaffold(
        backgroundColor: kWhite,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: TabBar(
                  labelColor: kPrimaryColor,
                  unselectedLabelColor: kSecondaryTextColor,
                  indicatorColor: kPrimaryColor,
                  tabs: [
                    Tab(text: 'Applied Programs'),
                    Tab(text: 'Saved'),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    AsyncContent(
                      asyncValue: appliedAsync,
                      onRetry: () => ref.invalidate(
                        empowermentProgramsProvider('applied'),
                      ),
                      builder: (page) => _buildProgramList(
                        context,
                        page.items,
                        'No applied programs yet',
                      ),
                    ),
                    AsyncContent(
                      asyncValue: savedAsync,
                      onRetry: () =>
                          ref.invalidate(empowermentProgramsProvider('saved')),
                      builder: (page) => _buildProgramList(
                        context,
                        page.items,
                        'No saved programs yet',
                      ),
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
