import 'package:flutter/material.dart';

import '../../shared/models/food_item.dart';
import '../../shared/services/i_food_item_service.dart';
import '../../shared/services/food_item_service_factory.dart';

class EditItemScreen extends StatefulWidget {
  final FoodItem item;

  const EditItemScreen({super.key, required this.item});

  @override
  State<EditItemScreen> createState() => _EditItemScreenState();
}

class _EditItemScreenState extends State<EditItemScreen> {
  final IFoodItemService _foodItemService = FoodItemServiceFactory.getService();
  final TextEditingController _itemNameController = TextEditingController();
  final TextEditingController _openDateController = TextEditingController();
  final TextEditingController _useByDateController = TextEditingController();

  String? _selectedCategory;
  int _quantity = 1;
  late DateTime _openDate;
  DateTime? _useByDate;
  late FoodItem _oldItem;

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
  void initState() {
    super.initState();

    // Pre-fill form with existing item data
    _oldItem = widget.item;
    _itemNameController.text = _oldItem.name;
    _selectedCategory = _oldItem.category;
    _quantity = _oldItem.quantity;
    _useByDate = _oldItem.useByDate;

    // Set open date - now always required
    _openDate = _oldItem.openDate;
    _openDateController.text =
        '${_openDate.day.toString().padLeft(2, '0')}/${_openDate.month.toString().padLeft(2, '0')}/${_openDate.year}';

    if (_useByDate != null) {
      _useByDateController.text =
          '${_useByDate!.day.toString().padLeft(2, '0')}/${_useByDate!.month.toString().padLeft(2, '0')}/${_useByDate!.year}';
    }
  }

  @override
  void dispose() {
    _itemNameController.dispose();
    _openDateController.dispose();
    _useByDateController.dispose();
    super.dispose();
  }

  Future<void> _selectOpenDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _openDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _openDate = picked;
        _openDateController.text =
            '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
      });
    }
  }

  Future<void> _selectUseByDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _useByDate ?? DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _useByDate = picked;
        _useByDateController.text =
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

  Color _getStatusColor(DateTime useByDate) {
    final days = useByDate.difference(DateTime.now()).inDays;
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

  Future<void> _updateItem() async {
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
    if (_useByDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a use by date')),
      );
      return;
    }

    final statusColor = _getStatusColor(_useByDate!);
    final icon = _getIconForCategory(_selectedCategory!);
    final iconBackgroundColor = _getIconBackgroundColor(_selectedCategory!);

    final foodItem = FoodItem(
      name: _itemNameController.text.trim(),
      category: _selectedCategory!,
      subcategory: _selectedCategory!,
      useByDate: _useByDate!,
      statusColor: statusColor,
      icon: icon,
      iconBackgroundColor: iconBackgroundColor,
      openDate: _openDate, // Now always required
      quantity: _quantity,
      quantityUnit: _oldItem.quantityUnit, // Now always required
      notes: _oldItem.notes, // Preserve notes when editing
    );

    await _foodItemService.updateItem(_oldItem, foodItem);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Item updated successfully!')),
      );
      Navigator.of(context).pop();
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
                      'Edit Item',
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
                      'Open Date',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2C2C2C),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _openDateController,
                      readOnly: true,
                      onTap: _selectOpenDate,
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
                      'Use By Date',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2C2C2C),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _useByDateController,
                      readOnly: true,
                      onTap: _selectUseByDate,
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

            // Update Item Button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _updateItem,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Update Item',
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
