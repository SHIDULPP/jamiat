import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jamiat/src/data/apis/event_api.dart';
import 'package:jamiat/src/data/constants/color_constants.dart';
import 'package:jamiat/src/data/constants/style_constants.dart';
import 'package:jamiat/src/data/models/event_model.dart';
import 'package:jamiat/src/data/providers/event_provider.dart';
import 'package:jamiat/src/data/services/haptic_helper.dart';
import 'package:jamiat/src/data/services/navigation_services.dart';
import 'package:jamiat/src/interfaces/components/async_content.dart';
import 'package:jamiat/src/interfaces/events/event_card.dart';

class SavedEventsScreen extends ConsumerStatefulWidget {
  const SavedEventsScreen({super.key});

  @override
  ConsumerState<SavedEventsScreen> createState() => _SavedEventsScreenState();
}

class _SavedEventsScreenState extends ConsumerState<SavedEventsScreen> {
  final Map<String, bool> _bookmarkOverrides = {};
  String? _bookmarkLoadingId;

  bool _isBookmarked(EventModel event) {
    return _bookmarkOverrides[event.id] ?? event.isBookmarked;
  }

  Future<void> _toggleBookmark(EventModel event) async {
    if (_bookmarkLoadingId != null) return;
    final currentlyBookmarked = _isBookmarked(event);
    setState(() => _bookmarkLoadingId = event.id);
    try {
      final api = ref.read(eventApiProvider);
      final res = currentlyBookmarked
          ? await api.removeBookmark(event.id)
          : await api.bookmarkEvent(event.id);
      if (!mounted) return;
      if (!res.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res.message ?? 'Bookmark failed')),
        );
        return;
      }
      setState(() => _bookmarkOverrides[event.id] = !currentlyBookmarked);
      ref.invalidate(savedEventsProvider);
      ref.invalidate(eventsListProvider);
      ref.invalidate(eventDetailProvider(event.id));
    } finally {
      if (mounted) setState(() => _bookmarkLoadingId = null);
    }
  }

  void _shareEvent(EventModel event) {
    HapticHelper.impact(HapticImpact.light);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Thanks for sharing ${event.title}')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final savedAsync = ref.watch(savedEventsProvider);

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
                    'Saved events',
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
                asyncValue: savedAsync,
                onRetry: () => ref.invalidate(savedEventsProvider),
                builder: (events) {
                  if (events.isEmpty) {
                    return Center(
                      child: Text('No saved events', style: kEmptyStateM),
                    );
                  }
                  return RefreshIndicator(
                    color: kPrimaryColor,
                    onRefresh: () async {
                      ref.invalidate(savedEventsProvider);
                      await ref.read(savedEventsProvider.future);
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      itemCount: events.length,
                      itemBuilder: (context, index) {
                        final event = events[index];
                        return EventListCard(
                          event: event,
                          isBookmarked: _isBookmarked(event),
                          isBookmarkLoading: _bookmarkLoadingId == event.id,
                          onTap: () {
                            HapticHelper.impact(HapticImpact.light);
                            NavigationService().pushNamed(
                              'EventDetails',
                              arguments: {'eventId': event.id},
                            );
                          },
                          onBookmark: () {
                            HapticHelper.impact(HapticImpact.light);
                            _toggleBookmark(event);
                          },
                          onShare: () => _shareEvent(event),
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
    );
  }
}
