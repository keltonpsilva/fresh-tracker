import '../models/food_item.dart';

/// Interface for food item service implementations.
/// This allows different storage backends (SQLite, in-memory, etc.) to be used interchangeably.
abstract class IFoodItemService {
  /// Get all food items
  Future<List<FoodItem>> getAllItems();

  /// Get filtered items by category and search query
  /// 
  /// [category] - The category to filter by. Use 'All' or null for all categories.
  ///              Use 'Expiring' to get items expiring within 3 days.
  /// [searchQuery] - Optional search query to filter items by name.
  Future<List<FoodItem>> getFilteredItems({
    String? category,
    String? searchQuery,
  });

  /// Get available categories
  List<String> getCategories();

  /// Add a new food item
  /// 
  /// Returns the ID of the newly added item (or a positive integer on success).
  Future<int> addItem(FoodItem item);

  /// Remove a food item
  /// 
  /// Returns the number of items removed (0 if not found, 1 if successful).
  Future<int> removeItem(FoodItem item);

  /// Update a food item
  /// 
  /// [oldItem] - The item to be replaced
  /// [newItem] - The new item data
  /// Returns the number of items updated (0 if not found, 1 if successful).
  Future<int> updateItem(FoodItem oldItem, FoodItem newItem);

  /// Import demo data into the storage
  Future<void> importDemoData();
}

