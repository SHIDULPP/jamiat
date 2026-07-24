import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:jamiat/src/data/apis/event_api.dart';
import 'package:jamiat/src/data/apis/user_api.dart';
import 'package:jamiat/src/data/constants/color_constants.dart';
import 'package:jamiat/src/data/constants/style_constants.dart';
import 'package:jamiat/src/data/models/event_model.dart';
import 'package:jamiat/src/data/providers/event_provider.dart';
import 'package:jamiat/src/data/services/haptic_helper.dart';
import 'package:jamiat/src/data/services/navigation_services.dart';
import 'package:jamiat/src/data/utils/format_helpers.dart';
import 'package:jamiat/src/interfaces/components/async_content.dart';
import 'package:jamiat/src/interfaces/events/event_card.dart';

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
          border: Border.all(color: kBorder, width: 1.25),
        ),
        child: Center(child: child),
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

  Future<void> _registerOrViewTicket(EventModel event) async {
    if (event.isRegistered == true) {
      final ticketId = event.myTicketId;
      if (ticketId != null && ticketId.isNotEmpty) {
        NavigationService().pushNamed(
          'EventTicket',
          arguments: {'ticketId': ticketId},
        );
      } else {
        NavigationService().pushNamed('MyTickets');
      }
      return;
    }

    if (_registerLoading) return;
    setState(() => _registerLoading = true);
    try {
      final res = await ref.read(eventApiProvider).registerForEvent(event.id);
      if (!mounted) return;
      if (!res.success || res.data == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res.message ?? 'Registration failed')),
        );
        return;
      }
      ref.invalidate(eventDetailProvider(event.id));
      ref.invalidate(myTicketsProvider('upcoming'));
      ref.invalidate(myTicketsProvider('past'));
      ref.invalidate(eventsListProvider);
      NavigationService().pushNamed(
        'EventTicket',
        arguments: {'ticketId': res.data!.id},
      );
    } finally {
      if (mounted) setState(() => _registerLoading = false);
    }
  }

  String? _resolvePersonImageUrl(String? raw) {
    final imageUrl = raw?.trim();
    if (imageUrl == null || imageUrl.isEmpty) return null;
    if (imageUrl.startsWith('//')) return 'https:$imageUrl';
    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      return imageUrl;
    }
    return null;
  }

  Widget _personAvatar(String? rawUrl) {
    const size = 48.0;
    final url = _resolvePersonImageUrl(rawUrl);

    Widget placeholder() => Container(
      width: size,
      height: size,
      color: kScreenBg,
      alignment: Alignment.center,
      child: const Icon(Icons.person_outline, color: kMutedText, size: 22),
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: url == null
          ? placeholder()
          : Image.network(
              url,
              width: size,
              height: size,
              fit: BoxFit.cover,
              alignment: Alignment.center,
              filterQuality: FilterQuality.medium,
              cacheWidth: (size * 3).round(),
              cacheHeight: (size * 3).round(),
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return Container(
                  width: size,
                  height: size,
                  color: kScreenBg,
                  alignment: Alignment.center,
                  child: const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                );
              },
              errorBuilder: (_, _, _) => placeholder(),
            ),
    );
  }

  Widget _personTile(EventPerson person, {String? fallbackRole}) {
    final role = person.designation?.isNotEmpty == true
        ? person.designation!
        : (fallbackRole ?? '');
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          _personAvatar(person.image),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(person.name, style: kBodyTitleSB.copyWith(fontSize: 15)),
                if (role.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    role,
                    style: kCaption12R.copyWith(color: kSecondaryTextColor),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _metaRow({required IconData icon, required String text}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: kMutedText),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: kCaption14R.copyWith(color: kSecondaryTextColor),
          ),
        ),
      ],
    );
  }

  Widget _buildBody(EventModel event) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: eventCoverImage(event.coverImage),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            event.title,
            style: kSectionTitleSB.copyWith(fontSize: 22),
          ),
          const SizedBox(height: 12),
          _metaRow(
            icon: Icons.calendar_today_outlined,
            text: formatEventDateTimeRange(event.startDate, event.endDate),
          ),
          if (event.venue != null && event.venue!.isNotEmpty) ...[
            const SizedBox(height: 8),
            _metaRow(
              icon: Icons.location_on_outlined,
              text: event.venue!,
            ),
          ],
          if (event.type == 'Online' &&
              event.onlineLink != null &&
              event.onlineLink!.isNotEmpty) ...[
            const SizedBox(height: 8),
            _metaRow(
              icon: Icons.link,
              text: event.onlineLink!,
            ),
          ],
          const SizedBox(height: 24),
          Text('About Event', style: kSectionTitleSB),
          const SizedBox(height: 8),
          Text(
            event.description,
            style: kBodyTitleR.copyWith(color: kText2Color, height: 1.5),
          ),
          if (event.guests.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text('Guests', style: kSectionTitleSB),
            const SizedBox(height: 12),
            ...event.guests.map(_personTile),
          ],
          if (event.coordinators.where((p) => p.name.isNotEmpty).isNotEmpty) ...[
            const SizedBox(height: 8),
            Text('Event Coordinators', style: kSectionTitleSB),
            const SizedBox(height: 12),
            ...event.coordinators
                .where((p) => p.name.isNotEmpty)
                .map(
                  (p) => _personTile(p, fallbackRole: 'Event Coordinator'),
                ),
          ],
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasId = widget.eventId != null && widget.eventId!.isNotEmpty;
    final eventAsync = hasId
        ? ref.watch(eventDetailProvider(widget.eventId!))
        : null;
    final event = eventAsync?.value;
    final isBookmarked = event?.isBookmarked ?? widget.isBookmarked;
    final currentUserId = ref.watch(userProfileProvider).maybeWhen(
      data: (user) => user.id,
      orElse: () => null,
    );
    final isCoordinator =
        event != null && event.isCoordinator(currentUserId);
    final showRegister =
        !isCoordinator && (event == null || event.registrationEnabled == true);
    final showScanQr = isCoordinator;

    return Scaffold(
      backgroundColor: kWhite,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
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
                  Expanded(
                    child: Text(
                      'Event Details',
                      textAlign: TextAlign.center,
                      style: kHeadTitleB.copyWith(
                        color: kTextColor,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  if (hasId) ...[
                    _headerCircleButton(
                      onTap: () {
                        HapticHelper.impact(HapticImpact.light);
                        final title = event?.title ?? widget.title;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Thanks for sharing $title')),
                        );
                      },
                      child: SvgPicture.asset(
                        'assets/svg/share.svg',
                        width: 18,
                        height: 18,
                        colorFilter: const ColorFilter.mode(
                          kTextColor,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _headerCircleButton(
                      onTap: _bookmarkLoading
                          ? null
                          : () {
                              HapticHelper.impact(HapticImpact.light);
                              if (event != null) _toggleBookmark(event);
                            },
                      child: _bookmarkLoading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : SvgPicture.asset(
                              'assets/svg/bookmark.svg',
                              width: 18,
                              height: 18,
                              colorFilter: ColorFilter.mode(
                                isBookmarked ? kPrimaryColor : kTextColor,
                                BlendMode.srcIn,
                              ),
                            ),
                    ),
                  ] else
                    const SizedBox(width: 40),
                ],
              ),
            ),
            Expanded(
              child: hasId
                  ? AsyncContent(
                      asyncValue: eventAsync!,
                      onRetry: () =>
                          ref.invalidate(eventDetailProvider(widget.eventId!)),
                      builder: _buildBody,
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: AspectRatio(
                              aspectRatio: 16 / 9,
                              child: eventCoverImage(widget.image),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            widget.title,
                            style: kSectionTitleSB.copyWith(fontSize: 22),
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
      bottomNavigationBar: hasId && event != null && (showScanQr || showRegister)
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                child: ElevatedButton(
                  onPressed: showScanQr
                      ? () {
                          HapticHelper.impact(HapticImpact.medium);
                          NavigationService().pushNamed(
                            'EventQrScan',
                            arguments: {
                              'eventId': event.id,
                              'eventTitle': event.title,
                            },
                          );
                        }
                      : _registerLoading
                      ? null
                      : () {
                          HapticHelper.impact(HapticImpact.medium);
                          _registerOrViewTicket(event);
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryColor,
                    foregroundColor: kWhite,
                    disabledBackgroundColor: kPrimaryColor.withValues(
                      alpha: 0.6,
                    ),
                    minimumSize: const Size.fromHeight(52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: showScanQr
                      ? Text('Scan QR', style: kButtonLabelSB)
                      : _registerLoading
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
                              ? 'View Ticket'
                              : 'Register',
                          style: kButtonLabelSB,
                        ),
                ),
              ),
            )
          : null,
    );
  }
}
