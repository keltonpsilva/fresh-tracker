import 'package:flutter/material.dart';
import '../../shared/models/food_item.dart';
import '../../shared/services/i_food_item_service.dart';
import '../../shared/services/food_item_service_factory.dart';
import '../../shared/widgets/info_dialog.dart';
import '../../shared/widgets/notification_item_card.dart';
import '../item_details/item_details_screen.dart';
import '../edit_item/edit_item_screen.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
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
      items = items
          .where((item) => item.name.toLowerCase().contains(query))
          .toList();
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
      return itemDate.isAfter(todayDate) && itemDate.isBefore(weekFromNow) ||
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
      message:
          'Are you sure you want to delete "${item.name}"? This action cannot be undone.',
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
    final hasUpcomingItems =
        _expiringToday.isNotEmpty || _expiringThisWeek.isNotEmpty;
    final hasExpiredItems = _selectedTab == 1 && _filteredItems.isNotEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
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
                      'Notifications',
                      style: TextStyle(
                        fontSize: 20,
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
                            color: _selectedTab == 0
                                ? Colors.white
                                : Colors.transparent,
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
                            color: _selectedTab == 1
                                ? Colors.white
                                : Colors.transparent,
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
            ..._expiringToday.map(
              (item) => NotificationItemCard(
                item: item,
                storageLocation: _getStorageLocation(item),
                onMarkAsConsumed: () => _markAsConsumed(item),
                onDelete: () => _deleteItem(item),
                onEdit: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => EditItemScreen(item: item),
                    ),
                  ).then((_) => _loadItems());
                },
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ItemDetailsScreen(item: item),
                    ),
                  );
                },
              ),
            ),
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
            ..._expiringThisWeek.map(
              (item) => NotificationItemCard(
                item: item,
                storageLocation: _getStorageLocation(item),
                onMarkAsConsumed: () => _markAsConsumed(item),
                onDelete: () => _deleteItem(item),
                onEdit: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => EditItemScreen(item: item),
                    ),
                  ).then((_) => _loadItems());
                },
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ItemDetailsScreen(item: item),
                    ),
                  );
                },
              ),
            ),
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
          ..._filteredItems.map(
            (item) => NotificationItemCard(
              item: item,
              storageLocation: _getStorageLocation(item),
              onMarkAsConsumed: () => _markAsConsumed(item),
              onDelete: () => _deleteItem(item),
              onEdit: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => EditItemScreen(item: item),
                  ),
                ).then((_) => _loadItems());
              },
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ItemDetailsScreen(item: item),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),
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
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
