import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:jamiat/src/data/constants/color_constants.dart';
import 'package:jamiat/src/data/constants/style_constants.dart';
import 'package:jamiat/src/data/services/haptic_helper.dart';
import 'package:jamiat/src/interfaces/market/market_product_data.dart';

class MarketProductCard extends StatelessWidget {
  const MarketProductCard({
    super.key,
    required this.product,
    required this.onViewDetails,
    this.showBookmark = false,
    this.isBookmarked = false,
    this.onBookmark,
  });

  final MarketProduct product;
  final VoidCallback onViewDetails;
  final bool showBookmark;
  final bool isBookmarked;
  final VoidCallback? onBookmark;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: kMarketCardAspectRatio,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: kWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: kBorder.withValues(alpha: 0.6)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: kMarketImageHeight.round(),
                child: _ProductImage(
                  imagePath: product.imagePath,
                  showBookmark: showBookmark,
                  isBookmarked: isBookmarked,
                  onBookmark: onBookmark,
                ),
              ),
              Expanded(
                flex: (kMarketCardHeight - kMarketImageHeight).round(),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          product.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: kBodyTitleM.copyWith(
                            color: kTextColor,
                            fontSize: 13,
                            height: 1.25,
                          ),
                        ),
                      ),
                      Text(
                        product.formattedPrice,
                        style: kBodyTitleB.copyWith(
                          color: kTextColor,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () {
                          HapticHelper.impact(HapticImpact.light);
                          onViewDetails();
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 9),
                          decoration: BoxDecoration(
                            color: kPrimaryColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              'View Details',
                              style: kButtonLabelSB.copyWith(
                                color: kWhite,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProductImage extends StatelessWidget {
  const _ProductImage({
    required this.imagePath,
    required this.showBookmark,
    required this.isBookmarked,
    this.onBookmark,
  });

  final String imagePath;
  final bool showBookmark;
  final bool isBookmarked;
  final VoidCallback? onBookmark;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          imagePath,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        ),
        if (showBookmark && onBookmark != null)
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: () {
                HapticHelper.impact(HapticImpact.light);
                onBookmark!();
              },
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.45),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: SvgPicture.asset(
                    'assets/svg/bookmark.svg',
                    width: 14,
                    height: 14,
                    colorFilter: ColorFilter.mode(
                      isBookmarked ? kSecondaryColor : kWhite,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
