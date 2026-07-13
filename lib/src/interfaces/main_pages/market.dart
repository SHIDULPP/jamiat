import 'package:flutter/material.dart';
import 'package:jamiat/src/data/constants/color_constants.dart';
import 'package:jamiat/src/data/constants/style_constants.dart';
import 'package:jamiat/src/data/services/haptic_helper.dart';

class _ProductItem {
  final String title;
  final String price;
  final String imagePath;
  final String category;

  const _ProductItem({
    required this.title,
    required this.price,
    required this.imagePath,
    required this.category,
  });
}

class MarketPage extends StatefulWidget {
  const MarketPage({super.key});

  @override
  State<MarketPage> createState() => _MarketPageState();
}

class _MarketPageState extends State<MarketPage> {
  late TextEditingController _searchController;
  String _selectedCategory = 'All';

  final List<_ProductItem> _products = const [
    _ProductItem(
      title: 'Tasbih - handcrafted sandalwoods',
      price: '₹ 380',
      imagePath: 'assets/pngs/product_tasbih.png',
      category: 'Clothing',
    ),
    _ProductItem(
      title: 'Fiqh essentials - scholar edition',
      price: '₹ 450',
      imagePath: 'assets/pngs/product_fiqh.png',
      category: 'Books',
    ),
    _ProductItem(
      title: 'Pure Cambodian Oud Oil',
      price: '₹ 200',
      imagePath: 'assets/pngs/product_oud.png',
      category: 'Clothing',
    ),
    _ProductItem(
      title: 'Orthopedic Memory Foam Prayer Mat',
      price: '₹ 500',
      imagePath: 'assets/pngs/product_prayermat.png',
      category: 'Clothing',
    ),
  ];

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

  List<_ProductItem> _getFilteredProducts() {
    final query = _searchController.text.toLowerCase().trim();

    return _products.where((product) {
      final matchesCategory =
          _selectedCategory == 'All' || product.category == _selectedCategory;
      final matchesSearch =
          query.isEmpty || product.title.toLowerCase().contains(query);
      return matchesCategory && matchesSearch;
    }).toList();
  }

  Widget _buildCategoryList() {
    final categories = ['All', 'Books', 'Clothing', 'Services', 'Medical'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: categories.map((category) {
          final isSelected = _selectedCategory == category;
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: GestureDetector(
              onTap: () {
                HapticHelper.impact(HapticImpact.light);
                setState(() {
                  _selectedCategory = category;
                });
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
        onChanged: (val) {
          setState(() {});
        },
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

  Widget _buildProductGrid(List<_ProductItem> filteredProducts) {
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
        childAspectRatio: 0.72,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
      ),
      itemCount: filteredProducts.length,
      itemBuilder: (context, index) {
        final product = filteredProducts[index];
        return Container(
          decoration: BoxDecoration(
            color: kScreenBg,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  child: Image.asset(
                    product.imagePath,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              // Details container
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: kBodyTitleM.copyWith(
                        color: kTextColor,
                        fontSize: 14,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      product.price,
                      style: kBodyTitleB.copyWith(
                        color: kTextColor,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 10),
                    // View Details Button
                    GestureDetector(
                      onTap: () {
                        HapticHelper.impact(HapticImpact.light);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Details for ${product.title}'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: kPrimaryColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            'View Details',
                            style: kButtonLabelSB.copyWith(
                              color: kWhite,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredProducts = _getFilteredProducts();

    return Scaffold(
      backgroundColor: kWhite,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Bar
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
                  // Shopping cart badge
                  GestureDetector(
                    onTap: () {
                      HapticHelper.impact(HapticImpact.light);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Cart clicked'),
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
                        Icons.shopping_cart_outlined,
                        color: kTextColor,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Search Bar
              _buildSearchField(),
              const SizedBox(height: 18),

              // Filter Chips
              _buildCategoryList(),
              const SizedBox(height: 24),

              // Product Grid
              _buildProductGrid(filteredProducts),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
