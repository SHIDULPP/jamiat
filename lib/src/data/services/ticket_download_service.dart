import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:gal/gal.dart';
import 'package:jamiat/src/data/constants/color_constants.dart';
import 'package:jamiat/src/data/constants/style_constants.dart';
import 'package:jamiat/src/data/models/event_model.dart';
import 'package:jamiat/src/data/utils/format_helpers.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_flutter/qr_flutter.dart';

enum TicketDownloadStatus { success, cancelled, failed }

class TicketDownloadResult {
  const TicketDownloadResult({
    required this.status,
    this.message,
  });

  final TicketDownloadStatus status;
  final String? message;

  bool get isSuccess => status == TicketDownloadStatus.success;
}

/// Captures an event ticket card (including QR) and saves it to the gallery.
///
/// Uses the same Overlay + offscreen [RepaintBoundary] approach as ipaconnect
/// digital ID download, so Image.memory / QrImageView are fully painted first.
class TicketDownloadService {
  const TicketDownloadService();

  Future<TicketDownloadResult> saveTicket({
    required BuildContext context,
    required EventTicketModel ticket,
  }) async {
    OverlayEntry? overlayEntry;
    try {
      final qrBytes = _decodeQrBytes(ticket.qrImage);
      final boundaryKey = GlobalKey();
      final cardWidth = MediaQuery.sizeOf(context).width - 48;

      overlayEntry = OverlayEntry(
        builder: (_) => Material(
          color: Colors.transparent,
          child: Center(
            child: RepaintBoundary(
              key: boundaryKey,
              child: SizedBox(
                width: cardWidth,
                child: _TicketCaptureCard(
                  ticket: ticket,
                  qrBytes: qrBytes,
                ),
              ),
            ),
          ),
        ),
      );

      Overlay.of(context).insert(overlayEntry);

      // Allow Image.memory / QrImageView to layout and paint (ipaconnect pattern).
      await Future<void>.delayed(const Duration(milliseconds: 500));
      await WidgetsBinding.instance.endOfFrame;

      final bytes = await _captureBoundary(boundaryKey);
      overlayEntry.remove();
      overlayEntry = null;

      if (bytes == null || bytes.isEmpty) {
        return const TicketDownloadResult(
          status: TicketDownloadStatus.failed,
          message: 'Unable to capture ticket. Please try again.',
        );
      }

      await _saveToGallery(bytes, _buildFileName(ticket.ticketCode));

      return const TicketDownloadResult(
        status: TicketDownloadStatus.success,
        message: 'Ticket saved to gallery',
      );
    } on _GalleryAccessDeniedException {
      return const TicketDownloadResult(
        status: TicketDownloadStatus.cancelled,
        message:
            'Permission denied. Enable Photos access in Settings to save tickets.',
      );
    } on GalException catch (e) {
      debugPrint('Ticket download GalException: ${e.type} ${e.type.message}');
      if (e.type == GalExceptionType.accessDenied) {
        return const TicketDownloadResult(
          status: TicketDownloadStatus.cancelled,
          message:
              'Permission denied. Enable Photos access in Settings to save tickets.',
        );
      }
      return TicketDownloadResult(
        status: TicketDownloadStatus.failed,
        message: e.type.message,
      );
    } catch (e, st) {
      debugPrint('Ticket download failed: $e\n$st');
      final raw = e.toString();
      if (raw.contains('MissingPluginException')) {
        return const TicketDownloadResult(
          status: TicketDownloadStatus.failed,
          message: 'Please fully restart the app, then try downloading again.',
        );
      }
      return TicketDownloadResult(
        status: TicketDownloadStatus.failed,
        message: 'Failed to save ticket: ${_shortError(raw)}',
      );
    } finally {
      overlayEntry?.remove();
    }
  }

  Uint8List? _decodeQrBytes(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    try {
      final base64Part = raw.contains(',') ? raw.split(',').last : raw;
      return base64Decode(base64Part);
    } catch (_) {
      return null;
    }
  }

  Future<Uint8List?> _captureBoundary(GlobalKey boundaryKey) async {
    final boundary =
        boundaryKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) return null;

