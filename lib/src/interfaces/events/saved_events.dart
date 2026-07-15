import 'package:flutter/material.dart';
import 'package:jamiat/src/data/constants/color_constants.dart';
import 'package:jamiat/src/data/constants/style_constants.dart';
import 'package:jamiat/src/data/services/haptic_helper.dart';

class SavedEventsScreen extends StatefulWidget {
  const SavedEventsScreen({super.key});

  @override
  State<SavedEventsScreen> createState() => _SavedEventsScreenState();
}

class _SavedEventsScreenState extends State<SavedEventsScreen> {
  final List<Map<String, dynamic>> _savedEvents = [
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
      'isBookmarked': true,
    },
    {
      'id': '3',
      'title': 'Community Iftar & fundraiser dinner',
      'category': 'Charity',
      'date': '07 Jun, 2026 • 10:45 am - 3:30pm',
      'location': 'Ernakulam Town Hall',
      'image': 'assets/jpgs/campaign_welfare.jpg',
      'isBookmarked': true,
    },
  ];

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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticHelper.impact(HapticImpact.light);
            Navigator.pushNamed(
              context,
              'EventDetails',
              arguments: {
                'title': event['title'],
                'category': event['category'],
                'date': event['date'],
                'location': event['location'],
                'image': event['image'],
                'isBookmarked': event['isBookmarked'],
              },
            );
          },
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
                      style: kBodyTitleB.copyWith(
                        fontSize: 16,
                        color: kTextColor,
                      ),
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
                            style: kCaption12R.copyWith(
                              color: kSecondaryTextColor,
                            ),
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
                            style: kCaption12R.copyWith(
                              color: kSecondaryTextColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                    'Saved events',
                    style: kHeadTitleB.copyWith(
                      color: kTextColor,
                      fontSize: 22,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Events list builder
              Expanded(
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: _savedEvents.length + 1, // list + bottom header
                  itemBuilder: (context, index) {
                    if (index == _savedEvents.length) {
                      // Bottom Ended Events row
                      return Padding(
                        padding: const EdgeInsets.only(top: 14, bottom: 24),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Recently ended',
                              style: kSectionTitleSB.copyWith(
                                color: kTextColor,
                                fontSize: 16,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                HapticHelper.impact(HapticImpact.light);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Showing all ended events...',
                                      style: kCaption14M.copyWith(
                                        color: kWhite,
                                      ),
                                    ),
                                    backgroundColor: kPrimaryColor,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                );
                              },
                              child: Text('See all', style: kLinkM),
                            ),
                          ],
                        ),
                      );
                    }
                    return _buildEventCard(_savedEvents[index]);
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
