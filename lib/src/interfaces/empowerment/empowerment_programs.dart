import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:jamiat/src/data/apis/empowerment_api.dart';
import 'package:jamiat/src/data/constants/color_constants.dart';
import 'package:jamiat/src/data/constants/style_constants.dart';
import 'package:jamiat/src/data/models/empowerment_model.dart';
import 'package:jamiat/src/data/providers/empowerment_provider.dart';
import 'package:jamiat/src/data/services/haptic_helper.dart';
import 'package:jamiat/src/data/services/navigation_services.dart';
import 'package:jamiat/src/data/utils/format_helpers.dart';
import 'package:jamiat/src/interfaces/components/async_content.dart';

class EmpowermentProgramsScreen extends ConsumerStatefulWidget {
  const EmpowermentProgramsScreen({super.key});

  @override
  ConsumerState<EmpowermentProgramsScreen> createState() =>
      _EmpowermentProgramsScreenState();
}

class _EmpowermentProgramsScreenState
    extends ConsumerState<EmpowermentProgramsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedChip = 'All';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<EmpowermentProgramModel> _filter(List<EmpowermentProgramModel> items) {
    if (_searchQuery.isEmpty) return items;
    final q = _searchQuery.toLowerCase();
    return items.where((p) {
      return p.title.toLowerCase().contains(q) ||
          p.description.toLowerCase().contains(q);
    }).toList();
  }

  Future<void> _apply(EmpowermentProgramModel program) async {
    final res = await ref
        .read(empowermentApiProvider)
        .applyForProgram(program.id);
    if (!mounted) return;
    if (res.success) {
      ref.invalidate(empowermentProgramsProvider('all'));
      ref.invalidate(empowermentProgramsProvider('applied'));
      showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Application Submitted'),
          content: Text('You have successfully applied for ${program.title}.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(res.message ?? 'Failed to apply')));
    }
  }

  Future<void> _toggleSave(EmpowermentProgramModel program) async {
    final api = ref.read(empowermentApiProvider);
    final res = program.isBookmarked
        ? await api.unsaveProgram(program.id)
        : await api.saveProgram(program.id);
    if (res.success) {
      ref.invalidate(empowermentProgramsProvider('all'));
      ref.invalidate(empowermentProgramsProvider('saved'));
    }
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

  Widget _image(String? url) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: url != null && url.startsWith('http')
          ? Image.network(
              url,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(
                color: kScreenBg,
                child: const Icon(Icons.image_outlined, color: kMutedText),
              ),
            )
          : Image.asset(
              url ?? 'assets/jpgs/campaign_welfare.jpg',
              fit: BoxFit.cover,
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final programsAsync = ref.watch(empowermentProgramsProvider('all'));

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
                0,
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
                  Expanded(
                    child: Text(
                      'Empowerment Programs',
                      style: kSectionTitleSB,
                    ),
                  ),
                  _headerCircleButton(
                    onTap: () {
                      HapticHelper.impact(HapticImpact.light);
                      NavigationService().pushNamed('AppliedPrograms');
                    },
                    child: SvgPicture.asset(
                      'assets/svg/bookmark.svg',
                      width: 18,
                      height: 18,
                      colorFilter: const ColorFilter.mode(
                        kTextColor,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: kScreenPaddingH),
              child: Container(
                height: 56,
                decoration: BoxDecoration(
                  color: kWhite,
                  borderRadius: BorderRadius.circular(kCardRadiusMd),
                  border: Border.all(color: kCardBorder),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    const Icon(Icons.search, color: kMutedText, size: 22),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: (v) =>
                            setState(() => _searchQuery = v.trim()),
                        decoration: InputDecoration(
                          hintText: 'Search programs',
                          hintStyle: kBodyTitleR.copyWith(
                            color: kSecondaryTextColor,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 30,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: kScreenPaddingH,
                ),
                children: [
                  for (final label in const [
                    'All',
                    'Education',
                    'Skill',
                    'Career',
                    'Youth',
                  ]) ...[
                    if (label != 'All') const SizedBox(width: 12),
                    _CategoryChip(
                      label: label,
                      selected: _selectedChip == label,
                      onTap: () => setState(() => _selectedChip = label),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: AsyncContent(
                asyncValue: programsAsync,
                onRetry: () =>
                    ref.invalidate(empowermentProgramsProvider('all')),
                builder: (page) {
                  final programs = _filter(page.items);
                  if (programs.isEmpty) {
                    return Center(
                      child: Text('No programs found', style: kEmptyStateM),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: kScreenPaddingH,
                    ),
                    itemCount: programs.length,
                    itemBuilder: (context, index) {
                      final program = programs[index];
                      return GestureDetector(
                        onTap: () {
                          NavigationService().pushNamed(
                            'ProgramDetails',
                            arguments: {
                              'programId': program.id,
                              'isApplied': program.isApplied,
                            },
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 20),
                          decoration: BoxDecoration(
                            color: kWhite,
                            borderRadius:
                                BorderRadius.circular(kCardRadiusLg),
                            border: Border.all(color: kCardBorder),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Stack(
                                children: [
                                  _image(program.image),
                                  Positioned(
                                    top: 10,
                                    right: 10,
                                    child: Material(
                                      color: kBlack.withValues(alpha: 0.35),
                                      shape: const CircleBorder(),
                                      child: InkWell(
                                        customBorder: const CircleBorder(),
                                        onTap: () {
                                          HapticHelper.impact(
                                            HapticImpact.light,
                                          );
                                          _toggleSave(program);
                                        },
                                        child: SizedBox(
                                          width: 36,
                                          height: 36,
                                          child: Center(
                                            child: SvgPicture.asset(
                                              'assets/svg/bookmark.svg',
                                              width: 16,
                                              height: 16,
                                              colorFilter: ColorFilter.mode(
                                                program.isBookmarked
                                                    ? kPrimaryColor
                                                    : kWhite,
                                                BlendMode.srcIn,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.all(14),
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
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        if (program.startDate != null)
                                          Expanded(
                                            child: Text(
                                              'Starts ${formatDateLabel(program.startDate)}',
                                              style: kCaption12R.copyWith(
                                                color: kTextColor,
                                              ),
                                            ),
                                          )
                                        else
                                          const Spacer(),
                                        SizedBox(
                                          height: 40,
                                          child: ElevatedButton(
                                            onPressed: program.isApplied
                                                ? null
                                                : () {
                                                    HapticHelper.impact(
                                                      HapticImpact.medium,
                                                    );
                                                    _apply(program);
                                                  },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: kPrimaryColor,
                                              foregroundColor: kWhite,
                                              disabledBackgroundColor:
                                                  kPrimaryColor.withValues(
                                                alpha: 0.6,
                                              ),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 20,
                                              ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                  kCardRadiusSm,
                                                ),
                                              ),
                                              elevation: 0,
                                            ),
                                            child: Text(
                                              program.isApplied
                                                  ? 'Applied'
                                                  : 'Apply',
                                              style: kButtonLabelSB,
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
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? kSecondaryColor
              : kSecondaryColor.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: kSecondaryColor),
        ),
        child: Text(
          label,
          style: kCaption12M.copyWith(
            color: selected ? kTextColor : kSecondaryTextColor,
            height: 1.2,
          ),
        ),
      ),
    );
  }
}