    for (var i = 0; i < 20; i++) {
      await WidgetsBinding.instance.endOfFrame;
      if (!_needsPaint(boundary)) break;
      await Future<void>.delayed(const Duration(milliseconds: 16));
    }

    final image = await boundary.toImage(pixelRatio: 2.0);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData?.buffer.asUint8List();
  }

  bool _needsPaint(RenderRepaintBoundary boundary) {
    var needsPaint = false;
    assert(() {
      needsPaint = boundary.debugNeedsPaint;
      return true;
    }());
    return needsPaint;
  }

  Future<void> _saveToGallery(Uint8List bytes, String name) async {
    final hasAccess = await Gal.hasAccess();
    if (!hasAccess) {
      final granted = await Gal.requestAccess();
      if (!granted) throw const _GalleryAccessDeniedException();
    }

    final tempFile = await _writeTempPng(bytes, name);
    try {
      if (tempFile != null) {
        await Gal.putImage(tempFile.path);
      } else {
        await Gal.putImageBytes(bytes, name: name);
      }
    } finally {
      if (tempFile != null && await tempFile.exists()) {
        try {
          await tempFile.delete();
        } catch (_) {}
      }
    }
  }

  Future<File?> _writeTempPng(Uint8List bytes, String name) async {
    try {
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/$name.png');
      await file.writeAsBytes(bytes, flush: true);
      return file;
    } catch (e) {
      debugPrint('Temp ticket file write failed: $e');
      return null;
    }
  }

  String _buildFileName(String? ticketCode) {
    final safeCode = (ticketCode == null || ticketCode.trim().isEmpty)
        ? 'ticket'
        : ticketCode.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '');
    return 'jamiat_${safeCode}_${DateTime.now().millisecondsSinceEpoch}';
  }

  String _shortError(String raw) {
    final cleaned = raw
        .replaceAll('Exception: ', '')
        .replaceAll('FlutterError: ', '')
        .trim();
    if (cleaned.length <= 120) return cleaned;
    return '${cleaned.substring(0, 117)}...';
  }

  Future<void> openSettings() => openAppSettings();
}

class _GalleryAccessDeniedException implements Exception {
  const _GalleryAccessDeniedException();
}

/// Offscreen ticket card used only for capture (mirrors on-screen design).
class _TicketCaptureCard extends StatelessWidget {
  const _TicketCaptureCard({
    required this.ticket,
    required this.qrBytes,
  });

  final EventTicketModel ticket;
  final Uint8List? qrBytes;

  @override
  Widget build(BuildContext context) {
    final dateLabel = formatEventShortDate(ticket.eventDate);
    final timeLabel = formatEventTime(ticket.eventDate);
    final qrData = (ticket.qrToken != null && ticket.qrToken!.isNotEmpty)
        ? ticket.qrToken!
        : ticket.ticketCode;

    return Material(
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
          mainAxisSize: MainAxisSize.min,
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
                  Text('Jamiat Welfare Committee', style: kCaption14M),
                ],
              ),
            ),
            Container(height: 1, color: kBorder),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _Meta(
                          label: 'Date',
                          value: dateLabel.isEmpty ? '—' : dateLabel,
                        ),
                      ),
                      Expanded(
                        child: _Meta(
                          label: 'Time',
                          value: timeLabel.isEmpty ? '—' : timeLabel,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: _Meta(
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
                    child: qrBytes != null
                        ? Image.memory(
                            qrBytes!,
                            width: 180,
                            height: 180,
                            fit: BoxFit.contain,
                            gaplessPlayback: true,
                            filterQuality: FilterQuality.none,
                            errorBuilder: (_, _, _) => _QrFallback(data: qrData),
                          )
                        : _QrFallback(data: qrData),
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
    );
  }
}

class _QrFallback extends StatelessWidget {
  const _QrFallback({required this.data});

  final String data;

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
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

class _Meta extends StatelessWidget {
  const _Meta({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: kCaption12R.copyWith(color: kSecondaryTextColor)),
        const SizedBox(height: 4),
        Text(value, style: kCaption14M),
      ],
    );
  }
}
