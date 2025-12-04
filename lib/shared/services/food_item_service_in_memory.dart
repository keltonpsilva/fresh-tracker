import 'package:flutter/material.dart';

import '../models/food_item.dart';
import 'i_food_item_service.dart';

class FoodItemServiceInMemory implements IFoodItemService {
  static final FoodItemServiceInMemory _instance =
      FoodItemServiceInMemory._internal();
  factory FoodItemServiceInMemory() => _instance;
  FoodItemServiceInMemory._internal();

  // In-memory storage using a list
  final List<FoodItem> _items = [];
  int _nextId = 1;

  // Demo food items for seeding
  static final List<FoodItem> _demoFoodItems = [
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
      purchaseDate: DateTime.now().subtract(const Duration(days: 6)),
      quantity: 1,
      quantityUnit: 'Gallon',
      notes: 'Opened recently. Keep in the main compartment, not the door.',
    ),
    FoodItem(
      name: 'Chicken Breast',
      category: 'Meat',
      subcategory: 'Meat',
      expirationDate: DateTime.now().add(const Duration(days: 3)),
      statusColor: Colors.green,
      icon: Icons.restaurant,
      iconBackgroundColor: const Color(0xFFE5F5E5),
      purchaseDate: DateTime.now().subtract(const Duration(days: 2)),
      quantity: 2,
      quantityUnit: 'lbs',
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

  // Get all food items
  Future<List<FoodItem>> getAllItems() async {
    return List.from(_items);
  }

  // Get filtered items by category and search query
  Future<List<FoodItem>> getFilteredItems({
    String? category,
    String? searchQuery,
  }) async {
    var items = List<FoodItem>.from(_items);

    // Filter by category
    if (category != null && category != 'All') {
      if (category == 'Expiring') {
        final now = DateTime.now();
        final threeDaysFromNow = now.add(const Duration(days: 3));
        items = items.where((item) {
          final expirationMs = item.expirationDate.millisecondsSinceEpoch;
          final nowMs = now.millisecondsSinceEpoch;
          final threeDaysMs = threeDaysFromNow.millisecondsSinceEpoch;
          return expirationMs >= nowMs && expirationMs <= threeDaysMs;
        }).toList();
      } else {
        items = items.where((item) => item.category == category).toList();
      }
    }

    // Filter by search query
    if (searchQuery != null && searchQuery.isNotEmpty) {
      items = items
          .where(
            (item) =>
                item.name.toLowerCase().contains(searchQuery.toLowerCase()),
          )
          .toList();
    }

    return items;
  }

  // Get available categories
  List<String> getCategories() {
    return ['All', 'Produce', 'Dairy', 'Meat', 'Expiring'];
  }

  // Add a new food item
  Future<int> addItem(FoodItem item) async {
    _items.add(item);
    return _nextId++;
  }

  // Remove a food item
  Future<int> removeItem(FoodItem item) async {
    final index = _items.indexWhere(
      (existingItem) => _itemsEqual(existingItem, item),
    );
    if (index != -1) {
      _items.removeAt(index);
      return 1;
    }
    return 0;
  }

  // Helper method to compare FoodItems
  bool _itemsEqual(FoodItem a, FoodItem b) {
    return a.name == b.name &&
        a.category == b.category &&
        a.subcategory == b.subcategory &&
        a.expirationDate.millisecondsSinceEpoch ==
            b.expirationDate.millisecondsSinceEpoch;
  }

  // Update a food item
  Future<int> updateItem(FoodItem oldItem, FoodItem newItem) async {
    final index = _items.indexWhere(
      (existingItem) => _itemsEqual(existingItem, oldItem),
    );
    if (index != -1) {
      _items[index] = newItem;
      return 1;
    }
    return 0;
  }

  // Import demo data
  Future<void> importDemoData() async {
    _items.clear();
    _items.addAll(_demoFoodItems);
  }

  // Clear all items (useful for testing)
  Future<void> clear() async {
    _items.clear();
    _nextId = 1;
  }
}
