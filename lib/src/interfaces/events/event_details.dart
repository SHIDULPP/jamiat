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
          border: Border.all(color: kGrey, width: 1.25),
        ),
        alignment: Alignment.center,
        child: child,
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

  Widget _personAvatar(String? rawUrl, {double size = 40, double radius = 4}) {
    final url = _resolvePersonImageUrl(rawUrl);

    Widget placeholder() => Container(
      width: size,
      height: size,
      color: kScreenBg,
      alignment: Alignment.center,
      child: Icon(Icons.person_outline, color: kMutedText, size: size * 0.5),
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
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
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                );
              },
              errorBuilder: (_, _, _) => placeholder(),
            ),
    );
  }

  Widget _speakerTile(EventPerson person) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          _personAvatar(person.image),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              person.name,
              style: kCaption12R.copyWith(color: kTextColor),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _metaRow({required IconData icon, required String text}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, size: 16, color: kTextColor),
        const SizedBox(width: 5),
        Expanded(
          child: Text(
            text,
            style: kCaption12R.copyWith(color: kTextColor),
          ),
        ),
      ],
    );
  }

  Widget _categoryChip(String label) {
    if (label.trim().isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFD5D5D5).withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: kCaption10M.copyWith(color: kTextColor),
      ),
    );
  }

  Widget _organizersRow(EventModel event) {
    final named = event.coordinators.where((p) => p.name.isNotEmpty).toList();
    final organizer = named.isNotEmpty ? named.first : null;
    final name = organizer?.name ?? 'Jamiat Welfare Committee';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          _personAvatar(organizer?.image, radius: 4),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ORGANIZERS',
                  style: kCaption10SB.copyWith(
                    color: kSecondaryTextColor,
                    letterSpacing: 0.4,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  name,
                  style: kCaption12R.copyWith(color: kTextColor),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(EventModel event) {
    final dateTimeLabel = formatEventDateTimeRange(
      event.startDate,
      event.endDate,
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        kScreenPaddingH,
        0,
        kScreenPaddingH,
        24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 370 / 203,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(kCardRadiusMd),
              child: eventCoverImage(event.coverImage),
            ),
          ),
          const SizedBox(height: 16),
          _categoryChip(event.type),
          const SizedBox(height: 16),
          Text(
            event.title,
            style: kLabel19SB,
          ),
          const SizedBox(height: 16),
          if (dateTimeLabel.isNotEmpty) ...[
            _metaRow(
              icon: Icons.calendar_today_outlined,
              text: dateTimeLabel,
            ),
          ],
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
          const SizedBox(height: 8),
          _organizersRow(event),
          const SizedBox(height: 8),
          Text('About Event', style: kSectionTitleSB),
          const SizedBox(height: 8),
          Text(
            event.description,
            style: kCaption12R.copyWith(color: kTextColor, height: 1.4),
          ),
          if (event.guests.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text('Speakers', style: kSectionTitleSB),
            const SizedBox(height: 8),
            ...event.guests.map(_speakerTile),
          ],
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _fallbackBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: kScreenPaddingH),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 370 / 203,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(kCardRadiusMd),
              child: eventCoverImage(widget.image),
            ),
          ),
          const SizedBox(height: 16),
          _categoryChip(widget.category),
          const SizedBox(height: 16),
          Text(widget.title, style: kLabel19SB),
          const SizedBox(height: 16),
          if (widget.date.isNotEmpty)
            _metaRow(
              icon: Icons.calendar_today_outlined,
              text: widget.date,
            ),
          if (widget.location.isNotEmpty) ...[
            const SizedBox(height: 8),
            _metaRow(
              icon: Icons.location_on_outlined,
              text: widget.location,
            ),
          ],
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
                  Expanded(
                    child: Text(
                      'Event Details',
                      style: kSectionTitleSB,
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
                  ],
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
                  : _fallbackBody(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: hasId && event != null && (showScanQr || showRegister)
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  kScreenPaddingH,
                  8,
                  kScreenPaddingH,
                  16,
                ),
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
                    minimumSize: const Size.fromHeight(56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(kCardRadiusSm),
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
