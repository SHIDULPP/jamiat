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

class EventsScreen extends ConsumerStatefulWidget {
  const EventsScreen({super.key});

  @override
  ConsumerState<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends ConsumerState<EventsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  final Map<String, bool> _bookmarkOverrides = {};
  String? _bookmarkLoadingId;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<EventModel> _filter(List<EventModel> items) {
    if (_searchQuery.isEmpty) return items;
    final query = _searchQuery.toLowerCase();
    return items.where((e) {
      return e.title.toLowerCase().contains(query) ||
          e.type.toLowerCase().contains(query) ||
          (e.venue?.toLowerCase().contains(query) ?? false) ||
          e.description.toLowerCase().contains(query);
    }).toList();
  }

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
    final eventsAsync = ref.watch(eventsListProvider);
    final upcomingTicketsAsync = ref.watch(myTicketsProvider('upcoming'));

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
                  Expanded(
                    child: Text(
                      'Events',
                      style: kHeadTitleB.copyWith(
                        color: kTextColor,
                        fontSize: 22,
                      ),
                    ),
                  ),
                  PopupMenuButton<String>(
                    padding: EdgeInsets.zero,
                    offset: const Offset(0, 44),
                    color: kWhite,
                    elevation: 8,
                    shadowColor: kBlack.withValues(alpha: 0.18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    icon: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: kWhite,
                        border: Border.all(color: kBorder, width: 1.25),
                      ),
                      child: const Icon(
                        Icons.more_vert,
                        color: kTextColor,
                        size: 20,
                      ),
                    ),
                    onSelected: (value) {
                      HapticHelper.impact(HapticImpact.light);
                      if (value == 'tickets') {
                        NavigationService().pushNamed('MyTickets');
                      } else {
                        NavigationService().pushNamed('SavedEvents');
                      }
                    },
                    itemBuilder: (_) => [
                      PopupMenuItem<String>(
                        value: 'tickets',
                        height: 48,
                        child: Text(
                          'My Tickets',
                          style: kStyle(
                            kMedium,
                            15,
                            color: const Color(0xFF888888),
                          ),
                        ),
                      ),
                      PopupMenuItem<String>(
                        enabled: false,
                        height: 1,
                        padding: EdgeInsets.zero,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Divider(
                            height: 1,
                            thickness: 1,
                            color: kBorder.withValues(alpha: 0.9),
                          ),
                        ),
                      ),
                      PopupMenuItem<String>(
                        value: 'saved',
                        height: 48,
                        child: Text(
                          'Saved',
                          style: kStyle(
                            kMedium,
                            15,
                            color: const Color(0xFF888888),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: kSearchFieldBg,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: Row(
                        children: [
                          const Icon(Icons.search, color: kMutedText, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              onChanged: (v) =>
                                  setState(() => _searchQuery = v),
                              decoration: InputDecoration(
                                hintText: 'Search for events...',
                                hintStyle: kCaption14R.copyWith(
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
                  const SizedBox(width: 10),
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: kSearchFieldBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      onPressed: () {
                        HapticHelper.impact(HapticImpact.light);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Filters coming soon'),
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.tune_rounded,
                        color: kTextColor,
                        size: 22,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () {
                  HapticHelper.impact(HapticImpact.light);
                  NavigationService().pushNamed('MyTickets');
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: kQuickEventsBg,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFFFE8C7)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: kSecondaryColor.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.confirmation_number_outlined,
                          color: Color(0xFFB45309),
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'My Tickets',
                              style: kCaption12R.copyWith(
                                color: kSecondaryTextColor,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              upcomingTicketsAsync.when(
                                data: (tickets) {
                                  final count = tickets.length;
                                  if (count == 0) {
                                    return 'No upcoming events registered';
                                  }
                                  return '$count upcoming event${count == 1 ? '' : 's'} registered';
                                },
                                loading: () => 'Loading tickets...',
                                error: (_, _) => 'View your tickets',
                              ),
                              style: kBodyTitleSB.copyWith(fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right,
                        color: kMutedText,
                        size: 22,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text('Upcoming events', style: kSectionTitleSB),
              const SizedBox(height: 12),
              Expanded(
                child: AsyncContent(
                  asyncValue: eventsAsync,
                  onRetry: () => ref.invalidate(eventsListProvider),
                  builder: (page) {
                    final events = _filter(page.items);
                    if (events.isEmpty) {
                      return Center(
                        child: Text('No events found', style: kEmptyStateM),
                      );
                    }
                    return RefreshIndicator(
                      color: kPrimaryColor,
                      onRefresh: () async {
                        ref.invalidate(eventsListProvider);
                        ref.invalidate(myTicketsProvider('upcoming'));
                        await ref.read(eventsListProvider.future);
                      },
                      child: ListView.builder(
                        itemCount: events.length,
                        itemBuilder: (_, i) {
                          final event = events[i];
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
      ),
    );
  }
}
