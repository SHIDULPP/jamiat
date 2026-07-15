import 'package:flutter/material.dart';
import 'package:jamiat/src/data/constants/color_constants.dart';
import 'package:jamiat/src/data/constants/style_constants.dart';
import 'package:jamiat/src/data/services/haptic_helper.dart';
import 'package:jamiat/src/data/services/navigation_services.dart';

class SavedDonationsScreen extends StatefulWidget {
  const SavedDonationsScreen({super.key});

  @override
  State<SavedDonationsScreen> createState() => _SavedDonationsScreenState();
}

class _SavedDonationsScreenState extends State<SavedDonationsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Initial list of saved campaigns
  final List<Map<String, dynamic>> _allSavedCampaigns = [
    {
      'id': '1',
      'title': 'Maktab support fund 2026',
      'description':
          'Providing resources and infrastructure for Islamic education centers in rural areas',
      'category': 'General Funding',
      'image': 'assets/jpgs/campaign_education.jpg',
      'raised': 68000,
      'goal': 100000,
      'daysLeft': 2,
      'isBookmarked': true,
    },
    {
      'id': '5', // Unique ID for Flood Relief
      'title': 'Flood relief-Kerala',
      'description':
          'Emergency relief support for families displaced by recent flooding across costal areas',
      'category': 'General Funding',
      'image': 'assets/jpgs/campaign_welfare.jpg',
      'raised': 75000,
      'goal': 100000,
      'daysLeft': 18,
      'isBookmarked': true,
    },
  ];

  List<Map<String, dynamic>> get _filteredCampaigns {
    if (_searchQuery.isEmpty) {
      return _allSavedCampaigns;
    }
    final query = _searchQuery.toLowerCase();
    return _allSavedCampaigns.where((campaign) {
      final title = (campaign['title'] as String).toLowerCase();
      final desc = (campaign['description'] as String).toLowerCase();
      final cat = (campaign['category'] as String).toLowerCase();
      return title.contains(query) ||
          desc.contains(query) ||
          cat.contains(query);
    }).toList();
  }

  String _formatRupee(int amount) {
    final raw = amount.toString();
    final buf = StringBuffer();
    final len = raw.length;
    int count = 0;

    for (int i = len - 1; i >= 0; i--) {
      buf.write(raw[i]);
      count++;
      if (count == 3 && i > 0) {
        buf.write(',');
      } else if (count > 3 && (count - 3) % 2 == 0 && i > 0) {
        buf.write(',');
      }
    }
    return '₹ ${buf.toString().split('').reversed.join('')}';
  }

  Widget _buildCampaignCard(Map<String, dynamic> campaign) {
    final int raised = campaign['raised'] as int;
    final int goal = campaign['goal'] as int;
    final double progress = goal <= 0 ? 0 : (raised / goal).clamp(0.0, 1.0);
    final int percent = (progress * 100).round();
    final int daysLeft = campaign['daysLeft'] as int;
    final bool isBookmarked = campaign['isBookmarked'] as bool;

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
          // Stack containing image and header badges
          SizedBox(
            height: 180,
            width: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  campaign['image'] as String,
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
                // Category Tag
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
                      campaign['category'] as String,
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
                      // Share button
                      GestureDetector(
                        onTap: () {
                          HapticHelper.impact(HapticImpact.light);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Shared "${campaign['title']}" successfully!',
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
                      // Bookmark button
                      GestureDetector(
                        onTap: () {
                          HapticHelper.impact(HapticImpact.medium);
                          setState(() {
                            campaign['isBookmarked'] = !isBookmarked;
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
          // Details body
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  campaign['title'] as String,
                  style: kBodyTitleSB.copyWith(fontSize: 16),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text(
                  campaign['description'] as String,
                  style: kCaption12R.copyWith(color: kMutedText, height: 1.4),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 14),
                // Yellow Progress indicator
                ClipRRect(
                  borderRadius: BorderRadius.circular(kPillRadius),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: kGreyLight,
                    color: kSecondaryColor,
                  ),
                ),
                const SizedBox(height: 10),
                // Metrics row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_formatRupee(raised), style: kBodyTitleSB),
                          const SizedBox(height: 2),
                          Text(
                            'of ${_formatRupee(goal)}',
                            style: kCaption12R.copyWith(
                              color: kSecondaryTextColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('$percent%', style: kBodyTitleSB),
                        const SizedBox(height: 2),
                        Text(
                          '$daysLeft days left',
                          style: kCaption12M.copyWith(color: kDaysLeftWarning),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                // Donate Now button
                ElevatedButton(
                  onPressed: () {
                    HapticHelper.impact(HapticImpact.medium);
                    NavigationService().pushNamed(
                      'CampaignDetails',
                      arguments: {
                        'title': campaign['title'],
                        'description': campaign['description'],
                        'image': campaign['image'],
                        'category': campaign['category'],
                        'raised': campaign['raised'],
                        'goal': campaign['goal'],
                        'daysLeft': campaign['daysLeft'],
                      },
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryColor,
                    foregroundColor: kWhite,
                    minimumSize: const Size.fromHeight(48),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    'Donate Now',
                    style: kButtonLabelSB.copyWith(fontSize: 16),
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
    final campaigns = _filteredCampaigns;

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
                    'Saved Donations',
                    style: kHeadTitleB.copyWith(
                      color: kTextColor,
                      fontSize: 22,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Search Input Bar
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
                          hintText: 'Search for campaigns',
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
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Campaigns List View
              Expanded(
                child: campaigns.isEmpty
                    ? Center(
                        child: Text(
                          'No saved donations found',
                          style: kEmptyStateM,
                        ),
                      )
                    : ListView.builder(
                        itemCount: campaigns.length,
                        itemBuilder: (context, index) {
                          return _buildCampaignCard(campaigns[index]);
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
