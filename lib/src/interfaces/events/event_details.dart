import 'package:flutter/material.dart';
import 'package:jamiat/src/data/constants/color_constants.dart';
import 'package:jamiat/src/data/constants/style_constants.dart';
import 'package:jamiat/src/data/services/haptic_helper.dart';

class EventDetailsScreen extends StatefulWidget {
  final String title;
  final String category;
  final String date;
  final String location;
  final String image;
  final bool isBookmarked;

  const EventDetailsScreen({
    super.key,
    required this.title,
    required this.category,
    required this.date,
    required this.location,
    required this.image,
    required this.isBookmarked,
  });

  @override
  State<EventDetailsScreen> createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen> {
  late bool _isBookmarked;

  @override
  void initState() {
    super.initState();
    _isBookmarked = widget.isBookmarked;
  }

  Widget _buildPersonRow(String name, String role, String avatarAsset) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          ClipOval(
            child: Image.asset(
              avatarAsset,
              width: 48,
              height: 48,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 48,
                  height: 48,
                  color: kScreenBg,
                  child: const Icon(Icons.person_outline, color: kMutedText),
                );
              },
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: kBodyTitleB.copyWith(color: kTextColor, fontSize: 15),
                ),
                const SizedBox(height: 2),
                Text(role, style: kCaption12R.copyWith(color: kMutedText)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kWhite,
      body: SafeArea(
        child: Column(
          children: [
            // Header row with back, title, share, bookmark buttons
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
                    'Event Details',
                    style: kHeadTitleB.copyWith(
                      color: kTextColor,
                      fontSize: 20,
                    ),
                  ),
                  const Spacer(),
                  // Share Button
                  GestureDetector(
                    onTap: () {
                      HapticHelper.impact(HapticImpact.light);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Shared "${widget.title}" details successfully!',
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
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: kWhite,
                        border: Border.all(color: kBorder, width: 1.25),
                      ),
                      child: const Icon(
                        Icons.share_outlined,
                        color: kTextColor,
                        size: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Bookmark Button
                  GestureDetector(
                    onTap: () {
                      HapticHelper.impact(HapticImpact.medium);
                      setState(() {
                        _isBookmarked = !_isBookmarked;
                      });
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: kWhite,
                        border: Border.all(color: kBorder, width: 1.25),
                      ),
                      child: Icon(
                        _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                        color: _isBookmarked ? kPrimaryColor : kTextColor,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Scrollable event content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Banner Image
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.asset(
                        widget.image,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 200,
                            width: double.infinity,
                            color: kScreenBg,
                            child: const Icon(
                              Icons.image_outlined,
                              color: kMutedText,
                              size: 48,
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Event Title
                    Text(
                      widget.title,
                      style: kHeadTitleB.copyWith(
                        color: kTextColor,
                        fontSize: 22,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Date row
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today_outlined,
                          size: 16,
                          color: kSecondaryTextColor,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            widget.date,
                            style: kCaption14M.copyWith(
                              color: kSecondaryTextColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Location row
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 16,
                          color: kSecondaryTextColor,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            widget.location,
                            style: kCaption14M.copyWith(
                              color: kSecondaryTextColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // About Event Section
                    Text(
                      'About Event',
                      style: kSectionTitleSB.copyWith(
                        color: kTextColor,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Providing emergency financial support to families unable to afford critical medical treatment. Your donation directly funds hospital bills, medicines, and post - surgery care.',
                      style: kCaption14M.copyWith(
                        color: kTextColor,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Guests Section
                    Text(
                      'Guests',
                      style: kSectionTitleSB.copyWith(
                        color: kTextColor,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildPersonRow(
                      'Raihan Muhhammed',
                      'Jamaith President',
                      'assets/pngs/dummy_avatar.png',
                    ),
                    _buildPersonRow(
                      'Siti Nurhaliza',
                      'Celebrity',
                      'assets/pngs/dummy_avatar.png',
                    ),
                    _buildPersonRow(
                      'Ahmad Fauzi',
                      'Jamaith Secretary',
                      'assets/pngs/dummy_avatar.png',
                    ),
                    const SizedBox(height: 14),

                    // Event Coordinators Section
                    Text(
                      'Event Coordinators',
                      style: kSectionTitleSB.copyWith(
                        color: kTextColor,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildPersonRow(
                      'Manaf',
                      'Event Coordinator',
                      'assets/pngs/dummy_avatar.png',
                    ),
                    _buildPersonRow(
                      'Mehar Muhhamed',
                      'Event Coordinator',
                      'assets/pngs/dummy_avatar.png',
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),

            // Persistent bottom button container
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                color: kWhite,
                boxShadow: [
                  BoxShadow(
                    color: kBlack.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () {
                  HapticHelper.impact(HapticImpact.medium);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Successfully registered for "${widget.title}"!',
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
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryColor,
                  foregroundColor: kWhite,
                  minimumSize: const Size.fromHeight(54),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  'Register',
                  style: kButtonLabelSB.copyWith(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
