import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../models/food_item.dart';
import 'i_food_item_service.dart';

class FoodItemService implements IFoodItemService {
  static final FoodItemService _instance = FoodItemService._internal();
  factory FoodItemService() => _instance;
  FoodItemService._internal();

  static Database? _database;
  static const String _tableName = 'food_items';

  // Demo food items for seeding the database
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

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'food_items.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $_tableName (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            category TEXT NOT NULL,
            subcategory TEXT NOT NULL,
            expiration_date INTEGER NOT NULL,
            status_color INTEGER NOT NULL,
            icon_code_point INTEGER NOT NULL,
            icon_background_color INTEGER NOT NULL,
            purchase_date INTEGER,
            quantity INTEGER,
            quantity_unit TEXT,
            notes TEXT
          )
        ''');
      },
    );
  }

  Map<String, dynamic> _foodItemToMap(FoodItem item) {
    return {
      'name': item.name,
      'category': item.category,
      'subcategory': item.subcategory,
      'expiration_date': item.expirationDate.millisecondsSinceEpoch,
      'status_color': item.statusColor.value,
      'icon_code_point': item.icon.codePoint,
      'icon_background_color': item.iconBackgroundColor.value,
      'purchase_date': item.purchaseDate?.millisecondsSinceEpoch,
      'quantity': item.quantity,
      'quantity_unit': item.quantityUnit,
      'notes': item.notes,
    };
  }

  FoodItem _mapToFoodItem(Map<String, dynamic> map) {
    return FoodItem(
      name: map['name'] as String,
      category: map['category'] as String,
      subcategory: map['subcategory'] as String,
      expirationDate: DateTime.fromMillisecondsSinceEpoch(
        map['expiration_date'] as int,
      ),
      statusColor: Color(map['status_color'] as int),
      icon: IconData(
        map['icon_code_point'] as int,
        fontFamily: 'MaterialIcons',
      ),
      iconBackgroundColor: Color(map['icon_background_color'] as int),
      purchaseDate: map['purchase_date'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['purchase_date'] as int)
          : null,
      quantity: map['quantity'] as int?,
      quantityUnit: map['quantity_unit'] as String?,
      notes: map['notes'] as String?,
    );
  }

  // Get all food items
  Future<List<FoodItem>> getAllItems() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(_tableName);
    return List.generate(maps.length, (i) => _mapToFoodItem(maps[i]));
  }

  // Get filtered items by category and search query
  Future<List<FoodItem>> getFilteredItems({
    String? category,
    String? searchQuery,
  }) async {
    final db = await database;
    List<Map<String, dynamic>> maps;

    if (category != null && category != 'All') {
      if (category == 'Expiring') {
        final now = DateTime.now();
        final threeDaysFromNow = now.add(const Duration(days: 3));
        maps = await db.query(
          _tableName,
          where: 'expiration_date >= ? AND expiration_date <= ?',
          whereArgs: [
            now.millisecondsSinceEpoch,
            threeDaysFromNow.millisecondsSinceEpoch,
          ],
        );
      } else {
        maps = await db.query(
          _tableName,
          where: 'category = ?',
          whereArgs: [category],
        );
      }
    } else {
      maps = await db.query(_tableName);
    }

    var items = List.generate(maps.length, (i) => _mapToFoodItem(maps[i]));

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
    final db = await database;
    return await db.insert(_tableName, _foodItemToMap(item));
  }

  // Remove a food item
  Future<int> removeItem(FoodItem item) async {
    final db = await database;
    // We need to find the item by its properties since we don't have an ID
    // This is a limitation - ideally FoodItem should have an ID field
    final maps = await db.query(_tableName);
    for (final map in maps) {
      final existingItem = _mapToFoodItem(map);
      if (_itemsEqual(existingItem, item)) {
        return await db.delete(
          _tableName,
          where: 'id = ?',
          whereArgs: [map['id']],
        );
      }
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
    final db = await database;
    // Find the old item by its properties
    final maps = await db.query(_tableName);
    for (final map in maps) {
      final existingItem = _mapToFoodItem(map);
      if (_itemsEqual(existingItem, oldItem)) {
        return await db.update(
          _tableName,
          _foodItemToMap(newItem),
          where: 'id = ?',
          whereArgs: [map['id']],
        );
      }
    }
    return 0;
  }

  // Import demo data into the database
  Future<void> importDemoData() async {
    final db = await database;
    for (final item in _demoFoodItems) {
      await db.insert(_tableName, _foodItemToMap(item));
    }
  }
}
