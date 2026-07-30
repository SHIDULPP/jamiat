import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jamiat/src/data/apis/product_api.dart';
import 'package:jamiat/src/data/constants/color_constants.dart';
import 'package:jamiat/src/data/constants/style_constants.dart';
import 'package:jamiat/src/data/models/product_model.dart';
import 'package:jamiat/src/data/providers/product_provider.dart';
import 'package:jamiat/src/data/services/haptic_helper.dart';
import 'package:jamiat/src/interfaces/components/async_content.dart';
import 'package:jamiat/src/interfaces/components/primarybutton.dart';
import 'package:jamiat/src/interfaces/market/market_product_card.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  const ProductDetailScreen({super.key, required this.productId});

  final String productId;

  @override
  ConsumerState<ProductDetailScreen> createState() =>
      _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  bool? _isSavedOverride;
  bool _saveLoading = false;
  bool _enquireLoading = false;

  bool _isSaved(ProductModel product) {
    return _isSavedOverride ?? product.isSaved;
  }

  Future<void> _toggleSave(ProductModel product) async {
    if (_saveLoading) return;
    setState(() => _saveLoading = true);
    try {
      final res =
          await ref.read(productApiProvider).toggleSaveProduct(product.id);
      if (!mounted) return;
      if (!res.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(res.message ?? 'Failed to update saved'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }
      final saved = res.data ?? !_isSaved(product);
      setState(() => _isSavedOverride = saved);
      ref.invalidate(productsListProvider);
      ref.invalidate(savedProductsProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            saved ? 'Product saved' : 'Removed from saved products',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _saveLoading = false);
    }
  }

  Future<void> _enquire(ProductModel product) async {
    if (_enquireLoading) return;
    setState(() => _enquireLoading = true);
    try {
      final res = await ref.read(productApiProvider).createEnquiry(product.id);
      if (!mounted) return;
      if (!res.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(res.message ?? 'Failed to submit enquiry'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }
      ref.invalidate(myProductEnquiriesProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res.message ?? 'Enquiry submitted'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _enquireLoading = false);
    }
  }

  Widget _heroImage(String? imageUrl) {
    return AspectRatio(
      aspectRatio: 370 / 203,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(kCardRadiusMd),
        child: productCoverImage(imageUrl),
      ),
    );
  }

  Widget _sellerAvatar(ProductSeller? seller) {
    final image = seller?.image;
    if (image != null && image.startsWith('http')) {
      return CircleAvatar(
        radius: 20,
        backgroundColor: kScreenBg,
        backgroundImage: NetworkImage(image),
      );
    }
    return CircleAvatar(
      radius: 20,
      backgroundColor: kScreenBg,
      backgroundImage: const AssetImage('assets/pngs/dummy_avatar.png'),
    );
  }

  @override
  Widget build(BuildContext context) {
    final productAsync = ref.watch(productDetailProvider(widget.productId));

    return Scaffold(
      backgroundColor: kWhite,
      body: SafeArea(
        child: AsyncContent(
          asyncValue: productAsync,
          onRetry: () =>
              ref.invalidate(productDetailProvider(widget.productId)),
          builder: (product) {
            final sellerName =
                (product.seller?.name.isNotEmpty == true)
                    ? product.seller!.name
                    : 'Jamiat Welfare Committee';
            final isSaved = _isSaved(product);

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    kScreenPaddingH,
                    8,
                    kScreenPaddingH,
                    0,
                  ),
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: kScreenPaddingH,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _heroImage(product.image),
                        const SizedBox(height: 16),
                        Text(
                          product.name,
                          style: kSubHeadingR.copyWith(
                            color: kTextColor,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            _sellerAvatar(product.seller),
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
                                    sellerName,
                                    style: kCaption12R.copyWith(
                                      color: kTextColor,
                                      height: 1.2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              product.formattedPrice,
                              style: kSubHeadingSB,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text('About Product', style: kBodyTitleSB),
                        const SizedBox(height: 8),
                        Text(
                          product.description.isEmpty
                              ? 'No description available.'
                              : product.description,
                          style: kCaption12R.copyWith(
                            color: kTextColor,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    kScreenPaddingH,
                    8,
                    kScreenPaddingH,
                    16,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: primaryButton(
                          label: isSaved ? 'Saved' : 'Save Product',
                          onPressed: _saveLoading
                              ? null
                              : () {
                                  HapticHelper.impact(HapticImpact.light);
                                  _toggleSave(product);
                                },
                          isLoading: _saveLoading,
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
                          onPressed: _enquireLoading
                              ? null
                              : () {
                                  HapticHelper.impact(HapticImpact.medium);
                                  _enquire(product);
                                },
                          isLoading: _enquireLoading,
                          buttonHeight: 56,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
