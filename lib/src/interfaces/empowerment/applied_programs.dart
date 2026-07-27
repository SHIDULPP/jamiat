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

class AppliedProgramsScreen extends ConsumerStatefulWidget {
  final int initialTab;

  const AppliedProgramsScreen({super.key, this.initialTab = 0});

  @override
  ConsumerState<AppliedProgramsScreen> createState() =>
      _AppliedProgramsScreenState();
}

class _AppliedProgramsScreenState extends ConsumerState<AppliedProgramsScreen> {
  late int _selectedTab;

  @override
  void initState() {
    super.initState();
    _selectedTab = widget.initialTab.clamp(0, 1);
  }

  Widget _headerCircleButton({
    required Widget child,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: kWhite,
          border: Border.all(color: kGrey, width: 1.25),
        ),
        alignment: Alignment.center,
        child: child,
      ),
    );
  }

  Widget _buildProgramList(
    BuildContext context,
    List<EmpowermentProgramModel> list,
    String emptyMessage,
  ) {
    if (list.isEmpty) {
      return Center(child: Text(emptyMessage, style: kEmptyStateM));
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(
        kScreenPaddingH,
        8,
        kScreenPaddingH,
        16,
      ),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final program = list[index];
        return GestureDetector(
          onTap: () {
            HapticHelper.impact(HapticImpact.light);
            NavigationService().pushNamed(
              'ProgramDetails',
              arguments: {
                'programId': program.id,
                'isApplied': _selectedTab == 0,
              },
            );
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: kWhite,
              borderRadius: BorderRadius.circular(kCardRadiusMd),
              border: Border.all(color: kCardBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(program.title, style: kSectionTitleSB),
                const SizedBox(height: 6),
                Text(
                  program.description,
                  style: kCaption12R.copyWith(
                    color: kSecondaryTextColor,
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (program.startDate != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Starts ${formatDateLabel(program.startDate)}',
                    style: kCaption12R.copyWith(color: kTextColor),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _tabChip({
    required String label,
    required bool active,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: active ? kSecondaryColor : kWhite,
          borderRadius: BorderRadius.circular(kCardRadiusSm),
          border: Border.all(
            color: active
                ? kSecondaryColor
                : kSecondaryColor.withValues(alpha: 0.45),
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: kCaption12M.copyWith(
            color: active ? kTextColor : kMutedText,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appliedAsync = ref.watch(empowermentProgramsProvider('applied'));
    final savedAsync = ref.watch(empowermentProgramsProvider('saved'));

    return Scaffold(
      backgroundColor: kWhite,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                kScreenPaddingH,
                8,
                kScreenPaddingH,
                16,
              ),
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
                  const SizedBox(width: 8),
                  Text('Empowerment Programs', style: kSectionTitleSB),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: kScreenPaddingH),
              child: Row(
                children: [
                  _tabChip(
                    label: 'Applied Programs',
                    active: _selectedTab == 0,
                    onTap: () => setState(() => _selectedTab = 0),
                  ),
                  const SizedBox(width: 10),
                  _tabChip(
                    label: 'Saved',
                    active: _selectedTab == 1,
                    onTap: () => setState(() => _selectedTab = 1),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _selectedTab == 0
                  ? AsyncContent(
                      asyncValue: appliedAsync,
                      onRetry: () => ref.invalidate(
                        empowermentProgramsProvider('applied'),
                      ),
                      builder: (page) => _buildProgramList(
                        context,
                        page.items,
                        'No applied programs yet',
                      ),
                    )
                  : AsyncContent(
                      asyncValue: savedAsync,
                      onRetry: () =>
                          ref.invalidate(empowermentProgramsProvider('saved')),
                      builder: (page) => _buildProgramList(
                        context,
                        page.items,
                        'No saved programs yet',
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
