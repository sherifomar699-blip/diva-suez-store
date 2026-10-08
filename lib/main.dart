import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

// ==========================================
// 1. Models (نماذج البيانات)
// ==========================================
enum PricingType {
  standard, // أسعار قياسية: 70 / 200 / 300
  special,  // أسعار خاصة: 80 / 250 / 350
  tobacco,  // أسعار توباكو: 90 / 300 / 400
}

class Perfume {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final String category;
  final double rating;
  final PricingType pricingType;
  final bool isBestSeller;
  final bool isSpecialOffer;

  Perfume({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.category,
    this.rating = 4.9,
    this.pricingType = PricingType.standard,
    this.isBestSeller = false,
    this.isSpecialOffer = false,
  });

  double getPriceForSize(String size) {
    switch (pricingType) {
      case PricingType.tobacco:
        switch (size) {
          case '10ml':
            return 90.0;
          case '30ml':
            return 300.0;
          case '50ml':
            return 400.0;
          default:
            return 300.0;
        }
      case PricingType.special:
        switch (size) {
          case '10ml':
            return 80.0;
          case '30ml':
            return 250.0;
          case '50ml':
            return 350.0;
          default:
            return 250.0;
        }
      case PricingType.standard:
      default:
        switch (size) {
          case '10ml':
            return 70.0;
          case '30ml':
            return 200.0;
          case '50ml':
            return 300.0;
          default:
            return 200.0;
        }
    }
  }
}

class CartItem {
  final Perfume perfume;
  final String selectedSize;
  int quantity;

  CartItem({
    required this.perfume,
    required this.selectedSize,
    this.quantity = 1,
  });

  double get unitPrice => perfume.getPriceForSize(selectedSize);
  double get totalPrice => unitPrice * quantity;
}

class CustomerInfo {
  String fullName = '';
  String phoneNumber = '';
  String governorate = 'السويس';
  String addressDetails = '';
  String notes = '';
}

// ==========================================
// 2. State Management (إدارة السلة)
// ==========================================
class CartProvider extends ChangeNotifier {
  final Map<String, CartItem> _items = {};

  Map<String, CartItem> get items => {..._items};

  int get itemCount => _items.length;

  double get totalAmount {
    var total = 0.0;
    _items.forEach((key, cartItem) {
      total += cartItem.totalPrice;
    });
    return total;
  }

  void addItem(Perfume perfume, String size) {
    final cartKey = '${perfume.id}_$size';
    if (_items.containsKey(cartKey)) {
      _items.update(
        cartKey,
        (existing) => CartItem(
          perfume: existing.perfume,
          selectedSize: existing.selectedSize,
          quantity: existing.quantity + 1,
        ),
      );
    } else {
      _items.putIfAbsent(
        cartKey,
        () => CartItem(perfume: perfume, selectedSize: size),
      );
    }
    notifyListeners();
  }

  void updateQuantity(String cartKey, int delta) {
    if (!_items.containsKey(cartKey)) return;
    if (_items[cartKey]!.quantity + delta > 0) {
      _items[cartKey]!.quantity += delta;
    } else {
      _items.remove(cartKey);
    }
    notifyListeners();
  }

  void removeItem(String cartKey) {
    _items.remove(cartKey);
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}

// ==========================================
// 3. Main Application
// ==========================================
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) => CartProvider(),
      child: MaterialApp(
        title: 'Diva Suez Store',
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark().copyWith(
          scaffoldBackgroundColor: const Color(0xFF0D0D12),
          primaryColor: const Color(0xFFD4AF37),
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFFD4AF37),
            secondary: Color(0xFF1E1E2A),
          ),
          textTheme: GoogleFonts.cairoTextTheme(ThemeData.dark().textTheme),
        ),
        home: const HomeScreen(),
      ),
    );
  }
}

