import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jamiat/src/data/apis/event_api.dart';
import 'package:jamiat/src/data/constants/color_constants.dart';
import 'package:jamiat/src/data/constants/style_constants.dart';
import 'package:jamiat/src/data/models/event_model.dart';
import 'package:jamiat/src/data/providers/event_provider.dart';
import 'package:jamiat/src/data/services/haptic_helper.dart';
import 'package:jamiat/src/data/services/navigation_services.dart';
import 'package:jamiat/src/data/utils/format_helpers.dart';
import 'package:jamiat/src/interfaces/components/async_content.dart';

class EventDetailsScreen extends ConsumerStatefulWidget {
  final String? eventId;
  final String title;
  final String category;
  final String date;
  final String location;
  final String image;
  final bool isBookmarked;

  const EventDetailsScreen({
    super.key,
    this.eventId,
    this.title = 'Event Details',
    this.category = 'Conference',
    this.date = '',
    this.location = '',
    this.image = 'assets/jpgs/campaign_education.jpg',
    this.isBookmarked = false,
  });

  @override
  ConsumerState<EventDetailsScreen> createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends ConsumerState<EventDetailsScreen> {
  bool _bookmarkLoading = false;
  bool _registerLoading = false;

  Widget _cover(String? url) {
    if (url != null && url.startsWith('http')) {
      return Image.network(
        url,
        height: 220,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => Container(
          height: 220,
          color: kScreenBg,
          child: const Icon(Icons.image_outlined, color: kMutedText, size: 40),
        ),
      );
    }
    return Image.asset(
      url ?? widget.image,
      height: 220,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => Container(
        height: 220,
        color: kScreenBg,
        child: const Icon(Icons.image_outlined, color: kMutedText, size: 40),
      ),
    );
  }

  Future<void> _toggleBookmark(EventModel event) async {
    if (_bookmarkLoading) return;
    setState(() => _bookmarkLoading = true);
    try {
      final api = ref.read(eventApiProvider);
      final res = event.isBookmarked
          ? await api.removeBookmark(event.id)
          : await api.bookmarkEvent(event.id);
      if (!mounted) return;
      if (!res.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res.message ?? 'Bookmark failed')),
        );
        return;
      }
      ref.invalidate(eventDetailProvider(event.id));
      ref.invalidate(savedEventsProvider);
      ref.invalidate(eventsListProvider);
    } finally {
      if (mounted) setState(() => _bookmarkLoading = false);
    }
  }

  Future<void> _register(EventModel event) async {
    if (_registerLoading || event.isRegistered == true) return;
    setState(() => _registerLoading = true);
    try {
      final res = await ref.read(eventApiProvider).registerForEvent(event.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            res.success
                ? 'Registered successfully'
                : (res.message ?? 'Registration failed'),
          ),
        ),
      );
      if (res.success) {
        ref.invalidate(eventDetailProvider(event.id));
        ref.invalidate(myTicketsProvider('upcoming'));
        ref.invalidate(myTicketsProvider('past'));
        final ticketId = res.data?.id;
        if (ticketId != null && ticketId.isNotEmpty) {
          NavigationService().pushNamed(
            'EventTicket',
            arguments: {'ticketId': ticketId},
          );
        } else {
          NavigationService().pushNamed('MyTickets');
        }
      }
    } finally {
      if (mounted) setState(() => _registerLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasId = widget.eventId != null && widget.eventId!.isNotEmpty;

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
                      'Event details',
                      style: kHeadTitleB.copyWith(
                        color: kTextColor,
                        fontSize: 22,
                      ),
                    ),
                  ),
                  if (hasId)
                    IconButton(
                      onPressed: _bookmarkLoading
                          ? null
                          : () {
                              HapticHelper.impact(HapticImpact.light);
                              final event = ref
                                  .read(eventDetailProvider(widget.eventId!))
                                  .value;
                              if (event != null) _toggleBookmark(event);
                            },
                      icon: _bookmarkLoading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Icon(
                              (ref
                                          .watch(
                                            eventDetailProvider(
                                              widget.eventId!,
                                            ),
                                          )
                                          .value
                                          ?.isBookmarked ??
                                      widget.isBookmarked)
                                  ? Icons.bookmark
                                  : Icons.bookmark_border,
                            ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: hasId
                  ? AsyncContent(
                      asyncValue: ref.watch(
                        eventDetailProvider(widget.eventId!),
                      ),
                      onRetry: () =>
                          ref.invalidate(eventDetailProvider(widget.eventId!)),
                      builder: (event) => SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: _cover(event.coverImage),
                            ),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: kScreenBg,
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: Text(event.type, style: kCaption10SB),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              event.title,
                              style: kSectionTitleSB.copyWith(fontSize: 20),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              formatDateLabel(event.startDate),
                              style: kCaption12R.copyWith(
                                color: kSecondaryTextColor,
                              ),
                            ),
                            if (event.venue != null) ...[
                              const SizedBox(height: 6),
                              Text(
                                event.venue!,
                                style: kCaption12R.copyWith(
                                  color: kSecondaryTextColor,
                                ),
                              ),
                            ],
                            const SizedBox(height: 16),
                            Text(
                              event.description,
                              style: kBodyTitleR.copyWith(
                                color: kText2Color,
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 24),
                            if (event.registrationEnabled == true)
                              ElevatedButton(
                                onPressed:
                                    (event.isRegistered == true ||
                                        _registerLoading)
                                    ? null
                                    : () {
                                        HapticHelper.impact(
                                          HapticImpact.medium,
                                        );
                                        _register(event);
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: kPrimaryColor,
                                  foregroundColor: kWhite,
                                  minimumSize: const Size.fromHeight(52),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                child: _registerLoading
                                    ? const SizedBox(
                                        width: 22,
                                        height: 22,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.5,
                                          color: kWhite,
                                        ),
                                      )
                                    : Text(
                                        event.isRegistered == true
                                            ? 'Already registered'
                                            : 'Register',
                                        style: kButtonLabelSB,
                                      ),
                              ),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: _cover(widget.image),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            widget.title,
                            style: kSectionTitleSB.copyWith(fontSize: 20),
                          ),
                          const SizedBox(height: 8),
                          Text(widget.date, style: kCaption12R),
                          Text(widget.location, style: kCaption12R),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
