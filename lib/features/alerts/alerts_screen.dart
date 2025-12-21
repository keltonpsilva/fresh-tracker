import 'package:flutter/material.dart';
import '../../shared/models/food_item.dart';
import '../../shared/services/i_food_item_service.dart';
import '../../shared/services/food_item_service_factory.dart';
import '../../shared/widgets/info_dialog.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  late final IFoodItemService _foodItemService;
  final TextEditingController _searchController = TextEditingController();
  int _selectedTab = 0; // 0 = Upcoming, 1 = Expired
  List<FoodItem> _allItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _foodItemService = FoodItemServiceFactory.getService();
    _loadItems();
  }

  Future<void> _loadItems() async {
    setState(() => _isLoading = true);
    try {
      final items = await _foodItemService.getAllItems();
      setState(() {
        _allItems = items;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _allItems = [];
        _isLoading = false;
      });
    }
  }

  List<FoodItem> get _filteredItems {
    var items = _allItems.where((item) {
      final now = DateTime.now();
      final difference = item.useByDate.difference(now);
      
      if (_selectedTab == 0) {
        // Upcoming: items that haven't expired yet
        return difference.inDays >= 0;
      } else {
        // Expired: items that have expired
        return difference.inDays < 0;
      }
    }).toList();

    // Apply search filter
    if (_searchController.text.isNotEmpty) {
      final query = _searchController.text.toLowerCase();
      items = items.where((item) => 
        item.name.toLowerCase().contains(query)
      ).toList();
    }

    return items;
  }

  List<FoodItem> get _expiringToday {
    final now = DateTime.now();
    return _filteredItems.where((item) {
      final itemDate = DateTime(
        item.useByDate.year,
        item.useByDate.month,
        item.useByDate.day,
      );
      final today = DateTime(now.year, now.month, now.day);
      return itemDate.isAtSameMomentAs(today);
    }).toList();
  }

  List<FoodItem> get _expiringThisWeek {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final weekFromNow = today.add(const Duration(days: 7));
    
    return _filteredItems.where((item) {
      final itemDate = DateTime(
        item.useByDate.year,
        item.useByDate.month,
        item.useByDate.day,
      );
      final todayDate = DateTime(now.year, now.month, now.day);
      
      // Exclude items expiring today (they're in the "Expiring Today" section)
      return itemDate.isAfter(todayDate) && 
             itemDate.isBefore(weekFromNow) || 
             itemDate.isAtSameMomentAs(weekFromNow);
    }).toList();
  }

  String _getStorageLocation(FoodItem item) {
    // Map categories to storage locations
    switch (item.category.toLowerCase()) {
      case 'dairy':
      case 'meat':
        return 'Fridge';
      case 'produce':
        return 'Counter';
      default:
        return 'Fridge'; // Default to fridge
    }
  }

  IconData _getStorageIcon(FoodItem item) {
    final location = _getStorageLocation(item);
    return location == 'Fridge' ? Icons.ac_unit : Icons.countertops;
  }

  String _getExpirationText(FoodItem item) {
    final now = DateTime.now();
    final difference = item.useByDate.difference(now);
    
    if (difference.inDays < 0) {
      // Expired
      final daysAgo = -difference.inDays;
      if (daysAgo == 1) {
        return 'Expired yesterday';
      }
      return 'Expired $daysAgo days ago';
    } else if (difference.inDays == 0) {
      // Expiring today - show hours
      final hours = difference.inHours;
      if (hours <= 0) {
        return 'Expired';
      }
      return 'Expires in $hours ${hours == 1 ? 'hour' : 'hours'}';
    } else if (difference.inDays == 1) {
      return 'Expires in 1 day';
    } else {
      return 'Expires in ${difference.inDays} days';
    }
  }

  Future<void> _markAsConsumed(FoodItem item) async {
    try {
      await _foodItemService.removeItem(item);
      _loadItems();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${item.name} marked as consumed'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to mark item as consumed'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteItem(FoodItem item) async {
    InfoDialog.showConfirmation(
      context: context,
      title: 'Delete Item',
      message: 'Are you sure you want to delete "${item.name}"? This action cannot be undone.',
      confirmText: 'Delete',
      cancelText: 'Cancel',
      onConfirm: () async {
        try {
          await _foodItemService.removeItem(item);
          _loadItems();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${item.name} has been deleted'),
                duration: const Duration(seconds: 2),
              ),
            );
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Failed to delete item'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasUpcomingItems = _expiringToday.isNotEmpty || _expiringThisWeek.isNotEmpty;
    final hasExpiredItems = _selectedTab == 1 && _filteredItems.isNotEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Alerts',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C2C2C),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.settings, color: Color(0xFF2C2C2C)),
                    onPressed: () {
                      // TODO: Open settings
                    },
                  ),
                ],
              ),
            ),

            // Tab Navigation
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedTab = 0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: _selectedTab == 0 ? Colors.white : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Upcoming',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF2C2C2C),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedTab = 1),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: _selectedTab == 1 ? Colors.white : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Expired',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: _selectedTab == 1 
                                ? const Color(0xFF2C2C2C)
                                : Colors.grey[600],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Search for an item',
                  hintStyle: TextStyle(color: Colors.grey[600]),
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  filled: true,
                  fillColor: Colors.white,
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

            const SizedBox(height: 24),

            // Content
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _selectedTab == 0
                      ? _buildUpcomingContent(hasUpcomingItems)
                      : _buildExpiredContent(hasExpiredItems),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingContent(bool hasItems) {
    if (!hasItems) {
      return _buildAllClearMessage();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_expiringToday.isNotEmpty) ...[
            const Text(
              'Expiring Today',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C2C2C),
              ),
            ),
            const SizedBox(height: 12),
            ..._expiringToday.map((item) => _buildItemCard(item)),
            const SizedBox(height: 24),
          ],
          if (_expiringThisWeek.isNotEmpty) ...[
            const Text(
              'Expiring This Week',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C2C2C),
              ),
            ),
            const SizedBox(height: 12),
            ..._expiringThisWeek.map((item) => _buildItemCard(item)),
            const SizedBox(height: 24),
          ],
          if (_expiringToday.isEmpty && _expiringThisWeek.isEmpty)
            _buildAllClearMessage(),
        ],
      ),
    );
  }

  Widget _buildExpiredContent(bool hasItems) {
    if (!hasItems) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.check_circle_outline,
                size: 80,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 24),
              Text(
                'No expired items',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Expired Items',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C2C2C),
            ),
          ),
          const SizedBox(height: 12),
          ..._filteredItems.map((item) => _buildItemCard(item)),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildItemCard(FoodItem item) {
    final storageLocation = _getStorageLocation(item);
    final storageIcon = _getStorageIcon(item);
    final expirationText = _getExpirationText(item);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Orange status bar
          Container(
            width: 4,
            height: 100,
            decoration: const BoxDecoration(
              color: Colors.orange,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
            ),
          ),

          // Item image/icon
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

          // Item details
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
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
                    expirationText,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.orange,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(storageIcon, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        storageLocation,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Action buttons
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Checkmark button
                GestureDetector(
                  onTap: () => _markAsConsumed(item),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE5F5E5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Color(0xFF4CAF50),
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // Trash button
                GestureDetector(
                  onTap: () => _deleteItem(item),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.delete_outline,
                      color: Color(0xFF2C2C2C),
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAllClearMessage() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: Color(0xFFE5F5E5),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.celebration,
                color: Color(0xFF4CAF50),
                size: 40,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'All Clear!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C2C2C),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'No items are expiring soon. Great job managing your inventory!',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

