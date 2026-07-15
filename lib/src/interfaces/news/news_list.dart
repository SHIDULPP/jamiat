import 'package:flutter/material.dart';
import 'package:jamiat/src/data/constants/color_constants.dart';
import 'package:jamiat/src/data/constants/style_constants.dart';
import 'package:jamiat/src/data/services/haptic_helper.dart';
import 'package:jamiat/src/data/services/navigation_services.dart';

class NewsListScreen extends StatefulWidget {
  const NewsListScreen({super.key});

  @override
  State<NewsListScreen> createState() => _NewsListScreenState();
}

class _NewsListScreenState extends State<NewsListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  static const List<Map<String, String>> _newsItems = [
    {
      'id': '1',
      'title': 'Annual Jamiat conference - registration open',
      'subtitle':
          'Lorem ipsum dolor sit amet consectetur. Enim tincidunt elementum tortor a dictum...',
      'date': '2 June 2026',
      'image': 'assets/jpgs/campaign_education.jpg',
      'readTime': '3 mins read',
    },
    {
      'id': '2',
      'title':
          'Flood relief update- thank you for your support, 218 families helped.',
      'subtitle':
          'Lorem ipsum dolor sit amet consectetur. Volutpat eget viverra nisl a feugiat duis...',
      'date': '15 July 2026',
      'image': 'assets/jpgs/campaign_welfare.jpg',
      'readTime': '5 mins read',
    },
    {
      'id': '3',
      'title': 'Jamiat Youth Club Kerala wins 9 award at Jamboree',
      'subtitle':
          'Lorem ipsum dolor sit amet consectetur. Eu nulla et eget tincidunt bibendum ferme...',
      'date': '30 August 2026',
      'image': 'assets/jpgs/campaign_welfare.jpg',
      'readTime': '4 mins read',
    },
    {
      'id': '4',
      'title': 'Green Kerala Campaign hits 100% goal - 5,000 trees planted',
      'subtitle':
          'Connect with industry leaders and explore the latest in technology and innovation.',
      'date': '12 September 2026',
      'image': 'assets/jpgs/campaign_housing.jpg',
      'readTime': '6 mins read',
    },
    {
      'id': '5',
      'title': 'Jamiat Youth Club Kerala wins 9 award at Jamboree',
      'subtitle':
          'Lorem ipsum dolor sit amet consectetur. Eu nulla et eget tincidunt bibendum ferme...',
      'date': '30 August 2026',
      'image': 'assets/jpgs/campaign_welfare.jpg',
      'readTime': '4 mins read',
    },
  ];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _newsItems.where((item) {
      if (_searchQuery.isEmpty) return true;
      final title = item['title']!.toLowerCase();
      final subtitle = item['subtitle']!.toLowerCase();
      return title.contains(_searchQuery) || subtitle.contains(_searchQuery);
    }).toList();

    return Scaffold(
      backgroundColor: kWhite,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
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
                    'News & Announcements',
                    style: kHeadTitleB.copyWith(
                      color: kTextColor,
                      fontSize: 22,
                    ),
                  ),
                ],
              ),
            ),

            // Search input field
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Container(
                decoration: BoxDecoration(
                  color: kWhite,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: kBorder, width: 1.25),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    const Icon(Icons.search, color: kMutedText, size: 22),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        style: kBodyTitleR.copyWith(color: kTextColor),
                        decoration: InputDecoration(
                          hintText: 'Search for news',
                          hintStyle: kBodyTitleR.copyWith(
                            color: kMutedText,
                            fontSize: 15,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Scrollable news cards list
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Text(
                        'No news articles found',
                        style: kEmptyStateM,
                      ),
                    )
                  : ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final item = filtered[index];

                        return GestureDetector(
                          onTap: () {
                            HapticHelper.impact(HapticImpact.light);
                            NavigationService().pushNamed(
                              'NewsDetail',
                              arguments: {'newsId': item['id']},
                            );
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: kWhite,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: kBorder),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Rounded Image Thumbnail
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.asset(
                                    item['image']!,
                                    width: 90,
                                    height: 90,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        width: 90,
                                        height: 90,
                                        color: kScreenBg,
                                        child: const Icon(
                                          Icons.image_outlined,
                                          color: kMutedText,
                                          size: 30,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(width: 16),

                                // Title and Meta Column
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item['title']!,
                                        style: kBodyTitleB.copyWith(
                                          color: kTextColor,
                                          fontSize: 15,
                                          height: 1.3,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        item['subtitle']!,
                                        style: kCaption12R.copyWith(
                                          color: kSecondaryTextColor,
                                          height: 1.35,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Text(
                                            item['date']!,
                                            style: kCaption10M.copyWith(
                                              color: kMutedText,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            '•',
                                            style: kCaption10M.copyWith(
                                              color: kMutedText,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            item['readTime']!,
                                            style: kCaption10M.copyWith(
                                              color: kMutedText,
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
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