// ==========================================
// 4. Home Screen
// ==========================================
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String selectedCategory = 'الكل';
  String searchQuery = '';

  final List<String> categories = ['الكل', 'نسائي', 'رجالي', 'شرقي', 'جنسين'];

  final List<Perfume> perfumes = [
    // --- نسائي ---
    Perfume(id: '1', name: 'Pink Sugar', description: 'عطر حلو وجذاب بنفحات الغزل والقطع السكرية.', imageUrl: 'https://images.unsplash.com/photo-1541643600914-78b084683601?q=80&w=400', category: 'نسائي', isBestSeller: true),
    Perfume(id: '2', name: 'يارا كاندي', description: 'عطر أنثوي رائع مليء بالحيوية والانتعاش.', imageUrl: 'https://images.unsplash.com/photo-1592945403244-b3fbafd7f539?q=80&w=400', category: 'نسائي'),
    Perfume(id: '3', name: 'يارا الكسير', description: 'نسخة أكثر تركيزاً وفخامة مع لمسات دافئة.', imageUrl: 'https://images.unsplash.com/photo-1523293182086-7651a899d37f?q=80&w=400', category: 'نسائي'),
    Perfume(id: '4', name: 'أروجيت بينك', description: 'لمسات أنثوية ناعمة ورائحة ساحرة تدوم طويلاً.', imageUrl: 'https://images.unsplash.com/photo-1588405748880-12d1d2a59f75?q=80&w=400', category: 'نسائي', pricingType: PricingType.special, isSpecialOffer: true),
    Perfume(id: '5', name: 'أميرة العرب', description: 'عطر شرقي نسائي فاخر بلمسات الزهور الملكية.', imageUrl: 'https://images.unsplash.com/photo-1547887537-6158d64c35b3?q=80&w=400', category: 'نسائي'),
    Perfume(id: '6', name: 'كاتي بيري (Katy Perry)', description: 'نفحات فاكهية وفانيليا أنيقة للفتيات.', imageUrl: 'https://images.unsplash.com/photo-1512777576244-b846ac3d816f?q=80&w=400', category: 'نسائي'),
    Perfume(id: '7', name: 'Donn', description: 'عطر رقيق يضفي لمسة من الأناقة اليومية.', imageUrl: 'https://images.unsplash.com/photo-1541643600914-78b084683601?q=80&w=400', category: 'نسائي'),
    Perfume(id: '8', name: 'بربري هير (Burberry Her)', description: 'مزيج فاخر من التوت والزهور مع قاعدة خشبية.', imageUrl: 'https://images.unsplash.com/photo-1592945403244-b3fbafd7f539?q=80&w=400', category: 'نسائي'),
    Perfume(id: '9', name: 'Good Girl', description: 'العطر الأيقوني بنفحات الكاكاو والياسمين الجذابة.', imageUrl: 'https://images.unsplash.com/photo-1588405748880-12d1d2a59f75?q=80&w=400', category: 'نسائي', isBestSeller: true),
    Perfume(id: '10', name: 'روز فانيليا', description: 'تناغم ساحر بين الورد التركي والفانيليا الناعمة.', imageUrl: 'https://images.unsplash.com/photo-1523293182086-7651a899d37f?q=80&w=400', category: 'نسائي'),
    Perfume(id: '11', name: 'فانيليا بودر', description: 'رائحة البودرة الناعمة والفانيليا الدافئة.', imageUrl: 'https://images.unsplash.com/photo-1547887537-6158d64c35b3?q=80&w=400', category: 'نسائي'),
    Perfume(id: '12', name: 'Morgan', description: 'عطر عصري أنيق يعكس الشخصية القوية والأنثوية.', imageUrl: 'https://images.unsplash.com/photo-1512777576244-b846ac3d816f?q=80&w=400', category: 'نسائي', pricingType: PricingType.special),

    // --- شرقي ---
    Perfume(id: '24', name: 'عود أبيض', description: 'عود خفيف ونقي ومناسب لجميع الأوقات.', imageUrl: 'https://images.unsplash.com/photo-1512777576244-b846ac3d816f?q=80&w=400', category: 'شرقي', pricingType: PricingType.special),
    Perfume(id: '27', name: 'مضاوي', description: 'العطر الشرقي الشهير بنفحات التشكيل العربي الساحر.', imageUrl: 'https://images.unsplash.com/photo-1588405748880-12d1d2a59f75?q=80&w=400', category: 'شرقي', pricingType: PricingType.special, isBestSeller: true),
    Perfume(id: '30', name: 'خمرة جولد', description: 'نفحات التوابل الدافئة والعنبر مع العسل.', imageUrl: 'https://images.unsplash.com/photo-1512777576244-b846ac3d816f?q=80&w=400', category: 'شرقي', pricingType: PricingType.special),

    // --- رجالي ---
    Perfume(id: '32', name: 'سوفاج (Sauvage)', description: 'العطر الرجالي الأكثر شهرة بنفحات البرغموت والعنبر.', imageUrl: 'https://images.unsplash.com/photo-1594035910387-fea47794261f?q=80&w=400', category: 'رجالي', pricingType: PricingType.special, isBestSeller: true),
    Perfume(id: '33', name: 'كريد أفينتوس (Creed Aventus)', description: 'رمز الفخامة الرجالية بالأناناس والأخشاب.', imageUrl: 'https://images.unsplash.com/photo-1595425970377-c9703cf48b6d?q=80&w=400', category: 'رجالي'),
    Perfume(id: '40', name: 'Stronger With You', description: 'دفء الهيل والملاذ العطري الجذاب.', imageUrl: 'https://images.unsplash.com/photo-1594035910387-fea47794261f?q=80&w=400', category: 'رجالي'),

    // --- جنسين (Unisex) ---
    Perfume(id: '49', name: 'توباكو فانيليا', description: 'دفء التبغ الفاخر مع حلاوة الفانيليا الغنية.', imageUrl: 'https://images.unsplash.com/photo-1523293182086-7651a899d37f?q=80&w=400', category: 'جنسين', pricingType: PricingType.tobacco, isBestSeller: true),
    Perfume(id: '50', name: 'توباكو فينج', description: 'تركيبة التبغ العصرية القوية للذوق الرفيع.', imageUrl: 'https://images.unsplash.com/photo-1588405748880-12d1d2a59f75?q=80&w=400', category: 'جنسين', pricingType: PricingType.tobacco),
    Perfume(id: '51', name: 'بيانكو لاتيه (Bianco Latte)', description: 'رائحة الحليب الدافئ والكراميل والمُسك الساحر.', imageUrl: 'https://images.unsplash.com/photo-1547887537-6158d64c35b3?q=80&w=400', category: 'جنسين'),
    Perfume(id: '57', name: 'بكرات روج (Baccarat Rouge 540)', description: 'العبير الأسطوري من العنبر والياسمين والخشب.', imageUrl: 'https://images.unsplash.com/photo-1547887537-6158d64c35b3?q=80&w=400', category: 'جنسين', pricingType: PricingType.special),
  ];

  @override
  Widget build(BuildContext context) {
    final filteredPerfumes = perfumes.where((p) {
      final matchesCategory = selectedCategory == 'الكل' || p.category == selectedCategory;
      final matchesSearch = p.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
          p.description.toLowerCase().contains(searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF14141E),
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFD4AF37), width: 1.5),
              ),
              child: const Icon(Icons.workspace_premium, color: Color(0xFFD4AF37), size: 18),
            ),
            const SizedBox(width: 8),
            const Text(
              'DIVA SUEZ',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                letterSpacing: 2.5,
                color: Color(0xFFD4AF37),
                fontSize: 18,
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          Consumer<CartProvider>(
            builder: (_, cart, ch) => Badge(
              label: Text('${cart.itemCount}'),
              isLabelVisible: cart.itemCount > 0,
              backgroundColor: const Color(0xFFD4AF37),
              textColor: Colors.black,
              child: ch!,
            ),
            child: IconButton(
              icon: const Icon(Icons.shopping_bag_outlined, color: Colors.white),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (ctx) => const CartScreen()),
                );
              },
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            // Branding Banner / Logo Section
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2A200B), Color(0xFF14141E)],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFD4AF37).withValues(alpha: 0.3)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.4),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD4AF37).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'LUXURY PARFUM',
                            style: TextStyle(color: Color(0xFFD4AF37), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Diva Suez Store 👑',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'أرقى العطور العالمية والشرقية بأعلى ثبات وتركيز (10ml - 30ml - 50ml)',
                          style: TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFD4AF37), width: 2),
                      gradient: const RadialGradient(
                        colors: [Color(0xFFD4AF37), Color(0xFF14141E)],
                      ),
                    ),
                    child: const Center(
                      child: Icon(Icons.auto_awesome, color: Colors.white, size: 32),
                    ),
                  ),
                ],
              ),
            ),

            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                onChanged: (val) => setState(() => searchQuery = val),
                decoration: InputDecoration(
                  hintText: 'ابحث باسم العطر أو المكونات...',
                  hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
                  prefixIcon: const Icon(Icons.search, color: Color(0xFFD4AF37)),
                  filled: true,
                  fillColor: const Color(0xFF1E1E2A),
                  contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            // Categories Filter Bar
            Container(
              height: 48,
              margin: const EdgeInsets.symmetric(vertical: 16),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: categories.length,
                itemBuilder: (ctx, i) {
                  final cat = categories[i];
                  final isSelected = selectedCategory == cat;
                  return GestureDetector(
                    onTap: () => setState(() => selectedCategory = cat),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(left: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFFD4AF37) : const Color(0xFF1E1E2A),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? const Color(0xFFD4AF37) : Colors.transparent,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          cat,
                          style: TextStyle(
                            color: isSelected ? Colors.black : Colors.white70,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Perfume Grid View
            filteredPerfumes.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(50.0),
                    child: Center(child: Text('لا توجد عطور مطابقة للبحث')),
                  )
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filteredPerfumes.length,
                      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 230,
                        childAspectRatio: 0.52,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemBuilder: (ctx, i) => PerfumeCard(perfume: filteredPerfumes[i]),
                    ),
                  ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// 5. Professional Perfume Card
// ==========================================
class PerfumeCard extends StatefulWidget {
  final Perfume perfume;

  const PerfumeCard({super.key, required this.perfume});

  @override
  State<PerfumeCard> createState() => _PerfumeCardState();
}

class _PerfumeCardState extends State<PerfumeCard> {
  String selectedSize = '30ml';

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context, listen: false);
    final currentPrice = widget.perfume.getPriceForSize(selectedSize);

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  child: Image.network(
                    widget.perfume.imageUrl,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (ctx, err, stack) => Container(
                      color: Colors.grey[900],
                      child: const Icon(Icons.science, size: 50, color: Color(0xFFD4AF37)),
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.75),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          '${widget.perfume.rating}',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
                if (widget.perfume.isBestSeller)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD4AF37),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'الأكثر مبيعاً 🔥',
                        style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.perfume.name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  widget.perfume.description,
                  style: const TextStyle(color: Colors.grey, fontSize: 10),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: ['10ml', '30ml', '50ml'].map((size) {
                    final isSelected = selectedSize == size;
                    return InkWell(
                      onTap: () => setState(() => selectedSize = size),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFFD4AF37) : Colors.black26,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected ? const Color(0xFFD4AF37) : Colors.grey.shade800,
                          ),
                        ),
                        child: Text(
                          size == '10ml' ? '10مل' : (size == '30ml' ? '30مل' : '50مل'),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.black : Colors.white,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${currentPrice.toInt()} ج.م',
                      style: const TextStyle(
                        color: Color(0xFFD4AF37),
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        cart.addItem(widget.perfume, selectedSize);
                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('تمت إضافة ${widget.perfume.name} ($selectedSize) للسلة'),
                            duration: const Duration(seconds: 2),
                            backgroundColor: const Color(0xFF2C2208),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD4AF37),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.add_shopping_cart, color: Colors.black, size: 16),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 6. Cart & Shipping Screen
// ==========================================
class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final _formKey = GlobalKey<FormState>();
  final CustomerInfo _customer = CustomerInfo();
  late String selectedPayment;

  final List<String> governorates = [
    'السويس',
    'القاهرة',
    'الجيزة',
    'الإسكندرية',
    'الشرقية',
    'الدقهلية',
    'البحيرة',
    'المنوفية',
    'الغربية',
    'الإسماعيلية',
    'بورسعيد',
    'محافظة أخرى',
  ];

  final List<String> paymentMethods = [
    'فودافون كاش (01143330686)',
    'InstaPay (01111266205)',
    'الدفع عند الاستلام',
  ];

  @override
  void initState() {
    super.initState();
    selectedPayment = paymentMethods.first;
    _customer.governorate = governorates.first;
  }

  void _submitOrder(CartProvider cart) {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: const Color(0xFF1E1E2A),
          title: const Text('تأكيد الطلب - Diva Suez', style: TextStyle(color: Color(0xFFD4AF37))),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('الاسم: ${_customer.fullName}'),
              Text('الهاتف: ${_customer.phoneNumber}'),
              Text('المحافظة: ${_customer.governorate}'),
              Text('العنوان: ${_customer.addressDetails}'),
              const Divider(color: Colors.grey),
              Text('طريقة الدفع: $selectedPayment'),
              const SizedBox(height: 8),
              Text('الإجمالي: ${cart.totalAmount.toStringAsFixed(2)} ج.م',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFD4AF37), fontSize: 16)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('تعديل', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD4AF37),
                foregroundColor: Colors.black,
              ),
              onPressed: () {
                Navigator.of(ctx).pop();
                cart.clearCart();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('شكراً لطلبك من Diva Suez Store! سيتم التواصل معك فوراً.'),
                    backgroundColor: Colors.green,
                  ),
                );
                Navigator.of(context).pop();
              },
              child: const Text('إرسال الطلب'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF14141E),
        title: const Text('سلة المشتريات والشحن'),
      ),
      body: cart.items.isEmpty
          ? const Center(child: Text('سلة المشتريات فارغة حالياً'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Owner Card Info
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E2A),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFD4AF37).withValues(alpha: 0.5)),
                    ),
                    child: const Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Color(0xFFD4AF37),
                          child: Icon(Icons.person, color: Colors.black),
                        ),
                        SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('صاحب المتجر: Mahmoud Mokhtar', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            SizedBox(height: 2),
                            Text('للتواصل المباشر: +201111266205', style: TextStyle(color: Color(0xFFD4AF37), fontSize: 12)),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const Text('المنتجات المختارة', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFD4AF37))),
                  const SizedBox(height: 10),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: cart.items.length,
                    itemBuilder: (ctx, i) {
                      final key = cart.items.keys.toList()[i];
                      final item = cart.items[key]!;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E1E2A),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          title: Text('${item.perfume.name} (${item.selectedSize})', style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('${item.totalPrice.toInt()} ج.م (${item.unitPrice.toInt()} ج.م/العبوة)', style: const TextStyle(color: Color(0xFFD4AF37))),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline, color: Colors.grey),
                                onPressed: () => cart.updateQuantity(key, -1),
                              ),
                              Text('${item.quantity}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              IconButton(
                                icon: const Icon(Icons.add_circle_outline, color: Color(0xFFD4AF37)),
                                onPressed: () => cart.updateQuantity(key, 1),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  const Divider(color: Colors.grey),
                  const SizedBox(height: 10),
                  const Text('بيانات التسليم والشحن', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFD4AF37))),
                  const SizedBox(height: 15),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'الاسم بالكامل',
                            prefixIcon: Icon(Icons.person, color: Color(0xFFD4AF37)),
                            border: OutlineInputBorder(),
                          ),
                          validator: (val) => val == null || val.trim().isEmpty ? 'برجاء كتابة الاسم' : null,
                          onSaved: (val) => _customer.fullName = val!,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(
                            labelText: 'رقم الهاتف',
                            prefixIcon: Icon(Icons.phone, color: Color(0xFFD4AF37)),
                            border: OutlineInputBorder(),
                          ),
                          validator: (val) => (val == null || val.trim().length < 11) ? 'برجاء إدخال رقم هاتف صحيح' : null,
                          onSaved: (val) => _customer.phoneNumber = val!,
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          initialValue: _customer.governorate,
                          decoration: const InputDecoration(
                            labelText: 'المحافظة',
                            prefixIcon: Icon(Icons.location_city, color: Color(0xFFD4AF37)),
                            border: OutlineInputBorder(),
                          ),
                          items: governorates.map((gov) => DropdownMenuItem(value: gov, child: Text(gov))).toList(),
                          onChanged: (val) => setState(() => _customer.governorate = val!),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'العنوان التفصيلي',
                            prefixIcon: Icon(Icons.home, color: Color(0xFFD4AF37)),
                            border: OutlineInputBorder(),
                          ),
                          validator: (val) => val == null || val.trim().isEmpty ? 'برجاء إدخال العنوان' : null,
                          onSaved: (val) => _customer.addressDetails = val!,
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          initialValue: selectedPayment,
                          decoration: const InputDecoration(
                            labelText: 'طريقة الدفع',
                            prefixIcon: Icon(Icons.payment, color: Color(0xFFD4AF37)),
                            border: OutlineInputBorder(),
                          ),
                          items: paymentMethods.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
                          onChanged: (val) => setState(() => selectedPayment = val!),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 25),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E2A),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: const Color(0xFFD4AF37)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('المبلغ الإجمالي:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        Text(
                          '${cart.totalAmount.toStringAsFixed(2)} ج.م',
                          style: const TextStyle(fontSize: 20, color: Color(0xFFD4AF37), fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD4AF37),
                        foregroundColor: Colors.black,
                      ),
                      onPressed: () => _submitOrder(cart),
                      child: const Text('تأكيد وإرسال الطلب', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}