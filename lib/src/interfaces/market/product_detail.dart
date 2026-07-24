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
      aspectRatio: 16 / 9,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.asset(
          imagePath,
          fit: BoxFit.cover,
          width: double.infinity,
        ),
      ),
    );
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
                  Expanded(
                    child: Text(
                      'Product Details',
                      style: kHeadTitleB.copyWith(
                        color: kTextColor,
                        fontSize: 20,
                      ),
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
                        color: kWhite,
                        border: Border.all(color: kBorder, width: 1.25),
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
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _heroImage(product.imagePath),
                    const SizedBox(height: 20),
                    Text(
                      product.title,
                      style: kHeadTitleB.copyWith(
                        color: kTextColor,
                        fontSize: 18,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 18,
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
                                style: kCaption10M.copyWith(
                                  color: kMutedText,
                                  letterSpacing: 0.4,
                                ),
                              ),
                              Text(
                                product.sellerName,
                                style: kBodyTitleM.copyWith(
                                  color: kTextColor,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          product.formattedPrice,
                          style: kHeadTitleB.copyWith(
                            color: kTextColor,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'About Product',
                      style: kSectionTitleSB.copyWith(fontSize: 16),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      product.description,
                      style: kBodyTitleR.copyWith(
                        color: kTextColor,
                        fontSize: 14,
                        height: 1.55,
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
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
                      buttonHeight: 52,
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
                      buttonHeight: 52,
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
