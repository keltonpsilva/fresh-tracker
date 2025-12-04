import 'package:flutter/material.dart';

import '../add-item/add-item-screen.dart';
import '../item-details/item-details-screen.dart';
import '../../shared/models/food_item.dart';
import '../../shared/services/food_item_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final FoodItemService _foodItemService = FoodItemService();
  String _selectedCategory = 'All';
  final TextEditingController _searchController = TextEditingController();
  List<FoodItem> _filteredItems = [];
  bool _isLoading = true;

  List<String> get _categories => _foodItemService.getCategories();

  Future<void> _loadItems() async {
    setState(() => _isLoading = true);
    try {
      final items = await _foodItemService.getFilteredItems(
        category: _selectedCategory,
        searchQuery: _searchController.text,
      );
      setState(() {
        _filteredItems = items;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _filteredItems = [];
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadItems();
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
                onChanged: (_) => _loadItems(),
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
                        _loadItems();
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
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredItems.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.kitchen,
                              size: 80,
                              color: const Color(0xFF2C2C2C),
                            ),
                            const SizedBox(height: 24),
                            const Text(
                              'Your fridge is empty',
                              style: TextStyle(
                                fontSize: 20,
                                color: Color(0xFF2C2C2C),
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              "Tap the '+' button below to add your first item and start tracking!",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
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
        onPressed: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const AddItemScreen()),
          );
          _loadItems(); // Reload items after returning from add screen
        },
        backgroundColor: const Color(0xFF4CAF50),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildFoodItemCard(FoodItem item) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ItemDetailsScreen(item: item),
          ),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
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
      ),
    );
  }
}
