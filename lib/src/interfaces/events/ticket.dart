import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:jamiat/src/data/constants/color_constants.dart';
import 'package:jamiat/src/data/constants/style_constants.dart';
import 'package:jamiat/src/data/models/event_model.dart';
import 'package:jamiat/src/data/providers/event_provider.dart';
import 'package:jamiat/src/data/services/haptic_helper.dart';
import 'package:jamiat/src/data/services/navigation_services.dart';
import 'package:jamiat/src/data/services/ticket_download_service.dart';
import 'package:jamiat/src/data/utils/format_helpers.dart';
import 'package:jamiat/src/interfaces/components/async_content.dart';
import 'package:qr_flutter/qr_flutter.dart';

class EventTicketScreen extends ConsumerStatefulWidget {
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
  ConsumerState<EventTicketScreen> createState() => _EventTicketScreenState();
}

class _EventTicketScreenState extends ConsumerState<EventTicketScreen> {
  final TicketDownloadService _downloadService = const TicketDownloadService();
  bool _downloading = false;

  void _showMessage(
    String message, {
    bool offerSettings = false,
  }) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        action: offerSettings
            ? SnackBarAction(
                label: 'Settings',
                onPressed: _downloadService.openSettings,
              )
            : null,
      ),
    );
  }

  Future<void> _downloadTicket(EventTicketModel ticket) async {
    if (_downloading) return;
    HapticHelper.impact(HapticImpact.light);
    setState(() => _downloading = true);

    try {
      final result = await _downloadService.saveTicket(
        context: context,
        ticket: ticket,
      );
      if (!mounted) return;

      _showMessage(
        result.message ??
            (result.isSuccess
                ? 'Ticket saved to gallery'
                : 'Failed to save ticket'),
        offerSettings: result.status == TicketDownloadStatus.cancelled,
      );
    } finally {
      if (mounted) setState(() => _downloading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasId = widget.ticketId != null && widget.ticketId!.isNotEmpty;
    final ticketAsync = hasId
        ? ref.watch(eventTicketProvider(widget.ticketId!))
        : null;
    final loadedTicket = ticketAsync?.value;
    final fallbackTicket = EventTicketModel(
      id: '',
      ticketCode: '—',
      status: '',
      eventTitle: widget.title,
      venue: widget.venue,
    );

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
                    onTap: _downloading || (hasId && loadedTicket == null)
                        ? null
                        : () => _downloadTicket(loadedTicket ?? fallbackTicket),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: kWhite,
                        border: Border.all(color: kBorder, width: 1.25),
                      ),
                      alignment: Alignment.center,
                      child: _downloading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : SvgPicture.asset(
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
                      asyncValue: ticketAsync!,
                      onRetry: () => ref.invalidate(
                        eventTicketProvider(widget.ticketId!),
                      ),
                      builder: (ticket) => _TicketBody(
                        ticket: ticket,
                        downloading: _downloading,
                        onDownload: () => _downloadTicket(ticket),
                      ),
                    )
                  : _TicketBody(
                      ticket: fallbackTicket,
                      fallbackDateLabel: widget.date,
                      downloading: _downloading,
                      onDownload: () => _downloadTicket(fallbackTicket),
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
    required this.onDownload,
    required this.downloading,
    this.fallbackDateLabel,
  });

  final EventTicketModel ticket;
  final VoidCallback onDownload;
  final bool downloading;
  final String? fallbackDateLabel;

  Uint8List? _decodeQrBytes() {
    final raw = ticket.qrImage;
    if (raw == null || raw.trim().isEmpty) return null;
    try {
      final base64Part = raw.contains(',') ? raw.split(',').last : raw;
      return base64Decode(base64Part);
    } catch (_) {
      return null;
    }
  }

  Widget _qrWidget() {
    final qrBytes = _decodeQrBytes();
    final qrData = (ticket.qrToken != null && ticket.qrToken!.isNotEmpty)
        ? ticket.qrToken!
        : ticket.ticketCode;

    if (qrBytes != null) {
      return Image.memory(
        qrBytes,
        width: 180,
        height: 180,
        fit: BoxFit.contain,
        gaplessPlayback: true,
        filterQuality: FilterQuality.none,
        errorBuilder: (_, _, _) => _QrFallback(data: qrData),
      );
    }
    return _QrFallback(data: qrData);
  }

  @override
  Widget build(BuildContext context) {
    final dateLabel = ticket.eventDate != null
        ? formatEventShortDate(ticket.eventDate)
        : (fallbackDateLabel ?? '');
    final timeLabel = formatEventTime(ticket.eventDate);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: kBlack.withValues(alpha: 0.06),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: kWhite,
              borderRadius: BorderRadius.circular(20),
              clipBehavior: Clip.antiAlias,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: kWhite,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: kCardBorder),
                ),
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
                              value:
                                  (ticket.venue == null ||
                                      ticket.venue!.isEmpty)
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
                            child: _qrWidget(),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Show this QR to the program coordinators',
                            style: kCaption12R.copyWith(
                              color: kSecondaryTextColor,
                            ),
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
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: downloading ? null : onDownload,
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimaryColor,
              foregroundColor: kWhite,
              disabledBackgroundColor: kPrimaryColor.withValues(alpha: 0.6),
              minimumSize: const Size.fromHeight(52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 0,
            ),
            child: downloading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: kWhite,
                    ),
                  )
                : Text('Download Tickets', style: kButtonLabelSB),
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

class _QrFallback extends StatelessWidget {
  const _QrFallback({required this.data});

  final String data;

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty || data == '—') {
      return Container(
        width: 180,
        height: 180,
        color: kScreenBg,
        child: const Icon(Icons.qr_code_2, size: 100, color: kMutedText),
      );
    }
    return QrImageView(
      data: data,
      version: QrVersions.auto,
      size: 180,
      backgroundColor: kWhite,
      eyeStyle: const QrEyeStyle(
        eyeShape: QrEyeShape.square,
        color: kBlack,
      ),
      dataModuleStyle: const QrDataModuleStyle(
        dataModuleShape: QrDataModuleShape.square,
        color: kBlack,
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
