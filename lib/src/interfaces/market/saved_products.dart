import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jamiat/src/data/apis/product_api.dart';
import 'package:jamiat/src/data/constants/color_constants.dart';
import 'package:jamiat/src/data/constants/style_constants.dart';
import 'package:jamiat/src/data/models/product_model.dart';
import 'package:jamiat/src/data/providers/product_provider.dart';
import 'package:jamiat/src/data/services/haptic_helper.dart';
import 'package:jamiat/src/data/services/navigation_services.dart';
import 'package:jamiat/src/interfaces/components/async_content.dart';
import 'package:jamiat/src/interfaces/market/market_product_card.dart';
import 'package:jamiat/src/interfaces/market/market_product_data.dart';

class SavedProductsScreen extends ConsumerStatefulWidget {
  const SavedProductsScreen({super.key});

  @override
  ConsumerState<SavedProductsScreen> createState() =>
      _SavedProductsScreenState();
}

class _SavedProductsScreenState extends ConsumerState<SavedProductsScreen> {
  String? _bookmarkLoadingId;

  void _openDetails(String productId) {
    NavigationService()
        .pushNamed(
          'MarketProductDetail',
          arguments: {'productId': productId},
        )
        .then((_) {
          if (mounted) {
            ref.invalidate(savedProductsProvider);
            ref.invalidate(productsListProvider);
          }
        });
  }

  Future<void> _unsave(ProductModel product) async {
    if (_bookmarkLoadingId != null) return;
    setState(() => _bookmarkLoadingId = product.id);
    try {
      final res =
          await ref.read(productApiProvider).toggleSaveProduct(product.id);
      if (!mounted) return;
      if (!res.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res.message ?? 'Failed to update saved')),
        );
        return;
      }
      ref.invalidate(savedProductsProvider);
      ref.invalidate(productsListProvider);
      ref.invalidate(productDetailProvider(product.id));
    } finally {
      if (mounted) setState(() => _bookmarkLoadingId = null);
    }
  }

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

  @override
  Widget build(BuildContext context) {
    final savedAsync = ref.watch(savedProductsProvider);

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
                  const SizedBox(width: 8),
                  Text('Saved', style: kSectionTitleSB),
                ],
              ),
            ),
            Expanded(
              child: AsyncContent(
                asyncValue: savedAsync,
                onRetry: () => ref.invalidate(savedProductsProvider),
                builder: (page) {
                  final products = page.items;
                  if (products.isEmpty) {
                    return Center(
                      child: Text(
                        'No saved products yet',
                        style: kEmptyStateM,
                      ),
                    );
                  }
                  return RefreshIndicator(
                    color: kPrimaryColor,
                    onRefresh: () async {
                      ref.invalidate(savedProductsProvider);
                      await ref.read(savedProductsProvider.future);
                    },
                    child: GridView.builder(
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics(),
                      ),
                      padding: const EdgeInsets.fromLTRB(
                        kScreenPaddingH,
                        0,
                        kScreenPaddingH,
                        16,
                      ),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: kMarketCardAspectRatio,
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 14,
                      ),
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        final product = products[index];
                        return MarketProductCard(
                          product: product,
                          showBookmark: true,
                          isBookmarked: true,
                          onBookmark: () => _unsave(product),
                          onViewDetails: () => _openDetails(product.id),
                        );
                      },
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
