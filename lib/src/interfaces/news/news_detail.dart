import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jamiat/src/data/constants/color_constants.dart';
import 'package:jamiat/src/data/constants/style_constants.dart';
import 'package:jamiat/src/data/providers/news_provider.dart';
import 'package:jamiat/src/data/services/haptic_helper.dart';
import 'package:jamiat/src/data/utils/format_helpers.dart';
import 'package:jamiat/src/interfaces/components/async_content.dart';

class NewsDetailScreen extends ConsumerWidget {
  final String newsId;

  const NewsDetailScreen({super.key, required this.newsId});

  Widget _headerCircleButton({
    required Widget child,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: kWhite,
          border: Border.all(color: kGrey, width: 1.25),
        ),
        alignment: Alignment.center,
        child: child,
      ),
    );
  }

  Widget _banner(String? url) {
    return SizedBox(
      height: 182,
      width: double.infinity,
      child: url != null && url.startsWith('http')
          ? Image.network(
              url,
              fit: BoxFit.cover,
              width: double.infinity,
              height: 182,
              errorBuilder: (_, _, _) => Container(
                color: kScreenBg,
                child: const Icon(
                  Icons.image_outlined,
                  color: kMutedText,
                  size: 40,
                ),
              ),
            )
          : Image.asset(
              url ?? 'assets/jpgs/campaign_education.jpg',
              fit: BoxFit.cover,
              width: double.infinity,
              height: 182,
              errorBuilder: (_, _, _) => Container(
                color: kScreenBg,
                child: const Icon(
                  Icons.image_outlined,
                  color: kMutedText,
                  size: 40,
                ),
              ),
            ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final newsAsync = ref.watch(newsDetailProvider(newsId));

    return Scaffold(
      backgroundColor: kWhite,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                kScreenPaddingH,
                8,
                kScreenPaddingH,
                16,
              ),
              child: Row(
                children: [
                  _headerCircleButton(
                    onTap: () {
                      HapticHelper.impact(HapticImpact.light);
                      Navigator.pop(context);
                    },
                    child: const Icon(
                      Icons.arrow_back,
                      color: kTextColor,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: AsyncContent(
                asyncValue: newsAsync,
                onRetry: () => ref.invalidate(newsDetailProvider(newsId)),
                builder: (article) => SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: kScreenPaddingH,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(kCardRadiusMd),
                        child: _banner(article.image),
                      ),
                      const SizedBox(height: 16),
                      Text(article.title, style: kSectionTitleSB),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: Image.asset(
                              'assets/jpgs/campaign_education.jpg',
                              width: 40,
                              height: 40,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => Container(
                                width: 40,
                                height: 40,
                                color: kScreenBg,
                                child: const Icon(
                                  Icons.newspaper_outlined,
                                  color: kMutedText,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  article.subTitle?.isNotEmpty == true
                                      ? article.subTitle!
                                      : 'Jamiat Connect',
                                  style: kCaption12R.copyWith(
                                    color: kTextColor,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'PUBLISHED ON  ${formatDateLabel(article.createdAt)}',
                                  style: kCaption10SB.copyWith(
                                    color: kSecondaryTextColor,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        article.description,
                        style: kCaption12R.copyWith(
                          color: kTextColor,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 36),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
