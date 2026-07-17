import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jamiat/src/data/constants/color_constants.dart';
import 'package:jamiat/src/data/constants/style_constants.dart';
import 'package:jamiat/src/data/providers/event_provider.dart';
import 'package:jamiat/src/data/services/haptic_helper.dart';
import 'package:jamiat/src/interfaces/components/async_content.dart';

class EventTicketScreen extends ConsumerWidget {
  final String? ticketId;
  final String title;
  final String date;
  final String venue;

  const EventTicketScreen({
    super.key,
    this.ticketId,
    required this.title,
    required this.date,
    required this.venue,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasId = ticketId != null && ticketId!.isNotEmpty;

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
                    'My Ticket',
                    style: kHeadTitleB.copyWith(
                      color: kTextColor,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: hasId
                  ? AsyncContent(
                      asyncValue: ref.watch(eventTicketProvider(ticketId!)),
                      onRetry: () =>
                          ref.invalidate(eventTicketProvider(ticketId!)),
                      builder: (ticket) => _TicketBody(
                        title: ticket.eventTitle ?? title,
                        date: ticket.eventDate ?? date,
                        venue: ticket.venue ?? venue,
                        code: ticket.ticketCode,
                        qrImage: ticket.qrImage,
                        status: ticket.status,
                      ),
                    )
                  : _TicketBody(
                      title: title,
                      date: date,
                      venue: venue,
                      code: '—',
                      status: '',
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TicketBody extends StatelessWidget {
  const _TicketBody({
    required this.title,
    required this.date,
    required this.venue,
    required this.code,
    this.qrImage,
    this.status = '',
  });

  final String title;
  final String date;
  final String venue;
  final String code;
  final String? qrImage;
  final String status;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: kScreenBg,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            Text(title, style: kSectionTitleSB, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            if (status.isNotEmpty)
              Text(status, style: kCaption12M.copyWith(color: kPrimaryColor)),
            const SizedBox(height: 16),
            Text(date, style: kCaption12R.copyWith(color: kSecondaryTextColor)),
            const SizedBox(height: 4),
            Text(
              venue,
              style: kCaption12R.copyWith(color: kSecondaryTextColor),
            ),
            const SizedBox(height: 24),
            if (qrImage != null && qrImage!.startsWith('http'))
              Image.network(qrImage!, width: 180, height: 180)
            else
              Container(
                width: 180,
                height: 180,
                color: kWhite,
                child: const Icon(
                  Icons.qr_code_2,
                  size: 100,
                  color: kMutedText,
                ),
              ),
            const SizedBox(height: 16),
            Text(code, style: kBodyTitleB.copyWith(letterSpacing: 1.2)),
          ],
        ),
      ),
    );
  }
}
