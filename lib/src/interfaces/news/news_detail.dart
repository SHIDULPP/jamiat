import 'package:flutter/material.dart';
import 'package:jamiat/src/data/constants/color_constants.dart';
import 'package:jamiat/src/data/constants/style_constants.dart';
import 'package:jamiat/src/data/services/haptic_helper.dart';

class NewsDetailScreen extends StatelessWidget {
  final String newsId;

  const NewsDetailScreen({super.key, required this.newsId});

  // Fetch article mock content
  Map<String, String> _getArticleData() {
    switch (newsId) {
      case '2':
        return {
          'title':
              'Flood relief update- thank you for your support, 218 families helped.',
          'image': 'assets/jpgs/campaign_welfare.jpg',
          'published': 'PUBLISHED ON  15 July 2026 • 5 mins read',
          'content':
              'Lorem ipsum dolor sit amet consectetur. Faucibus quam arcu sed iaculis malesuada ullamcorper ut phasellus. Aliquet nibh eget tristique gravida. Pretium lorem in mi pulvinar et ultricies ultrices eget. Enim diam odio semper faucibus nunc quis sit feugiat.\n\nSollicitudin. Felis vitae commodo at tempor quam nulla in vel sed. Ipsum integer faucibus commodo gravida nisl pulvinar tortor. Vitae ultrices in elementum cursus diam. Massa egestas ultricies tempor amet.\n\nPretium laoreet ridiculus sem et neque fermentum ornare malesuada cursus. Sem vestibulum nunc egestas bibendum blandit eu neque. Eu dui ullamcorper quis molestie sed vel. Ornare justo augue volutpat sit mattis quam consequat rutrum amet. Eu dapibus arcu egestas ac tristique. Cursus vulputate mattis ultrices velit pellentesque eros molestie viverra. Aliquet nisl ultricies netus vitae semper convallis ligula. Sit sed odio est integer nibh quis egestas bibendum. Mattis convallis et neque odio curabitur neque.\n\nDignissim at viverra massa at. Sit in id quis lorem a risus tellus habitant. Sed id amet diam sed maecenas in. Enim leo integer est eu adipiscing congue posuere. Adipiscing arcu viverra nisl porttitor magna nunc purus blandit. Purus lectus hendrerit volutpat mi aliquam amet tortor curabitur egestas. At dapibus faucibus praesent ultricies dolor. Turpis nibh aliquam porta cras. Odio in duis morbi eleifend. Magna arcu scelerisque quis commodo mauris. Suspendisse suspendisse a nam turpis tellus.',
        };
      case '3':
      case '5':
        return {
          'title': 'Jamiat Youth Club Kerala wins 9 award at Jamboree',
          'image': 'assets/jpgs/campaign_welfare.jpg',
          'published': 'PUBLISHED ON  30 August 2026 • 4 mins read',
          'content':
              'Lorem ipsum dolor sit amet consectetur. Faucibus quam arcu sed iaculis malesuada ullamcorper ut phasellus. Aliquet nibh eget tristique gravida. Pretium lorem in mi pulvinar et ultricies ultrices eget. Enim diam odio semper faucibus nunc quis sit feugiat.\n\nSollicitudin. Felis vitae commodo at tempor quam nulla in vel sed. Ipsum integer faucibus commodo gravida nisl pulvinar tortor. Vitae ultrices in elementum cursus diam. Massa egestas ultricies tempor amet.\n\nPretium laoreet ridiculus sem et neque fermentum ornare malesuada cursus. Sem vestibulum nunc egestas bibendum blandit eu neque. Eu dui ullamcorper quis molestie sed vel. Ornare justo augue volutpat sit mattis quam consequat rutrum amet. Eu dapibus arcu egestas ac tristique. Cursus vulputate mattis ultrices velit pellentesque eros molestie viverra. Aliquet nisl ultricies netus vitae semper convallis ligula. Sit sed odio est integer nibh quis egestas bibendum. Mattis convallis et neque odio curabitur neque.\n\nDignissim at viverra massa at. Sit in id quis lorem a risus tellus habitant. Sed id amet diam sed maecenas in. Enim leo integer est eu adipiscing congue posuere. Adipiscing arcu viverra nisl porttitor magna nunc purus blandit. Purus lectus hendrerit volutpat mi aliquam amet tortor curabitur egestas. At dapibus faucibus praesent ultricies dolor. Turpis nibh aliquam porta cras. Odio in duis morbi eleifend. Magna arcu scelerisque quis commodo mauris. Suspendisse suspendisse a nam turpis tellus.',
        };
      case '4':
        return {
          'title': 'Green Kerala Campaign hits 100% goal - 5,000 trees planted',
          'image': 'assets/jpgs/campaign_welfare.jpg',
          'published': 'PUBLISHED ON  12 September 2026 • 6 mins read',
          'content':
              'Lorem ipsum dolor sit amet consectetur. Faucibus quam arcu sed iaculis malesuada ullamcorper ut phasellus. Aliquet nibh eget tristique gravida. Pretium lorem in mi pulvinar et ultricies ultrices eget. Enim diam odio semper faucibus nunc quis sit feugiat.\n\nSollicitudin. Felis vitae commodo at tempor quam nulla in vel sed. Ipsum integer faucibus commodo gravida nisl pulvinar tortor. Vitae ultrices in elementum cursus diam. Massa egestas ultricies tempor amet.\n\nPretium laoreet ridiculus sem et neque fermentum ornare malesuada cursus. Sem vestibulum nunc egestas bibendum blandit eu neque. Eu dui ullamcorper quis molestie sed vel. Ornare justo augue volutpat sit mattis quam consequat rutrum amet. Eu dapibus arcu egestas ac tristique. Cursus vulputate mattis ultrices velit pellentesque eros molestie viverra. Aliquet nisl ultricies netus vitae semper convallis ligula. Sit sed odio est integer nibh quis egestas bibendum. Mattis convallis et neque odio curabitur neque.\n\nDignissim at viverra massa at. Sit in id quis lorem a risus tellus habitant. Sed id amet diam sed maecenas in. Enim leo integer est eu adipiscing congue posuere. Adipiscing arcu viverra nisl porttitor magna nunc purus blandit. Purus lectus hendrerit volutpat mi aliquam amet tortor curabitur egestas. At dapibus faucibus praesent ultricies dolor. Turpis nibh aliquam porta cras. Odio in duis morbi eleifend. Magna arcu scelerisque quis commodo mauris. Suspendisse suspendisse a nam turpis tellus.',
        };
      case '1':
      default:
        return {
          'title': 'Annual Jamiat conference - registration open',
          'image': 'assets/jpgs/campaign_education.jpg',
          'published': 'PUBLISHED ON  2 June 2026 • 3 mins read',
          'content':
              'Lorem ipsum dolor sit amet consectetur. Faucibus quam arcu sed iaculis malesuada ullamcorper ut phasellus. Aliquet nibh eget tristique gravida. Pretium lorem in mi pulvinar et ultricies ultrices eget. Enim diam odio semper faucibus nunc quis sit feugiat.\n\nSollicitudin. Felis vitae commodo at tempor quam nulla in vel sed. Ipsum integer faucibus commodo gravida nisl pulvinar tortor. Vitae ultrices in elementum cursus diam. Massa egestas ultricies tempor amet.\n\nPretium laoreet ridiculus sem et neque fermentum ornare malesuada cursus. Sem vestibulum nunc egestas bibendum blandit eu neque. Eu dui ullamcorper quis molestie sed vel. Ornare justo augue volutpat sit mattis quam consequat rutrum amet. Eu dapibus arcu egestas ac tristique. Cursus vulputate mattis ultrices velit pellentesque eros molestie viverra. Aliquet nisl ultricies netus vitae semper convallis ligula. Sit sed odio est integer nibh quis egestas bibendum. Mattis convallis et neque odio curabitur neque.\n\nDignissim at viverra massa at. Sit in id quis lorem a risus tellus habitant. Sed id amet diam sed maecenas in. Enim leo integer est eu adipiscing congue posuere. Adipiscing arcu viverra nisl porttitor magna nunc purus blandit. Purus lectus hendrerit volutpat mi aliquam amet tortor curabitur egestas. At dapibus faucibus praesent ultricies dolor. Turpis nibh aliquam porta cras. Odio in duis morbi eleifend. Magna arcu scelerisque quis commodo mauris. Suspendisse suspendisse a nam turpis tellus.',
        };
    }
  }

  @override
  Widget build(BuildContext context) {
    final article = _getArticleData();

    return Scaffold(
      backgroundColor: kWhite,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row (Back Button only)
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
                ],
              ),
            ),

            // Scrollable Article Details
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Main Article Banner Image
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.asset(
                        article['image']!,
                        height: 220,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 220,
                            color: kScreenBg,
                            child: const Icon(
                              Icons.image_outlined,
                              color: kMutedText,
                              size: 40,
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Article Title
                    Text(
                      article['title']!,
                      style: kHeadTitleB.copyWith(
                        color: kTextColor,
                        fontSize: 20,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Publish date & read time metadata
                    Text(
                      article['published']!,
                      style: kCaption10M.copyWith(
                        color: kMutedText,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Article Text Content
                    Text(
                      article['content']!,
                      style: kBodyTitleR.copyWith(
                        color: kTextColor,
                        fontSize: 14.5,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 36),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
