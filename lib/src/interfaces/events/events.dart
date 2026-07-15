import 'package:flutter/material.dart';
import 'package:jamiat/src/data/constants/color_constants.dart';
import 'package:jamiat/src/data/constants/style_constants.dart';
import 'package:jamiat/src/data/services/haptic_helper.dart';
import 'package:jamiat/src/data/services/navigation_services.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<Map<String, dynamic>> _allEvents = [
    {
      'id': '1',
      'title': 'Annual Jamiat Conference',
      'category': 'Conference',
      'date': '07 Jun, 2026 • 10:45 am - 3:30pm',
      'location': 'Ernakulam Town Hall',
      'image': 'assets/jpgs/campaign_education.jpg',
      'isBookmarked': true,
    },
    {
      'id': '2',
      'title': 'Community Iftar & fundraiser dinner',
      'category': 'Charity',
      'date': '07 Jun, 2026 • 10:45 am - 3:30pm',
      'location': 'Ernakulam Town Hall',
      'image': 'assets/jpgs/campaign_welfare.jpg',
      'isBookmarked': false,
    },
    {
      'id': '3',
      'title': 'Harvest of Hope: Community Dinner',
      'category': 'Charity',
      'date': '08 Jun, 2026 • 6:00 pm - 9:30pm',
      'location': 'Ernakulam Town Hall',
      'image': 'assets/jpgs/campaign_welfare.jpg',
      'isBookmarked': false,
    },
  ];

  List<Map<String, dynamic>> get _filteredEvents {
    if (_searchQuery.isEmpty) {
      return _allEvents;
    }
    final query = _searchQuery.toLowerCase();
    return _allEvents.where((event) {
      final title = (event['title'] as String).toLowerCase();
      final cat = (event['category'] as String).toLowerCase();
      final loc = (event['location'] as String).toLowerCase();
      return title.contains(query) ||
          cat.contains(query) ||
          loc.contains(query);
    }).toList();
  }

  Widget _buildEventCard(Map<String, dynamic> event) {
    final bool isBookmarked = event['isBookmarked'] as bool;

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
          // Banner Image section with badges
          SizedBox(
            height: 180,
            width: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  event['image'] as String,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: kScreenBg,
                      child: const Icon(
                        Icons.image_outlined,
                        color: kMutedText,
                        size: 40,
                      ),
                    );
                  },
                ),
                // Category Label badge
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: kBlack.withValues(alpha: 0.45),
                      borderRadius: BorderRadius.circular(kPillRadius),
                    ),
                    child: Text(
                      event['category'] as String,
                      style: kCaption10M.copyWith(color: kWhite),
                    ),
                  ),
                ),
                // Actions (Share & Bookmark)
                Positioned(
                  top: 10,
                  right: 10,
                  child: Row(
                    children: [
                      // Share action
                      GestureDetector(
                        onTap: () {
                          HapticHelper.impact(HapticImpact.light);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Shared "${event['title']}" successfully!',
                                style: kCaption14M.copyWith(color: kWhite),
                              ),
                              backgroundColor: kPrimaryColor,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          );
                        },
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: kBlack.withValues(alpha: 0.4),
                          ),
                          child: const Icon(
                            Icons.share_outlined,
                            color: kWhite,
                            size: 18,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Bookmark toggle action
                      GestureDetector(
                        onTap: () {
                          HapticHelper.impact(HapticImpact.medium);
                          setState(() {
                            event['isBookmarked'] = !isBookmarked;
                          });
                        },
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: kBlack.withValues(alpha: 0.4),
                          ),
                          child: Icon(
                            isBookmarked
                                ? Icons.bookmark
                                : Icons.bookmark_border,
                            color: isBookmarked ? kPrimaryColor : kWhite,
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Info Details body
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event['title'] as String,
                  style: kBodyTitleB.copyWith(fontSize: 16, color: kTextColor),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                // Date Row
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_outlined,
                      size: 14,
                      color: kSecondaryTextColor,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        event['date'] as String,
                        style: kCaption12R.copyWith(color: kSecondaryTextColor),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                // Location Row
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 14,
                      color: kSecondaryTextColor,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        event['location'] as String,
                        style: kCaption12R.copyWith(color: kSecondaryTextColor),
                      ),
                    ),
                  ],
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
    final events = _filteredEvents;

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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
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
                        'Events',
                        style: kHeadTitleB.copyWith(
                          color: kTextColor,
                          fontSize: 22,
                        ),
                      ),
                    ],
                  ),
                  // Header action 3-dot button
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: kWhite,
                      border: Border.all(color: kBorder, width: 1.25),
                    ),
                    child: PopupMenuButton<String>(
                      padding: EdgeInsets.zero,
                      icon: const Icon(
                        Icons.more_vert,
                        color: kTextColor,
                        size: 20,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: const BorderSide(color: kBorder, width: 1),
                      ),
                      color: kWhite,
                      elevation: 4,
                      offset: const Offset(0, 44),
                      onSelected: (value) {
                        HapticHelper.impact(HapticImpact.light);
                        if (value == 'my_tickets') {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Navigating to your upcoming registered tickets...',
                                style: kCaption14M.copyWith(color: kWhite),
                              ),
                              backgroundColor: kPrimaryColor,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          );
                        } else if (value == 'saved') {
                          NavigationService().pushNamed('SavedDonations');
                        }
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem<String>(
                          value: 'my_tickets',
                          height: 44,
                          child: Text(
                            'My Tickets',
                            style: kStyle(
                              kMedium,
                              15,
                              color: const Color(0xFF888888),
                            ),
                          ),
                        ),
                        const PopupMenuDivider(height: 1),
                        PopupMenuItem<String>(
                          value: 'saved',
                          height: 44,
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
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Unified Search & Filter bar
              Container(
                height: 48,
                decoration: BoxDecoration(
                  color: kWhite,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: kBorder),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    const Icon(Icons.search, color: kMutedText, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: (val) {
                          setState(() {
                            _searchQuery = val;
                          });
                        },
                        decoration: const InputDecoration(
                          hintText: 'Search for events...',
                          hintStyle: TextStyle(color: kMutedText, fontSize: 14),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                        style: kBodyTitleR.copyWith(
                          color: kTextColor,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: VerticalDivider(
                        color: kBorder,
                        width: 16,
                        thickness: 1.25,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        HapticHelper.impact(HapticImpact.light);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Filter preferences clicked!',
                              style: kCaption14M.copyWith(color: kWhite),
                            ),
                            backgroundColor: kPrimaryColor,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        );
                      },
                      child: const Icon(
                        Icons.tune_outlined,
                        color: kSecondaryColor,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // My Tickets Alert Banner Card
              GestureDetector(
                onTap: () {
                  HapticHelper.impact(HapticImpact.medium);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Navigating to your upcoming registered tickets...',
                        style: kCaption14M.copyWith(color: kWhite),
                      ),
                      backgroundColor: kPrimaryColor,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7), // Amber 100 soft background
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: const Color(0xFFFDE68A), // Amber 200 border
                      width: 1.25,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.local_activity_outlined,
                        color: kSecondaryColor,
                        size: 22,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'My Tickets',
                              style: kCaption12M.copyWith(
                                color: const Color(0xFFB45309), // Amber 700
                                fontSize: 11,
                                fontWeight: kBold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '2 upcoming events registered',
                              style: kBodyTitleB.copyWith(
                                color: const Color(0xFF78350F), // Amber 900
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right,
                        color: kSecondaryColor,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // Section Title
              Text(
                'Upcoming events',
                style: kSectionTitleSB.copyWith(
                  color: kTextColor,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 14),

              // Events list builder
              Expanded(
                child: events.isEmpty
                    ? Center(
                        child: Text(
                          'No upcoming events found',
                          style: kEmptyStateM,
                        ),
                      )
                    : ListView.builder(
                        itemCount: events.length,
                        itemBuilder: (context, index) {
                          return _buildEventCard(events[index]);
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
