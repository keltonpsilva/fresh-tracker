import 'package:flutter/material.dart';
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
