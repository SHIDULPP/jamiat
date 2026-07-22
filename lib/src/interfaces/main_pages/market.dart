import 'package:flutter/material.dart';
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
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: marketCategories.map((category) {
          final isSelected = _selectedCategory == category;
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: GestureDetector(
              onTap: () {
                HapticHelper.impact(HapticImpact.light);
                setState(() => _selectedCategory = category);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? kSecondaryColor : kWhite,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected ? kSecondaryColor : kBorder,
                    width: 1,
                  ),
                ),
                child: Text(
                  category,
                  style: kBodyTitleM.copyWith(
                    color: isSelected ? kTextColor : kSecondaryTextColor,
                    fontWeight: isSelected ? kBold : kRegular,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSearchField() {
    return Container(
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        style: kBodyTitleR.copyWith(color: kTextColor),
        onChanged: (_) => setState(() {}),
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.search, color: kSecondaryTextColor),
          hintText: 'Search for product & services',
          hintStyle: kBodyTitleR.copyWith(color: kSecondaryTextColor),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 18,
            horizontal: 16,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: kBorder, width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: kBorder, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: kPrimaryColor, width: 1.5),
          ),
        ),
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
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
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
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                      Text(
                        'Jamiat Market Place',
                        style: kHeadTitleB.copyWith(
                          color: kTextColor,
                          fontSize: 20,
                        ),
                      ),
                    ],
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
                        border: Border.all(color: kBorder, width: 1.25),
                      ),
                      child: const Icon(
                        Icons.shopping_cart_outlined,
                        color: kTextColor,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildSearchField(),
              const SizedBox(height: 18),
              _buildCategoryList(),
              const SizedBox(height: 24),
              _buildProductGrid(filteredProducts),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
