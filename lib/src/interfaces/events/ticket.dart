import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:jamiat/src/data/constants/color_constants.dart';
import 'package:jamiat/src/data/constants/style_constants.dart';
import 'package:jamiat/src/data/models/event_model.dart';
import 'package:jamiat/src/data/providers/event_provider.dart';
import 'package:jamiat/src/data/services/haptic_helper.dart';
import 'package:jamiat/src/data/services/navigation_services.dart';
import 'package:jamiat/src/data/utils/format_helpers.dart';
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
                  Expanded(
                    child: Text(
                      'My Ticket',
                      textAlign: TextAlign.center,
                      style: kHeadTitleB.copyWith(
                        color: kTextColor,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      HapticHelper.impact(HapticImpact.light);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Ticket download coming soon'),
                        ),
                      );
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: kWhite,
                        border: Border.all(color: kBorder, width: 1.25),
                      ),
                      alignment: Alignment.center,
                      child: SvgPicture.asset(
                        'assets/svg/donwload_icon.svg',
                        width: 17,
                        height: 17,
                      ),
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
                      builder: (ticket) => _TicketBody(ticket: ticket),
                    )
                  : _TicketBody(
                      ticket: EventTicketModel(
                        id: '',
                        ticketCode: '—',
                        status: '',
                        eventTitle: title,
                        venue: venue,
                      ),
                      fallbackDateLabel: date,
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
    required this.ticket,
    this.fallbackDateLabel,
  });

  final EventTicketModel ticket;
  final String? fallbackDateLabel;

  Widget? _qrImage() {
    final qr = ticket.qrImage;
    if (qr == null || qr.isEmpty) return null;

    if (qr.startsWith('data:image')) {
      try {
        final base64Part = qr.split(',').last;
        final bytes = base64Decode(base64Part);
        return Image.memory(bytes, width: 180, height: 180, fit: BoxFit.contain);
      } catch (_) {
        return null;
      }
    }

    if (qr.startsWith('http')) {
      return Image.network(qr, width: 180, height: 180, fit: BoxFit.contain);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final dateLabel = ticket.eventDate != null
        ? formatEventShortDate(ticket.eventDate)
        : (fallbackDateLabel ?? '');
    final timeLabel = formatEventTime(ticket.eventDate);
    final qr = _qrImage();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: kWhite,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: kCardBorder),
              boxShadow: [
                BoxShadow(
                  color: kBlack.withValues(alpha: 0.06),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
                  color: kSecondaryColor,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ticket.eventTitle ?? 'Event',
                        style: kSectionTitleSB.copyWith(fontSize: 20),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        ticket.passType,
                        style: kBodyTitleSB.copyWith(fontSize: 15),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'ORGANIZERS',
                        style: kCaption10SB.copyWith(
                          color: kTextColor.withValues(alpha: 0.55),
                          letterSpacing: 0.6,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Jamiat Welfare Committee',
                        style: kCaption14M,
                      ),
                    ],
                  ),
                ),
                CustomPaint(
                  painter: _DashedLinePainter(color: kBorder),
                  child: const SizedBox(width: double.infinity, height: 1),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _MetaColumn(
                              label: 'Date',
                              value: dateLabel.isEmpty ? '—' : dateLabel,
                            ),
                          ),
                          Expanded(
                            child: _MetaColumn(
                              label: 'Time',
                              value: timeLabel.isEmpty ? '—' : timeLabel,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: _MetaColumn(
                          label: 'Venue',
                          value: (ticket.venue == null || ticket.venue!.isEmpty)
                              ? '—'
                              : ticket.venue!,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: kWhite,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: kBorder),
                        ),
                        child: qr ??
                            Container(
                              width: 180,
                              height: 180,
                              color: kScreenBg,
                              child: const Icon(
                                Icons.qr_code_2,
                                size: 100,
                                color: kMutedText,
                              ),
                            ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Show this QR to the program coordinators',
                        style: kCaption12R.copyWith(color: kSecondaryTextColor),
                        textAlign: TextAlign.center,
                      ),
                      if (ticket.ticketCode.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Text(
                          ticket.ticketCode,
                          style: kBodyTitleB.copyWith(letterSpacing: 1.2),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              HapticHelper.impact(HapticImpact.light);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Ticket download coming soon')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimaryColor,
              foregroundColor: kWhite,
              minimumSize: const Size.fromHeight(52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 0,
            ),
            child: Text('Download Tickets', style: kButtonLabelSB),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () {
              HapticHelper.impact(HapticImpact.light);
              NavigationService().popAndPushNamed('MyTickets');
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: kTextColor,
              minimumSize: const Size.fromHeight(52),
              side: const BorderSide(color: kBorder),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: Text(
              'View all my Tickets',
              style: kButtonLabelSB.copyWith(color: kTextColor),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaColumn extends StatelessWidget {
  const _MetaColumn({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: kCaption12R.copyWith(color: kSecondaryTextColor),
        ),
        const SizedBox(height: 4),
        Text(value, style: kCaption14M),
      ],
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  _DashedLinePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    const dashWidth = 6.0;
    const dashSpace = 4.0;
    double startX = 0;
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;
    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, 0),
        Offset(startX + dashWidth, 0),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
