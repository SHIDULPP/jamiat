/// Figma listing card proportions (width : height).
const double kMarketCardWidth = 177;
const double kMarketCardHeight = 266;
const double kMarketImageHeight = 140;

const double kMarketCardAspectRatio = kMarketCardWidth / kMarketCardHeight;
const double kMarketImageAspectRatio = kMarketCardWidth / kMarketImageHeight;

class MarketProduct {
  const MarketProduct({
    required this.id,
    required this.title,
    required this.price,
    required this.imagePath,
    required this.category,
    required this.sellerName,
    required this.description,
    this.sellerLogoPath = 'assets/pngs/dummy_avatar.png',
  });

  final String id;
  final String title;
  final int price;
  final String imagePath;
  final String category;
  final String sellerName;
  final String description;
  final String sellerLogoPath;

  String get formattedPrice => '₹ $price';
}

const marketCategories = ['All', 'Books', 'Clothing', 'Services', 'Medical'];

const marketProducts = <MarketProduct>[
  MarketProduct(
    id: 'tasbih',
    title: 'Tasbih - handcrafted sandalwoods',
    price: 380,
    imagePath: 'assets/pngs/product_tasbih.png',
    category: 'Clothing',
    sellerName: 'Jamait Welfare Committee',
    description:
        'Handcrafted sandalwood tasbih beads, polished for daily dhikr. '
        'Each strand is inspected for smooth threading and consistent bead size.',
  ),
  MarketProduct(
    id: 'fiqh',
    title: 'Fiqh essentials - scholar edition',
    price: 450,
    imagePath: 'assets/pngs/product_fiqh.png',
    category: 'Books',
    sellerName: 'Jamait Welfare Committee',
    description:
        'A concise fiqh reference for students and families, covering '
        'everyday rulings with clear explanations and chapter summaries.',
  ),
  MarketProduct(
    id: 'oud',
    title: 'Pure Cambodian Oud Oil',
    price: 200,
    imagePath: 'assets/pngs/product_oud.png',
    category: 'Clothing',
    sellerName: 'Jamait Welfare Committee',
    description:
        'Premium Cambodian oud oil with a warm, long-lasting aroma. '
        'Suitable for personal use and gifting.',
  ),
  MarketProduct(
    id: 'prayer_mat',
    title: 'Orthopedic Memory Foam Prayer Mat',
    price: 500,
    imagePath: 'assets/pngs/product_prayermat.png',
    category: 'Clothing',
    sellerName: 'Jamait Welfare Committee',
    description:
        'Experience unparalleled comfort during your daily prayers with our '
        'Orthopedic Memory Foam Prayer Mat. Designed with high-density memory '
        'foam, it provides superior cushioning to relieve joint pressure on '
        'knees and ankles. The mat is wrapped in a soft, breathable '
        'micro-velvet fabric and features a non-slip backing to ensure '
        'stability on any floor surface.',
  ),
];

MarketProduct? marketProductById(String id) {
  for (final product in marketProducts) {
    if (product.id == id) return product;
  }
  return null;
}

/// Local saved-state until marketplace APIs are wired.
class MarketSavedProducts {
  MarketSavedProducts._();

  static final Set<String> _ids = {'tasbih', 'fiqh'};

  static Set<String> get ids => Set.unmodifiable(_ids);

  static bool isSaved(String id) => _ids.contains(id);

  static bool toggle(String id) {
    if (_ids.contains(id)) {
      _ids.remove(id);
      return false;
    }
    _ids.add(id);
    return true;
  }

  static List<MarketProduct> savedProducts() {
    return marketProducts.where((p) => _ids.contains(p.id)).toList();
  }
}
