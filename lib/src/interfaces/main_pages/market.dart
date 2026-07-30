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

class MarketPage extends ConsumerStatefulWidget {
  const MarketPage({super.key});

  @override
  ConsumerState<MarketPage> createState() => _MarketPageState();
}

class _MarketPageState extends ConsumerState<MarketPage> {
  late final TextEditingController _searchController;
  String _searchQuery = '';
  final Map<String, bool> _bookmarkOverrides = {};
  String? _bookmarkLoadingId;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text.trim().toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<ProductModel> _filter(List<ProductModel> items) {
    if (_searchQuery.isEmpty) return items;
    return items.where((product) {
      return product.name.toLowerCase().contains(_searchQuery) ||
          product.description.toLowerCase().contains(_searchQuery);
    }).toList();
  }

  bool _isSaved(ProductModel product) {
    return _bookmarkOverrides[product.id] ?? product.isSaved;
  }

  void _clearBookmarkOverrides() {
    if (_bookmarkOverrides.isEmpty) return;
    setState(() => _bookmarkOverrides.clear());
  }

  void _refreshProductsAfterNavigation() {
    if (!mounted) return;
    _clearBookmarkOverrides();
    ref.invalidate(productsListProvider);
    ref.invalidate(savedProductsProvider);
  }

  Future<void> _toggleBookmark(ProductModel product) async {
    if (_bookmarkLoadingId != null) return;
    final currentlySaved = _isSaved(product);
    setState(() {
      _bookmarkLoadingId = product.id;
      _bookmarkOverrides[product.id] = !currentlySaved;
    });
    try {
      final res = await ref
          .read(productApiProvider)
          .toggleSaveProduct(product.id);
      if (!mounted) return;
      if (!res.success) {
        setState(() => _bookmarkOverrides[product.id] = currentlySaved);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res.message ?? 'Failed to update saved')),
        );
        return;
      }
      setState(() {
        _bookmarkOverrides[product.id] = res.data ?? !currentlySaved;
      });
      ref.invalidate(savedProductsProvider);
      ref.invalidate(productDetailProvider(product.id));
      ref.invalidate(productsListProvider);
    } finally {
      if (mounted) setState(() => _bookmarkLoadingId = null);
    }
  }

  void _openDetails(String productId) {
    NavigationService()
        .pushNamed(
          'MarketProductDetail',
          arguments: {'productId': productId},
        )
        .then((_) => _refreshProductsAfterNavigation());
  }

  void _openMenuRoute(String routeName) {
    NavigationService()
        .pushNamed(routeName)
        .then((_) => _refreshProductsAfterNavigation());
  }

  Widget _buildSearchField() {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(kCardRadiusLg),
        border: Border.all(color: kCardBorder),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          const Icon(Icons.search, color: kSecondaryTextColor, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _searchController,
              style: kBodyTitleR.copyWith(color: kTextColor),
              cursorColor: kPrimaryColor,
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                hintText: 'Search for product & services',
                hintStyle: kBodyTitleR.copyWith(color: kSecondaryTextColor),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          },
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: kWhite,
              border: Border.all(color: kStrokeColor, width: 1.25),
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
            'Jamiat Market Place',
            style: kSectionTitleSB,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        PopupMenuButton<String>(
          padding: EdgeInsets.zero,
          offset: const Offset(0, 44),
          color: kWhite,
          elevation: 8,
          shadowColor: kBlack.withValues(alpha: 0.18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          icon: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: kWhite,
              border: Border.all(color: kStrokeColor, width: 1.25),
            ),
            child: const Icon(
              Icons.more_vert,
              color: kTextColor,
              size: 20,
            ),
          ),
          onSelected: (value) {
            HapticHelper.impact(HapticImpact.light);
            if (value == 'enquiries') {
              _openMenuRoute('MyEnquiries');
            } else {
              _openMenuRoute('SavedProducts');
            }
          },
          itemBuilder: (_) => [
            PopupMenuItem<String>(
              value: 'enquiries',
              height: 48,
              child: Text(
                'My Enquiries',
                style: kStyle(
                  kMedium,
                  15,
                  color: const Color(0xFF888888),
                ),
              ),
            ),
            PopupMenuItem<String>(
              enabled: false,
              height: 1,
              padding: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Divider(
                  height: 1,
                  thickness: 1,
                  color: kBorder.withValues(alpha: 0.9),
                ),
              ),
            ),
            PopupMenuItem<String>(
              value: 'saved',
              height: 48,
              child: Text(
                'Saved',
                style: kStyle(
                  kMedium,
                  15,
                  color: const Color(0xFF888888),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProductGrid(List<ProductModel> products) {
    if (products.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        children: [
          const SizedBox(height: 60),
          Center(child: Text('No products found', style: kEmptyStateM)),
        ],
      );
    }

    return GridView.builder(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      padding: const EdgeInsets.only(bottom: 24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: kMarketCardAspectRatio,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return MarketProductCard(
          product: product,
          showBookmark: true,
          isBookmarked: _isSaved(product),
          onBookmark: () => _toggleBookmark(product),
          onViewDetails: () => _openDetails(product.id),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(productsListProvider, (previous, next) {
      if (_bookmarkLoadingId != null) return;
      next.whenData((_) {
        if (mounted) _clearBookmarkOverrides();
      });
    });

    final productsAsync = ref.watch(productsListProvider);

    return Scaffold(
      backgroundColor: kWhite,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            kScreenPaddingH,
            8,
            kScreenPaddingH,
            0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              _buildSearchField(),
              const SizedBox(height: 32),
              Expanded(
                child: RefreshIndicator(
                  color: kPrimaryColor,
                  onRefresh: () async {
                    ref.invalidate(productsListProvider);
                    await ref.read(productsListProvider.future);
                  },
                  child: AsyncContent(
                    asyncValue: productsAsync,
                    onRetry: () => ref.invalidate(productsListProvider),
                    builder: (page) =>
                        _buildProductGrid(_filter(page.items)),
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
