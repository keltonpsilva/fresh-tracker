import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';

import '../../shared/models/food_item.dart';
import '../../shared/services/i_food_item_service.dart';
import '../../shared/services/food_item_service_factory.dart';

class AddItemScreen extends StatefulWidget {
  final Product? product;

  const AddItemScreen({super.key, this.product});

  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final IFoodItemService _foodItemService = FoodItemServiceFactory.getService();
  final TextEditingController _itemNameController = TextEditingController();
  final TextEditingController _purchaseDateController = TextEditingController();
  final TextEditingController _expirationDateController =
      TextEditingController();

  String? _selectedCategory;
  int _quantity = 1;
  late DateTime _purchaseDate;
  DateTime? _expirationDate;

  @override
  void initState() {
    super.initState();
    // Set purchase date to today by default
    _purchaseDate = DateTime.now();
    _purchaseDateController.text =
        '${_purchaseDate.day.toString().padLeft(2, '0')}/${_purchaseDate.month.toString().padLeft(2, '0')}/${_purchaseDate.year}';

    // Populate form with product data if available
    if (widget.product != null) {
      _populateFormFromProduct(widget.product!);
    }
  }

  void _populateFormFromProduct(Product product) {
    // Set product name
    if (product.productName != null && product.productName!.isNotEmpty) {
      _itemNameController.text = product.productName!;
    }

    // Map OpenFoodFacts category to app category
    if (product.categories != null && product.categories!.isNotEmpty) {
      final category = _mapOpenFoodFactsCategoryToAppCategory(
        product.categories!,
      );
      _selectedCategory = category;
      // Set estimated expiration date based on category
      if (category != null) {
        _setEstimatedExpirationDate(category);
      }
    }

    // Quantity is always 1 (not extracted from product)
  }

  void _setEstimatedExpirationDate(String category) {
    final estimatedDate = _getEstimatedExpirationDate(category);
    setState(() {
      _expirationDate = estimatedDate;
      _expirationDateController.text =
          '${estimatedDate.day.toString().padLeft(2, '0')}/${estimatedDate.month.toString().padLeft(2, '0')}/${estimatedDate.year}';
    });
  }

  DateTime _getEstimatedExpirationDate(String category) {
    final now = DateTime.now();

    // Estimates are based on opened products (shorter shelf life than unopened)
    switch (category) {
      case 'Produce':
        // Fresh produce (opened) typically lasts 3-7 days
        return now.add(const Duration(days: 5));
      case 'Dairy':
        // Dairy products (opened) typically last 3-7 days
        return now.add(const Duration(days: 5));
      case 'Meat':
        // Meat (opened) typically lasts 1-3 days
        return now.add(const Duration(days: 2));
      case 'Beverages':
        // Beverages (opened) typically last 3-7 days
        return now.add(const Duration(days: 5));
      case 'Snacks':
        // Snacks (opened) typically last 7-14 days
        return now.add(const Duration(days: 30));
      case 'Frozen':
        // Frozen items (thawed/opened) typically last 1-3 days
        return now.add(const Duration(days: 90));
      case 'Other':
      default:
        // Default to 5 days for other opened items
        return now.add(const Duration(days: 5));
    }
  }

  String? _mapOpenFoodFactsCategoryToAppCategory(String categories) {
    final categoriesLower = categories.toLowerCase();

    // Map OpenFoodFacts categories to app categories
    if (categoriesLower.contains('dairy') ||
        categoriesLower.contains('milk') ||
        categoriesLower.contains('cheese') ||
        categoriesLower.contains('yogurt')) {
      return 'Dairy';
    }
    if (categoriesLower.contains('meat') ||
        categoriesLower.contains('poultry') ||
        categoriesLower.contains('fish') ||
        categoriesLower.contains('seafood')) {
      return 'Meat';
    }
    if (categoriesLower.contains('fruit') ||
        categoriesLower.contains('vegetable') ||
        categoriesLower.contains('produce')) {
      return 'Produce';
    }
    if (categoriesLower.contains('beverage') ||
        categoriesLower.contains('drink') ||
        categoriesLower.contains('juice') ||
        categoriesLower.contains('soda')) {
      return 'Beverages';
    }
    if (categoriesLower.contains('snack') ||
        categoriesLower.contains('chip') ||
        categoriesLower.contains('cracker')) {
      return 'Snacks';
    }
    if (categoriesLower.contains('frozen') ||
        categoriesLower.contains('ice cream')) {
      return 'Frozen';
    }

    // Default to "Other" if no match
    return 'Other';
  }

  final List<String> _categories = [
    'Produce',
    'Dairy',
    'Meat',
    'Beverages',
    'Snacks',
    'Frozen',
    'Other',
  ];

  @override
  void dispose() {
    _itemNameController.dispose();
    _purchaseDateController.dispose();
    _expirationDateController.dispose();
    super.dispose();
  }

