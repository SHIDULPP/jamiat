import 'package:flutter/material.dart';
import 'package:jamiat/src/data/constants/color_constants.dart';
import 'package:jamiat/src/data/constants/style_constants.dart';
import 'package:jamiat/src/data/services/haptic_helper.dart';
import 'package:jamiat/src/data/services/navigation_services.dart';

class MyTicketsScreen extends StatefulWidget {
  const MyTicketsScreen({super.key});

  @override
  State<MyTicketsScreen> createState() => _MyTicketsScreenState();
}

class _MyTicketsScreenState extends State<MyTicketsScreen> {
  bool _isUpcomingSelected = true;

  final List<Map<String, dynamic>> _upcomingTickets = [
    {
      'title': 'Annual Jamiat Conference',
      'passType': 'General entry pass',
      'date': '20 Jun 2026',
      'ticketId': 'AJC12345',
      'venue': 'Ernakulam Town Hall',
      'month': 'May 2026',
    },
    {
      'title': 'Youth leadership workshop',
      'passType': 'Free entry pass',
      'date': '20 Jun 2026',
      'ticketId': 'AJC12345',
      'venue': 'Ernakulam Town Hall',
      'month': 'May 2026',
    },
  ];

  final List<Map<String, dynamic>> _pastTickets = [
    {
      'title': 'Community Clean up drive',
      'date': '20 Jun 2026',
      'venue': 'Townhall, Ernakulam',
      'status': 'Attended',
      'month': 'May 2026',
    },
    {
      'title': 'Islamic finance seminar',
      'date': '20 Jun 2026',
      'venue': 'Darbar hall, Ernakulam',
      'status': 'Missed',
      'month': 'May 2026',
    },
    {
      'title': 'Jem Graduation Ceremony',
      'date': '20 Jun 2026',
      'venue': 'Aspinwall, Kochi',
      'status': 'Attended',
      'month': 'May 2026',
    },
    {
      'title': 'Community Clean up drive',
      'date': '20 Jun 2026',
      'venue': 'Townhall, Ernakulam',
      'status': 'Attended',
      'month': 'May 2026',
    },
  ];

  Widget _buildTabButton(String label, int count, bool isActive) {
    return GestureDetector(
      onTap: () {
        HapticHelper.impact(HapticImpact.light);
        setState(() {
          _isUpcomingSelected = (label == 'Upcoming');
        });
      },
      child: Container(
        height: 38,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFFBBF24) : kWhite,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isActive ? Colors.transparent : kBorder,
            width: 1.25,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: kCaption14M.copyWith(
                color: isActive ? const Color(0xFF451A03) : kMutedText,
                fontWeight: kBold,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isActive ? kWhite : kBorder,
                shape: BoxShape.circle,
              ),
              child: Text(
                count.toString(),
                style: kCaption10M.copyWith(
                  color: isActive ? const Color(0xFF451A03) : kTextColor,
                  fontWeight: kBold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTicketCard(Map<String, dynamic> ticket) {
    if (!_isUpcomingSelected) {
      final String status = ticket['status'] as String? ?? 'Attended';
      final bool isAttended = status == 'Attended';
      final Color statusBg = isAttended
          ? const Color(0xFFDCFCE7)
          : const Color(0xFFFEE2E2);
      final Color statusText = isAttended
          ? const Color(0xFF16A34A)
          : const Color(0xFFDC2626);

      return Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: kWhite,
          borderRadius: BorderRadius.circular(kCardRadiusLg),
          border: Border.all(color: kBorder),
          boxShadow: [
            BoxShadow(
              color: kBlack.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Grey Top Segment
            Container(
              width: double.infinity,
              color: const Color(0xFFF3F4F6), // Cool Grey 100
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Text(
                ticket['title'] as String,
                style: kBodyTitleB.copyWith(color: kTextColor, fontSize: 15),
              ),
            ),

            // White Bottom Segment
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${ticket['date']} • ${ticket['venue']}',
                      style: kCaption12R.copyWith(
                        color: kSecondaryTextColor,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusBg,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      status,
                      style: kCaption12M.copyWith(
                        color: statusText,
                        fontWeight: kBold,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(kCardRadiusLg),
        border: Border.all(color: kBorder),
        boxShadow: [
          BoxShadow(
            color: kBlack.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cream Yellow Top Segment
          Container(
            width: double.infinity,
            color: const Color(0xFFFEF3C7), // Warm light amber 100
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ticket['title'] as String,
                  style: kBodyTitleB.copyWith(
                    color: const Color(0xFF78350F), // Amber 900
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  ticket['passType'] as String,
                  style: kCaption12R.copyWith(
                    color: const Color(0xFFB45309), // Amber 700
                  ),
                ),
              ],
            ),
          ),

          // Details segment
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Date & Ticket ID Row
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Date',
                            style: kCaption12R.copyWith(color: kMutedText),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            ticket['date'] as String,
                            style: kBodyTitleB.copyWith(
                              color: kTextColor,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Ticket ID',
                            style: kCaption12R.copyWith(color: kMutedText),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            ticket['ticketId'] as String,
                            style: kBodyTitleB.copyWith(
                              color: kTextColor,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Tap to show QR drawer capsule
                InkWell(
                  onTap: () {
                    HapticHelper.impact(HapticImpact.light);
                    NavigationService().pushNamed(
                      'EventTicket',
                      arguments: {
                        'title': ticket['title'],
                        'date': ticket['date'],
                        'venue': ticket['venue'],
                      },
                    );
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6), // Grey 100
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.qr_code_scanner,
                          color: kTextColor,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Tap to show QR',
                                style: kBodyTitleB.copyWith(
                                  color: kTextColor,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Present to program coordinators',
                                style: kCaption12R.copyWith(
                                  color: kMutedText,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.chevron_right,
                          color: kMutedText,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeTickets = _isUpcomingSelected ? _upcomingTickets : _pastTickets;

    // Group tickets by month header
    final Map<String, List<Map<String, dynamic>>> grouped = {};
    for (var ticket in activeTickets) {
      final month = ticket['month'] as String;
      grouped.putIfAbsent(month, () => []).add(ticket);
    }

    final months = grouped.keys.toList();

    return Scaffold(
      backgroundColor: kWhite,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
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
                    'My Tickets',
                    style: kHeadTitleB.copyWith(
                      color: kTextColor,
                      fontSize: 22,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Tab Toggle selector
              Row(
                children: [
                  _buildTabButton('Upcoming', 4, _isUpcomingSelected),
                  const SizedBox(width: 12),
                  _buildTabButton('Past', 6, !_isUpcomingSelected),
                ],
              ),
              const SizedBox(height: 24),

              // Grouped Tickets List
              Expanded(
                child: activeTickets.isEmpty
                    ? Center(
                        child: Text('No tickets found', style: kEmptyStateM),
                      )
                    : ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        itemCount: months.length,
                        itemBuilder: (context, mIndex) {
                          final month = months[mIndex];
                          final tickets = grouped[month]!;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Month header label
                              Padding(
                                padding: const EdgeInsets.only(
                                  bottom: 14,
                                  top: 6,
                                ),
                                child: Text(
                                  month,
                                  style: kSectionTitleSB.copyWith(
                                    color: kTextColor,
                                    fontSize: 14,
                                    fontWeight: kBold,
                                  ),
                                ),
                              ),
                              // Month ticket cards
                              ...tickets.map(_buildTicketCard),
                            ],
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
