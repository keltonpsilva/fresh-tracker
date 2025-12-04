import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fresh Track',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const WelcomeScreen(),
    );
  }
}

class OnboardingSlide {
  final String title;
  final String subtitle;

  const OnboardingSlide({required this.title, required this.subtitle});
}

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingSlide> _slides = const [
    OnboardingSlide(
      title: 'Waste Less, Save More',
      subtitle:
          'Easily track food in your fridge, reduce waste, and manage your kitchen inventory.',
    ),
    OnboardingSlide(
      title: 'Smart Expiration Tracking',
      subtitle:
          'Get timely notifications about expiring items and never let food go to waste again.',
    ),
    OnboardingSlide(
      title: 'Plan Meals, Save Money',
      subtitle:
          'Create meal plans based on what you have, reduce grocery trips, and save on your food budget.',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onGetStartedPressed(BuildContext context) {
    if (_currentPage < _slides.length - 1) {
      // Navigate to next slide
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // On last slide, proceed to main app
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Welcome! Let\'s get started!'),
          duration: Duration(seconds: 2),
        ),
      );
      // TODO: Navigate to main app screen
    }
  }

  void _onSignInPressed(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const DashboardScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const Spacer(flex: 2),

              // Refrigerator Illustration
              _buildRefrigeratorIllustration(),
              const SizedBox(height: 40),

              // Title & Subtitle Slider
              Expanded(
                flex: 2,
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemCount: _slides.length,
                  itemBuilder: (context, index) {
                    final slide = _slides[index];
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          slide.title,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2C2C2C),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          slide.subtitle,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    );
                  },
                ),
              ),

              const Spacer(flex: 1),

              // Pagination Dots
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _slides.length,
                  (index) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: _buildPaginationDot(isActive: index == _currentPage),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Get Started Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () => _onGetStartedPressed(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    _currentPage < _slides.length - 1 ? 'Next' : 'Get Started',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              // Sign In (only show on last slide)
              if (_currentPage == _slides.length - 1) ...[
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => _onSignInPressed(context),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey[600],
                  ),
                  child: const Text(
                    'Sign In',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ),
              ],

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  // -------------------------------
  // Refrigerator Illustration
  // -------------------------------
  Widget _buildRefrigeratorIllustration() {
    return SizedBox(
      height: 280,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Floor base
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 20,
              decoration: BoxDecoration(
                color: const Color(0xFFE8E8E8),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),

          // Refrigerator body
          Positioned(
            bottom: 20,
            child: Container(
              width: 200,
              height: 260,
              decoration: BoxDecoration(
                color: const Color(0xFFD0D0D0),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF9E9E9E), width: 2),
              ),
              child: Stack(
                children: [
                  // Door edge
                  Positioned(
                    right: -10,
                    top: 0,
                    bottom: 0,
                    child: Container(
                      width: 8,
                      decoration: BoxDecoration(
                        color: const Color(0xFFB0B0B0),
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(8),
                          bottomRight: Radius.circular(8),
                        ),
                      ),
                    ),
                  ),

                  // Shelves
                  Positioned(top: 40, left: 8, right: 8, child: _buildShelf()),
                  Positioned(top: 100, left: 8, right: 8, child: _buildShelf()),
                  Positioned(top: 160, left: 8, right: 8, child: _buildShelf()),

                  // Food items
                  Positioned(
                    top: 50,
                    left: 20,
                    child: _buildFoodItem(Colors.orange, 12),
                  ),
                  Positioned(
                    top: 50,
                    left: 40,
                    child: _buildFoodItem(Colors.red, 10),
                  ),
                  Positioned(
                    top: 110,
                    left: 30,
                    child: _buildFoodItem(Colors.green, 14),
                  ),
                  Positioned(
                    top: 170,
                    left: 25,
                    child: _buildFoodItem(Colors.yellow, 11),
                  ),

                  // Drawers
                  Positioned(
                    bottom: 20,
                    left: 8,
                    right: 8,
                    child: Container(
                      height: 30,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0E0E0).withOpacity(0.6),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: const Color(0xFF9E9E9E)),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 55,
                    left: 8,
                    right: 8,
                    child: Container(
                      height: 30,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0E0E0).withOpacity(0.6),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: const Color(0xFF9E9E9E)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShelf() {
    return Container(height: 2, color: const Color(0xFF9E9E9E));
  }

  Widget _buildFoodItem(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }

  // -------------------------------
  // Animated Pagination Dots
  // -------------------------------
  Widget _buildPaginationDot({required bool isActive}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      width: isActive ? 20 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive
            ? const Color(0xFF4CAF50)
            : const Color(0xFF4CAF50).withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}

// -------------------------------
// Dashboard Page
// -------------------------------

class FoodItem {
  final String name;
  final String category;
  final String subcategory;
  final DateTime expirationDate;
  final Color statusColor;
  final IconData icon;
  final Color iconBackgroundColor;

  FoodItem({
    required this.name,
    required this.category,
    required this.subcategory,
    required this.expirationDate,
    required this.statusColor,
    required this.icon,
    required this.iconBackgroundColor,
  });

  String get expirationStatus {
    final now = DateTime.now();
    final difference = expirationDate.difference(now).inDays;

    if (difference < 0) {
      if (difference == -1) {
        return 'Expired yesterday';
      }
      return 'Expired ${-difference} days ago';
    } else if (difference == 0) {
      return 'Expires today';
    } else if (difference == 1) {
      return 'Expires Tomorrow';
    } else {
      return 'Expires in $difference days';
    }
  }
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _selectedCategory = 'All';
  final TextEditingController _searchController = TextEditingController();

  final List<String> _categories = [
    'All',
    'Produce',
    'Dairy',
    'Meat',
    'Expiring',
  ];

  final List<FoodItem> _foodItems = [
    FoodItem(
      name: 'Organic Eggs',
      category: 'Dairy',
      subcategory: 'Dairy & Eggs',
      expirationDate: DateTime.now().subtract(const Duration(days: 1)),
      statusColor: Colors.red,
      icon: Icons.egg,
      iconBackgroundColor: const Color(0xFFFFE5E5),
    ),
    FoodItem(
      name: 'Milk',
      category: 'Dairy',
      subcategory: 'Dairy',
      expirationDate: DateTime.now().add(const Duration(days: 1)),
      statusColor: Colors.orange,
      icon: Icons.water_drop,
      iconBackgroundColor: const Color(0xFFFFF4E5),
    ),
    FoodItem(
      name: 'Chicken Breast',
      category: 'Meat',
      subcategory: 'Meat',
      expirationDate: DateTime.now().add(const Duration(days: 3)),
      statusColor: Colors.green,
      icon: Icons.restaurant,
      iconBackgroundColor: const Color(0xFFE5F5E5),
    ),
    FoodItem(
      name: 'Broccoli',
      category: 'Produce',
      subcategory: 'Produce',
      expirationDate: DateTime.now().add(const Duration(days: 5)),
      statusColor: Colors.green,
      icon: Icons.eco,
      iconBackgroundColor: const Color(0xFFE5F5E5),
    ),
    FoodItem(
      name: 'Yogurt',
      category: 'Dairy',
      subcategory: 'Dairy',
      expirationDate: DateTime.now().add(const Duration(days: 7)),
      statusColor: Colors.green,
      icon: Icons.lunch_dining,
      iconBackgroundColor: const Color(0xFFE5F5E5),
    ),
  ];

  List<FoodItem> get _filteredItems {
    var items = _foodItems;

    // Filter by category
    if (_selectedCategory != 'All') {
      if (_selectedCategory == 'Expiring') {
        items = items.where((item) {
          final days = item.expirationDate.difference(DateTime.now()).inDays;
          return days <= 3 && days >= 0;
        }).toList();
      } else {
        items = items
            .where((item) => item.category == _selectedCategory)
            .toList();
      }
    }

    // Filter by search
    if (_searchController.text.isNotEmpty) {
      items = items
          .where(
            (item) => item.name.toLowerCase().contains(
              _searchController.text.toLowerCase(),
            ),
          )
          .toList();
    }

    return items;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Top Navigation Bar
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12.0,
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.menu, color: Color(0xFF2C2C2C)),
                    onPressed: () {
                      // TODO: Open drawer
                    },
                  ),
                  const Expanded(
                    child: Text(
                      'My Fridge',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C2C2C),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.notifications_outlined,
                      color: Color(0xFF2C2C2C),
                    ),
                    onPressed: () {
                      // TODO: Open notifications
                    },
                  ),
                ],
              ),
            ),

            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Search for items...',
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  filled: true,
                  fillColor: const Color(0xFFF5F5F5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ),

            // Category Filters
            SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final category = _categories[index];
                  final isSelected = _selectedCategory == category;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: FilterChip(
                      label: Text(category),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _selectedCategory = category;
                        });
                      },
                      selectedColor: const Color(0xFFE5F5E5),
                      backgroundColor: Colors.grey[200],
                      labelStyle: TextStyle(
                        color: isSelected
                            ? const Color(0xFF2C2C2C)
                            : Colors.grey[700],
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            // Food Items List
            Expanded(
              child: _filteredItems.isEmpty
                  ? const Center(
                      child: Text(
                        'No items found',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      itemCount: _filteredItems.length,
                      itemBuilder: (context, index) {
                        final item = _filteredItems[index];
                        return _buildFoodItemCard(item);
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Add new item
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Add new item')));
        },
        backgroundColor: const Color(0xFF4CAF50),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildFoodItemCard(FoodItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          // Status Color Bar
          Container(
            width: 4,
            height: 80,
            decoration: BoxDecoration(
              color: item.statusColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
            ),
          ),

          // Item Icon
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: item.iconBackgroundColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(item.icon, color: item.statusColor, size: 28),
            ),
          ),

          // Item Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2C2C2C),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.subcategory,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                Text(
                  item.expirationStatus,
                  style: TextStyle(
                    fontSize: 14,
                    color: item.statusColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // More options icon
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.grey),
            onPressed: () {
              // TODO: Show item options
            },
          ),
        ],
      ),
    );
  }
}
