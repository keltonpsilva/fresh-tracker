import 'package:flutter/material.dart';
import '../models/food_item.dart';

class FoodItemCard extends StatelessWidget {
  final FoodItem item;
  final VoidCallback onMarkAsConsumed;
  final VoidCallback onDelete;
  final VoidCallback onEdit;
  final VoidCallback? onTap;

  const FoodItemCard({
    super.key,
    required this.item,
    required this.onMarkAsConsumed,
    required this.onDelete,
    required this.onEdit,
    this.onTap,
  });

  String _getStorageLocation() {
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

  IconData _getStorageIcon() {
    final storageLocation = _getStorageLocation();
    return storageLocation == 'Fridge' ? Icons.ac_unit : Icons.countertops;
  }

  String _getExpirationText() {
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

  void _showActionMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Edit Option
              ListTile(
                leading: const Icon(Icons.edit, color: Color(0xFF2C2C2C)),
                title: const Text(
                  'Edit',
                  style: TextStyle(fontSize: 16, color: Color(0xFF2C2C2C)),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  onEdit();
                },
              ),
              // Mark as Consumed Option
              ListTile(
                leading: const Icon(Icons.check, color: Color(0xFF4CAF50)),
                title: const Text(
                  'Mark as Consumed',
                  style: TextStyle(fontSize: 16, color: Color(0xFF2C2C2C)),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  onMarkAsConsumed();
                },
              ),
              // Delete Option
              ListTile(
                leading: Icon(Icons.delete_outline, color: Colors.red[700]),
                title: Text(
                  'Delete',
                  style: TextStyle(fontSize: 16, color: Colors.red[700]),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  onDelete();
                },
              ),
              SizedBox(height: MediaQuery.of(context).padding.bottom),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
          // Status bar
          Container(
            width: 4,
            height: 100,
            decoration: BoxDecoration(
              color: item.statusColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
            ),
          ),

          // Tappable main content area
          Expanded(
            child: InkWell(
              onTap: onTap,
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
              child: Row(
                children: [
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
                            _getExpirationText(),
                            style: TextStyle(
                              fontSize: 14,
                              color: item.statusColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                _getStorageIcon(),
                                size: 16,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _getStorageLocation(),
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
                ],
              ),
            ),
          ),

          // Action menu button
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: GestureDetector(
              onTap: () => _showActionMenu(context),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.more_vert,
                  color: Color(0xFF2C2C2C),
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

