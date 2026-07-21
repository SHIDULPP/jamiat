import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jamiat/src/data/constants/color_constants.dart';
import 'package:jamiat/src/data/constants/style_constants.dart';
import 'package:jamiat/src/data/models/welfare_model.dart';
import 'package:jamiat/src/data/providers/welfare_provider.dart';
import 'package:jamiat/src/data/services/haptic_helper.dart';
import 'package:jamiat/src/data/services/navigation_services.dart';
import 'package:jamiat/src/interfaces/components/async_content.dart';

class WelfareProgramScreen extends ConsumerStatefulWidget {
  const WelfareProgramScreen({super.key});

  @override
  ConsumerState<WelfareProgramScreen> createState() =>
      _WelfareProgramScreenState();
}

class _WelfareProgramScreenState extends ConsumerState<WelfareProgramScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  static const _fallbackColors = [
    Color(0xFFFFFBEB),
    Color(0xFFFFF1F2),
    Color(0xFFF0FDF4),
    Color(0xFFFDF4FF),
    Color(0xFFEFF6FF),
    Color(0xFFF5EBE6),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Color _cardColor(WelfareServiceModel service, int index) {
    final parsed = _parseAccent(service.accentColor);
    if (parsed != null) return parsed.withValues(alpha: 0.18);
    return _fallbackColors[index % _fallbackColors.length];
  }

  Color? _parseAccent(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    var hex = raw.trim().replaceFirst('#', '');
    if (hex.length == 6) hex = 'FF$hex';
    if (hex.length != 8) return null;
    final value = int.tryParse(hex, radix: 16);
    if (value == null) return null;
    return Color(value);
  }

  List<WelfareServiceModel> _filter(List<WelfareServiceModel> items) {
    if (_searchQuery.isEmpty) return items;
    final q = _searchQuery.toLowerCase();
    return items.where((s) {
      return s.name.toLowerCase().contains(q) ||
          s.shortDescription.toLowerCase().contains(q);
    }).toList();
  }

  Widget _icon(String? url) {
    if (url != null && url.startsWith('http')) {
      return Image.network(
        url,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => const Icon(
          Icons.volunteer_activism_outlined,
          color: kMutedText,
          size: 32,
        ),
      );
    }
    return const Icon(
      Icons.volunteer_activism_outlined,
      color: kMutedText,
      size: 32,
    );
  }

  @override
  Widget build(BuildContext context) {
    final listAsync = ref.watch(welfareListProvider);

    return Scaffold(
      backgroundColor: kWhite,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                    'Welfare Services',
                    style: kHeadTitleB.copyWith(
                      color: kTextColor,
                      fontSize: 22,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Container(
                decoration: BoxDecoration(
                  color: kSearchFieldBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (v) => setState(() => _searchQuery = v.trim()),
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
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                  style: kBodyTitleB.copyWith(color: kTextColor, fontSize: 15),
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: AsyncContent(
                  asyncValue: listAsync,
                  onRetry: () => ref.invalidate(welfareListProvider),
                  builder: (page) {
                    final services = _filter(page.items);
                    if (services.isEmpty) {
                      return Center(
                        child: Text('No services found', style: kEmptyStateM),
                      );
                    }
                    return RefreshIndicator(
                      color: kPrimaryColor,
                      onRefresh: () async {
                        ref.invalidate(welfareListProvider);
                        await ref.read(welfareListProvider.future);
                      },
                      child: ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(
                          parent: BouncingScrollPhysics(),
                        ),
                        itemCount: services.length,
                        itemBuilder: (context, index) {
                          final service = services[index];
                          final bg = _cardColor(service, index);
                          return GestureDetector(
                            onTap: () {
                              HapticHelper.impact(HapticImpact.light);
                              NavigationService().pushNamed(
                                'WelfareDetails',
                                arguments: {'welfareId': service.id},
                              );
                            },
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 20),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: bg,
                                borderRadius: BorderRadius.circular(
                                  kCardRadiusLg,
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      color: kWhite,
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    clipBehavior: Clip.antiAlias,
                                    child: _icon(service.icon),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          service.name,
                                          style: kBodyTitleSB.copyWith(
                                            fontSize: 16,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          service.shortDescription,
                                          style: kCaption12R.copyWith(
                                            color: kMutedText,
                                            height: 1.4,
                                          ),
                                          maxLines: 4,
                                          overflow: TextOverflow.ellipsis,
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
