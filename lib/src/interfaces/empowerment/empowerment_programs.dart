import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
                  Expanded(
                    child: Text(
                      'Empowerment Programs',
                      style: kHeadTitleB.copyWith(
                        color: kTextColor,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      NavigationService().pushNamed('AppliedPrograms');
                    },
                    icon: const Icon(Icons.bookmark_border),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: TextField(
                controller: _searchController,
                onChanged: (v) => setState(() => _searchQuery = v.trim()),
                decoration: InputDecoration(
                  hintText: 'Search programs',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
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
                    padding: const EdgeInsets.symmetric(horizontal: 24),
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
                            borderRadius: BorderRadius.circular(kCardRadiusLg),
                            border: Border.all(color: kBorder),
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
                                    child: IconButton(
                                      onPressed: () => _toggleSave(program),
                                      icon: Icon(
                                        program.isBookmarked
                                            ? Icons.bookmark
                                            : Icons.bookmark_border,
                                        color: kWhite,
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
                                    Text(program.title, style: kBodyTitleB),
                                    const SizedBox(height: 6),
                                    Text(
                                      program.description,
                                      style: kCaption12R.copyWith(
                                        color: kSecondaryTextColor,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        Text(
                                          program.startDate != null
                                              ? 'Starts ${formatDateLabel(program.startDate)}'
                                              : '',
                                          style: kCaption12R,
                                        ),
                                        const Spacer(),
                                        ElevatedButton(
                                          onPressed: program.isApplied
                                              ? null
                                              : () => _apply(program),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: kPrimaryColor,
                                            foregroundColor: kWhite,
                                          ),
                                          child: Text(
                                            program.isApplied
                                                ? 'Applied'
                                                : 'Apply',
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
