import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:jamiat/src/data/constants/color_constants.dart';
import 'package:jamiat/src/data/constants/style_constants.dart';
import 'package:jamiat/src/data/services/haptic_helper.dart';
import 'package:jamiat/src/data/services/navigation_services.dart';
import 'package:jamiat/src/interfaces/market/market_product_card.dart';
import 'package:jamiat/src/interfaces/market/market_product_data.dart';

class MarketPage extends StatefulWidget {
  const MarketPage({super.key});

  @override
  State<MarketPage> createState() => _MarketPageState();
}

class _MarketPageState extends State<MarketPage> {
  late final TextEditingController _searchController;
  String _selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<MarketProduct> _filteredProducts() {
    final query = _searchController.text.toLowerCase().trim();

    return marketProducts.where((product) {
      final matchesCategory =
          _selectedCategory == 'All' || product.category == _selectedCategory;
      final matchesSearch =
          query.isEmpty || product.title.toLowerCase().contains(query);
      return matchesCategory && matchesSearch;
    }).toList();
  }

  void _openDetails(String productId) {
    NavigationService().pushNamed(
      'MarketProductDetail',
      arguments: {'productId': productId},
    ).then((_) {
      if (mounted) setState(() {});
    });
  }

  void _toggleBookmark(String productId) {
    MarketSavedProducts.toggle(productId);
    setState(() {});
  }

  Widget _buildCategoryList() {
    // Figma chips: 30h · r6 · selected #FBBD05 · unselected soft yellow + border · 12 Medium
    return SizedBox(
      height: 30,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: marketCategories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final category = marketCategories[index];
          final isSelected = _selectedCategory == category;
          return GestureDetector(
            onTap: () {
              HapticHelper.impact(HapticImpact.light);
              setState(() => _selectedCategory = category);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isSelected
                    ? kSecondaryColor
                    : kSecondaryColor.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(kCardRadiusXs),
                border: Border.all(color: kSecondaryColor),
              ),
              alignment: Alignment.center,
              child: Text(
                category,
                style: kCaption12M.copyWith(
                  color: isSelected ? kTextColor : kMutedText,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchField() {
    // Figma Input Field 1: 56h · r16 · border #E3E3E3 · no shadow
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
              onChanged: (_) => setState(() {}),
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

  Widget _buildProductGrid(List<MarketProduct> filteredProducts) {
    if (filteredProducts.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 60),
          child: Text('No products found', style: kEmptyStateM),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: kMarketCardAspectRatio,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: filteredProducts.length,
      itemBuilder: (context, index) {
        final product = filteredProducts[index];
        return MarketProductCard(
          product: product,
          showBookmark: true,
          isBookmarked: MarketSavedProducts.isSaved(product.id),
          onBookmark: () => _toggleBookmark(product.id),
          onViewDetails: () => _openDetails(product.id),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredProducts = _filteredProducts();

    return Scaffold(
      backgroundColor: kWhite,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            kScreenPaddingH,
            8,
            kScreenPaddingH,
            24,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
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
                  GestureDetector(
                    onTap: () {
                      HapticHelper.impact(HapticImpact.light);
                      NavigationService().pushNamed('SavedProducts');
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: kWhite,
                        border: Border.all(color: kStrokeColor, width: 1.25),
                      ),
                      child: Center(
                        child: SvgPicture.asset(
                          'assets/svg/market_icon.svg',
                          width: 22,
                          height: 22,
                          colorFilter: const ColorFilter.mode(
                            kTextColor,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildSearchField(),
              const SizedBox(height: 16),
              _buildCategoryList(),
              const SizedBox(height: 32),
              _buildProductGrid(filteredProducts),
            ],
          ),
        ),
      ),
    );
  }
}