  Future<void> _selectPurchaseDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _purchaseDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _purchaseDate = picked;
        _purchaseDateController.text =
            '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
      });
    }
  }

  Future<void> _selectExpirationDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          _expirationDate ?? DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _expirationDate = picked;
        _expirationDateController.text =
            '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
      });
    }
  }

  void _incrementQuantity() {
    setState(() {
      _quantity++;
    });
  }

  void _decrementQuantity() {
    if (_quantity > 1) {
      setState(() {
        _quantity--;
      });
    }
  }

  Color _getStatusColor(DateTime expirationDate) {
    final days = expirationDate.difference(DateTime.now()).inDays;
    if (days < 0) return Colors.red;
    if (days <= 3) return Colors.orange;
    return Colors.green;
  }

  IconData _getIconForCategory(String category) {
    switch (category) {
      case 'Produce':
        return Icons.eco;
      case 'Dairy':
        return Icons.water_drop;
      case 'Meat':
        return Icons.restaurant;
      case 'Beverages':
        return Icons.local_drink;
      case 'Snacks':
        return Icons.lunch_dining;
      case 'Frozen':
        return Icons.ac_unit;
      default:
        return Icons.shopping_bag;
    }
  }

  Color _getIconBackgroundColor(String category) {
    switch (category) {
      case 'Produce':
        return const Color(0xFFE5F5E5);
      case 'Dairy':
        return const Color(0xFFFFF4E5);
      case 'Meat':
        return const Color(0xFFFFE5E5);
      case 'Beverages':
        return const Color(0xFFE5F0FF);
      case 'Snacks':
        return const Color(0xFFFFF9E5);
      case 'Frozen':
        return const Color(0xFFE5F5FF);
      default:
        return const Color(0xFFF5F5F5);
    }
  }

  Future<void> _addItem() async {
    if (_itemNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an item name')),
      );
      return;
    }
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a category')));
      return;
    }
    if (_expirationDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an expiration date')),
      );
      return;
    }

    final statusColor = _getStatusColor(_expirationDate!);
    final icon = _getIconForCategory(_selectedCategory!);
    final iconBackgroundColor = _getIconBackgroundColor(_selectedCategory!);

    final foodItem = FoodItem(
      name: _itemNameController.text.trim(),
      category: _selectedCategory!,
      subcategory: _selectedCategory!,
      expirationDate: _expirationDate!,
      statusColor: statusColor,
      icon: icon,
      iconBackgroundColor: iconBackgroundColor,
      purchaseDate: _purchaseDate, // Now always required
      quantity: _quantity,
      quantityUnit: 'unit', // Now always required
    );

    await _foodItemService.addItem(foodItem);

    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Item added to fridge!')));
      Navigator.of(context).pop(true); // Return true to indicate item was added
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12.0,
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, color: Color(0xFF2C2C2C)),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const Expanded(
                    child: Text(
                      'Add New Item',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C2C2C),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 48), // Balance the close button
                ],
              ),
            ),

            // Form Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),

                    // Item Name
                    const Text(
                      'Item Name',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2C2C2C),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _itemNameController,
                      decoration: InputDecoration(
                        hintText: 'e.g., Milk, Eggs, Chicken Breast',
                        filled: true,
                        fillColor: const Color(0xFFF5F5F5),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Category
                    const Text(
                      'Category',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2C2C2C),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: DropdownButtonFormField<String>(
                        initialValue: _selectedCategory,
                        decoration: InputDecoration(
                          hintText: 'Select a category',
                          filled: true,
                          fillColor: const Color(0xFFF5F5F5),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          suffixIcon: const Icon(Icons.keyboard_arrow_down),
                        ),
                        items: _categories.map((category) {
                          return DropdownMenuItem<String>(
                            value: category,
                            child: Text(category),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedCategory = value;
                          });
                          // Set estimated expiration date based on selected category
                          if (value != null) {
                            _setEstimatedExpirationDate(value);
                          }
                        },
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Quantity
                    const Text(
                      '# Quantity',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2C2C2C),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Decrement Button
                          IconButton(
                            onPressed: _decrementQuantity,
                            icon: Container(
                              width: 32,
                              height: 32,
                              decoration: const BoxDecoration(
                                color: Color(0xFFE0E0E0),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.remove,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),

                          // Quantity Display
                          Text(
                            '$_quantity',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF2C2C2C),
                            ),
                          ),

                          // Increment Button
                          IconButton(
                            onPressed: _incrementQuantity,
                            icon: Container(
                              width: 32,
                              height: 32,
                              decoration: const BoxDecoration(
                                color: Color(0xFF4CAF50),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.add,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Purchase Date
                    const Text(
                      'Purchase Date',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2C2C2C),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _purchaseDateController,
                      readOnly: true,
                      onTap: _selectPurchaseDate,
                      decoration: InputDecoration(
                        hintText: 'dd/mm/yyyy',
                        filled: true,
                        fillColor: const Color(0xFFF5F5F5),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        suffixIcon: const Icon(
                          Icons.calendar_today,
                          color: Colors.grey,
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Expiration Date
                    const Text(
                      'Expiration Date',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2C2C2C),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _expirationDateController,
                      readOnly: true,
                      onTap: _selectExpirationDate,
                      decoration: InputDecoration(
                        hintText: 'dd/mm/yyyy',
                        filled: true,
                        fillColor: const Color(0xFFF5F5F5),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        suffixIcon: const Icon(
                          Icons.calendar_today,
                          color: Colors.grey,
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),

            // Add Item Button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _addItem,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Add Item to Fridge',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
