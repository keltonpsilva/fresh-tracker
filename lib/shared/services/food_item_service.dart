import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import '../models/food_item.dart';
import 'i_food_item_service.dart';

/// ------------------------------------------------------------
/// ICON LOOKUP TABLE (tree-shake safe)
/// ------------------------------------------------------------
/// These values must match the icons you save.
/// You can print icon.codePoint to confirm each one.
const Map<int, IconData> kIconLookup = {
  // Demo data icons
  0xeac0: Icons.egg, // Icons.egg.codePoint
  0xf054b: Icons.water_drop, // Icons.water_drop.codePoint
  0xe56c: Icons.restaurant, // Icons.restaurant.codePoint
  0xe63a: Icons.eco, // Icons.eco.codePoint
  0xf109f: Icons.lunch_dining, // Icons.lunch_dining.codePoint
};

class FoodItemService implements IFoodItemService {
  static final FoodItemService _instance = FoodItemService._internal();
  factory FoodItemService() => _instance;
  FoodItemService._internal();

  static const String _tableName = 'food_items';

  /// Demo items
  static final List<FoodItem> _demoFoodItems = [
    FoodItem(
      name: 'Organic Eggs',
      category: 'Dairy',
      subcategory: 'Dairy & Eggs',
      expirationDate: DateTime.now().subtract(const Duration(days: 1)),
      statusColor: Colors.red,
      icon: Icons.egg,
      iconBackgroundColor: const Color(0xFFFFE5E5),
      purchaseDate: DateTime.now().subtract(const Duration(days: 8)),
      quantity: 1,
      quantityUnit: 'dozen',
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
      purchaseDate: DateTime.now().subtract(const Duration(days: 2)),
      quantity: 1,
      quantityUnit: 'bunch',
    ),
    FoodItem(
      name: 'Yogurt',
      category: 'Dairy',
      subcategory: 'Dairy',
      expirationDate: DateTime.now().add(const Duration(days: 7)),
      statusColor: Colors.green,
      icon: Icons.lunch_dining,
      iconBackgroundColor: const Color(0xFFE5F5E5),
      purchaseDate: DateTime.now().subtract(const Duration(days: 1)),
      quantity: 1,
      quantityUnit: 'container',
    ),
  ];

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase(importDemo: true);
    return _database!;
  }

  Future<Database> _initDatabase({bool importDemo = false}) async {
    final documentsDir = await getApplicationDocumentsDirectory();
    await Directory(documentsDir.path).create(recursive: true);
    final dbPath = join(documentsDir.path, 'food_items.db');

    if (importDemo && !await File(dbPath).exists()) {
      final data = await rootBundle.load('assets/food_items.db');
      final bytes = data.buffer.asUint8List();
      await File(dbPath).writeAsBytes(bytes, flush: true);
    }

    return await openDatabase(
      dbPath,
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
      'status_color': item.statusColor.toARGB32(),
      'icon_code_point': item.icon.codePoint,
      'icon_background_color': item.iconBackgroundColor.toARGB32(),
      'purchase_date': item.purchaseDate.millisecondsSinceEpoch,
      'quantity': item.quantity,
      'quantity_unit': item.quantityUnit,
      'notes': item.notes,
    };
  }

  /// -------------------------
  /// FIXED: NO dynamic IconData
  /// -------------------------
  FoodItem _mapToFoodItem(Map<String, dynamic> map) {
    final iconCode = map['icon_code_point'] as int;

    return FoodItem(
      name: map['name'] as String,
      category: map['category'] as String,
      subcategory: map['subcategory'] as String,
      expirationDate: DateTime.fromMillisecondsSinceEpoch(
        map['expiration_date'] as int,
      ),
      statusColor: Color(map['status_color'] as int),

      /// SAFE icon lookup
      icon: kIconLookup[iconCode] ?? Icons.help_outline,

      iconBackgroundColor: Color(map['icon_background_color'] as int),

      purchaseDate: map['purchase_date'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['purchase_date'] as int)
          : DateTime.fromMillisecondsSinceEpoch(
              map['expiration_date'] as int,
            ).subtract(const Duration(days: 7)),

      quantity: map['quantity'] ?? 1,
      quantityUnit: map['quantity_unit'] ?? 'unit',
      notes: map['notes'] as String?,
    );
  }

  @override
  Future<List<FoodItem>> getAllItems() async {
    final db = await database;
    final maps = await db.query(_tableName);
    return List.generate(maps.length, (i) => _mapToFoodItem(maps[i]));
  }

  @override
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

  @override
  List<String> getCategories() {
    return ['All', 'Produce', 'Dairy', 'Meat', 'Expiring'];
  }

  @override
  Future<int> addItem(FoodItem item) async {
    final db = await database;
    return await db.insert(_tableName, _foodItemToMap(item));
  }

  @override
  Future<int> removeItem(FoodItem item) async {
    final db = await database;
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

  bool _itemsEqual(FoodItem a, FoodItem b) {
    return a.name == b.name &&
        a.category == b.category &&
        a.subcategory == b.subcategory &&
        a.expirationDate.millisecondsSinceEpoch ==
            b.expirationDate.millisecondsSinceEpoch;
  }

  @override
  Future<int> updateItem(FoodItem oldItem, FoodItem newItem) async {
    final db = await database;
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

  @override
  Future<void> importDemoData() async {
    final db = await database;
    for (final item in _demoFoodItems) {
      await db.insert(_tableName, _foodItemToMap(item));
    }
  }
}
