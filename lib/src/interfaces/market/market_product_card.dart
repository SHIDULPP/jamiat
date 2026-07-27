import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:jamiat/src/data/constants/color_constants.dart';
import 'package:jamiat/src/data/constants/style_constants.dart';
import 'package:jamiat/src/data/services/haptic_helper.dart';
import 'package:jamiat/src/interfaces/market/market_product_data.dart';

/// Figma Offer Card surface (636:3103) — `#F6F6F6`, r14, no border.
const Color _kMarketCardSurface = Color(0xFFF6F6F6);

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
          color: _kMarketCardSurface,
          borderRadius: BorderRadius.circular(kCardRadiusMd),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(kCardRadiusMd),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: kMarketImageHeight,
                child: _ProductImage(
                  imagePath: product.imagePath,
                  showBookmark: showBookmark,
                  isBookmarked: isBookmarked,
                  onBookmark: onBookmark,
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  product.title,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: kCaption12R.copyWith(
                                    color: kTextColor,
                                    height: 1.2,
                                  ),
                                ),
                              ),
                              Text(
                                product.formattedPrice,
                                style: kBodyTitleSB.copyWith(height: 1.2),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: SizedBox(
                          height: 40,
                          width: double.infinity,
                          child: Material(
                            color: kPrimaryColor,
                            borderRadius: BorderRadius.circular(kCardRadiusSm),
                            child: InkWell(
                              onTap: () {
                                HapticHelper.impact(HapticImpact.light);
                                onViewDetails();
                              },
                              borderRadius:
                                  BorderRadius.circular(kCardRadiusSm),
                              child: Center(
                                child: Text(
                                  'View Details',
                                  style: kButtonLabelSB,
                                ),
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
