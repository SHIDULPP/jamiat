import 'package:flutter/material.dart';
import 'package:jamiat/src/data/constants/color_constants.dart';
import 'package:jamiat/src/data/constants/style_constants.dart';
import 'package:jamiat/src/data/services/haptic_helper.dart';
import 'package:jamiat/src/interfaces/components/primarybutton.dart';
import 'package:jamiat/src/interfaces/market/market_product_data.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({super.key, required this.productId});

  final String productId;

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late bool _isSaved;

  MarketProduct? get _product => marketProductById(widget.productId);

  @override
  void initState() {
    super.initState();
    _isSaved = MarketSavedProducts.isSaved(widget.productId);
  }

  Widget _heroImage(String imagePath) {
    return AspectRatio(
      aspectRatio: 370 / 203,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(kCardRadiusMd),
        child: Image.asset(
          imagePath,
          fit: BoxFit.cover,
          width: double.infinity,
        ),
      ),
    );
  }

  List<(String, String)> _quickSpecs(MarketProduct product) {
    if (product.id != 'prayer_mat') return const [];
    return const [
      ('Size', '45" x 27" (Fits all adult heights)'),
      ('Thickness', '1.2 inches of premium memory foam'),
      ('Top Material', 'Hypoallergenic soft micro-velvet'),
      ('Maintenance', 'Removable outer cover for easy machine washing'),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final product = _product;
    if (product == null) {
      return Scaffold(
        backgroundColor: kWhite,
        body: SafeArea(
          child: Center(child: Text('Product not found', style: kEmptyStateM)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: kWhite,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(kScreenPaddingH, 8, kScreenPaddingH, 0),
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
                        color: kWhite.withValues(alpha: 0.08),
                        border: Border.all(color: kGrey, width: 1.25),
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        color: kTextColor,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Product Details',
                      style: kSectionTitleSB,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      HapticHelper.impact(HapticImpact.light);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Share coming soon'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: kWhite.withValues(alpha: 0.08),
                        border: Border.all(color: kGrey, width: 1.25),
                      ),
                      child: const Icon(
                        Icons.ios_share_outlined,
                        color: kTextColor,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: kScreenPaddingH),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _heroImage(product.imagePath),
                    const SizedBox(height: 16),
                    Text(
                      product.title,
                      style: kSubHeadingR.copyWith(
                        color: kTextColor,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: kScreenBg,
                          backgroundImage: AssetImage(product.sellerLogoPath),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'SELLERS',
                                style: kCaption10SB.copyWith(
                                  color: kSecondaryTextColor,
                                  letterSpacing: 0.2,
                                ),
                              ),
                              Text(
                                product.sellerName,
                                style: kCaption12R.copyWith(
                                  color: kTextColor,
                                  height: 1.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(product.formattedPrice, style: kSubHeadingSB),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'About Product',
                      style: kBodyTitleSB,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      product.description,
                      style: kCaption12R.copyWith(
                        color: kTextColor,
                        height: 1.4,
                      ),
                    ),
                    if (_quickSpecs(product).isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Text('Quick Specs', style: kBodyTitleSB),
                      const SizedBox(height: 8),
                      ..._quickSpecs(product).map(
                        (spec) => Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 120,
                                child: Text(
                                  spec.$1,
                                  style: kCaption12SB.copyWith(
                                    color: kText2Color,
                                    height: 1.2,
                                  ),
                                ),
                              ),
                              Text(':', style: kCaption12R.copyWith(height: 1.4)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  spec.$2,
                                  style: kCaption12R.copyWith(
                                    color: kTextColor,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(kScreenPaddingH, 8, kScreenPaddingH, 16),
              child: Row(
                children: [
                  Expanded(
                    child: primaryButton(
                      label: _isSaved ? 'Saved' : 'Save Product',
                      onPressed: () {
                        HapticHelper.impact(HapticImpact.light);
                        setState(() {
                          _isSaved = MarketSavedProducts.toggle(product.id);
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              _isSaved
                                  ? 'Product saved'
                                  : 'Removed from saved products',
                            ),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      buttonHeight: 56,
                      buttonColor: kWhite,
                      labelColor: kPrimaryColor,
                      sideColor: kPrimaryColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: primaryButton(
                      label: 'Enquire',
                      onPressed: () {
                        HapticHelper.impact(HapticImpact.medium);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Enquiry submitted'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      buttonHeight: 56,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
