import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jamiat/src/data/constants/color_constants.dart';
import 'package:jamiat/src/data/constants/style_constants.dart';
import 'package:jamiat/src/data/providers/event_provider.dart';
import 'package:jamiat/src/data/services/haptic_helper.dart';
import 'package:jamiat/src/data/services/navigation_services.dart';
import 'package:jamiat/src/interfaces/components/async_content.dart';

class MyTicketsScreen extends ConsumerStatefulWidget {
  const MyTicketsScreen({super.key});

  @override
  ConsumerState<MyTicketsScreen> createState() => _MyTicketsScreenState();
}

class _MyTicketsScreenState extends ConsumerState<MyTicketsScreen> {
  bool _isUpcomingSelected = true;

  @override
  Widget build(BuildContext context) {
    final tab = _isUpcomingSelected ? 'upcoming' : 'past';
    final ticketsAsync = ref.watch(myTicketsProvider(tab));

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
                    'My Tickets',
                    style: kHeadTitleB.copyWith(
                      color: kTextColor,
                      fontSize: 22,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  _tabChip('Upcoming', _isUpcomingSelected, () {
                    setState(() => _isUpcomingSelected = true);
                  }),
                  const SizedBox(width: 10),
                  _tabChip('Past', !_isUpcomingSelected, () {
                    setState(() => _isUpcomingSelected = false);
                  }),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: AsyncContent(
                asyncValue: ticketsAsync,
                onRetry: () => ref.invalidate(myTicketsProvider(tab)),
                builder: (tickets) {
                  if (tickets.isEmpty) {
                    return Center(
                      child: Text('No tickets found', style: kEmptyStateM),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    itemCount: tickets.length,
                    itemBuilder: (context, index) {
                      final ticket = tickets[index];
                      return GestureDetector(
                        onTap: () {
                          NavigationService().pushNamed(
                            'EventTicket',
                            arguments: {
                              'ticketId': ticket.id,
                              'title': ticket.eventTitle ?? 'Event',
                              'date': ticket.eventDate ?? '',
                              'venue': ticket.venue ?? '',
                            },
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: kScreenBg,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                ticket.eventTitle ?? 'Event',
                                style: kBodyTitleB,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '${ticket.ticketCode} • ${ticket.status}',
                                style: kCaption12R.copyWith(
                                  color: kSecondaryTextColor,
                                ),
                              ),
                              if (ticket.venue != null) ...[
                                const SizedBox(height: 4),
                                Text(
                                  ticket.venue!,
                                  style: kCaption12R.copyWith(
                                    color: kMutedText,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tabChip(String label, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 38,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: active ? const Color(0xFFFBBF24) : kWhite,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: active ? Colors.transparent : kBorder),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: kCaption14M.copyWith(
            color: active ? const Color(0xFF451A03) : kMutedText,
            fontWeight: kBold,
          ),
        ),
      ),
    );
  }
}
