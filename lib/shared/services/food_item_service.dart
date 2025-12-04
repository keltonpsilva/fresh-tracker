import 'package:flutter/material.dart';

import '../models/food_item.dart';

class FoodItemService {
  static final FoodItemService _instance = FoodItemService._internal();
  factory FoodItemService() => _instance;
  FoodItemService._internal();

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
  List<FoodItem> getAllItems() {
    return List.unmodifiable(_foodItems);
  }

  // Get filtered items by category and search query
  List<FoodItem> getFilteredItems({
    String? category,
    String? searchQuery,
  }) {
    var items = _foodItems;

    // Filter by category
    if (category != null && category != 'All') {
      if (category == 'Expiring') {
        items = items.where((item) {
          final days = item.expirationDate.difference(DateTime.now()).inDays;
          return days <= 3 && days >= 0;
        }).toList();
      } else {
        items = items.where((item) => item.category == category).toList();
      }
    }

    // Filter by search query
    if (searchQuery != null && searchQuery.isNotEmpty) {
      items = items
          .where(
            (item) => item.name.toLowerCase().contains(
              searchQuery.toLowerCase(),
            ),
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
  void addItem(FoodItem item) {
    _foodItems.add(item);
  }

  // Remove a food item
  void removeItem(FoodItem item) {
    _foodItems.remove(item);
  }

  // Update a food item
  void updateItem(FoodItem oldItem, FoodItem newItem) {
    final index = _foodItems.indexOf(oldItem);
    if (index != -1) {
      _foodItems[index] = newItem;
    }
  }
}

