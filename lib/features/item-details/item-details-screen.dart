import 'package:flutter/material.dart';

import '../models/food_item.dart';

class ItemDetailsScreen extends StatelessWidget {
  final FoodItem item;

  const ItemDetailsScreen({super.key, required this.item});

  String _formatDate(DateTime date) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  double _getFreshnessProgress() {
    final now = DateTime.now();
    final purchaseDate =
        item.purchaseDate ??
        item.expirationDate.subtract(const Duration(days: 7));
    final totalDays = item.expirationDate.difference(purchaseDate).inDays;
    final remainingDays = item.expirationDate.difference(now).inDays;

    if (totalDays <= 0) return 0.0;
    if (remainingDays <= 0) return 0.0;

    return (remainingDays / totalDays).clamp(0.0, 1.0);
  }

  Color _getFreshnessColor() {
    final days = item.expirationDate.difference(DateTime.now()).inDays;
    if (days <= 1) return Colors.red;
    if (days <= 3) return Colors.orange;
    return Colors.green;
  }

  String _getQuantityText() {
    if (item.quantity != null) {
      return '${item.quantity} ${item.quantityUnit ?? 'unit'}';
    }
    return '1 unit';
  }

  @override
  Widget build(BuildContext context) {
    final purchaseDate =
        item.purchaseDate ??
        item.expirationDate.subtract(const Duration(days: 7));
    final freshnessProgress = _getFreshnessProgress();
    final freshnessColor = _getFreshnessColor();
    final daysRemaining = item.expirationDate.difference(DateTime.now()).inDays;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: Color(0xFF2C2C2C)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          item.name,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2C2C2C),
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Image Section
                  Container(
                    margin: const EdgeInsets.all(16),
                    height: 200,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1B5E20), // Dark green background
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Icon(
                        item.icon,
                        size: 100,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ),

                  // Freshness Indicator
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Freshness',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2C2C2C),
                          ),
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: freshnessProgress,
                            minHeight: 8,
                            backgroundColor: Colors.green[100],
                            valueColor: AlwaysStoppedAnimation<Color>(
                              daysRemaining <= 3 ? Colors.orange : Colors.green,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          daysRemaining < 0
                              ? 'Expired ${-daysRemaining} ${-daysRemaining == 1 ? 'day' : 'days'} ago'
                              : daysRemaining == 0
                              ? 'Expires today'
                              : daysRemaining == 1
                              ? 'Expires Tomorrow'
                              : 'Expires in $daysRemaining days',
                          style: TextStyle(
                            fontSize: 14,
                            color: freshnessColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Item Details List
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      children: [
                        _buildDetailRow(
                          icon: Icons.egg,
                          label: 'Category',
                          value: item.subcategory,
                        ),
                        const SizedBox(height: 16),
                        _buildDetailRow(
                          icon: Icons.inventory_2,
                          label: 'Quantity',
                          value: _getQuantityText(),
                        ),
                        const SizedBox(height: 16),
                        _buildDetailRow(
                          icon: Icons.calendar_today,
                          label: 'Added On',
                          value: _formatDate(purchaseDate),
                        ),
                        const SizedBox(height: 16),
                        _buildDetailRow(
                          icon: Icons.event_busy,
                          label: 'Use By',
                          value: _formatDate(item.expirationDate),
                          isBold: true,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Notes Section
                  if (item.notes != null && item.notes!.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.description,
                                color: Colors.grey[600],
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Notes',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF2C2C2C),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            item.notes!,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ],
              ),
            ),
          ),

          // Bottom Action Buttons
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Edit Button
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.edit, color: Color(0xFF2C2C2C)),
                    onPressed: () {
                      // TODO: Navigate to edit screen
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Edit item')),
                      );
                    },
                  ),
                ),

                // Mark as Consumed Button
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: ElevatedButton(
                      onPressed: () {
                        // TODO: Mark as consumed
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Item marked as consumed'),
                          ),
                        );
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4CAF50),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        'Mark as Consumed',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),

                // Delete Button
                Container(
                  width: 56,
                  height: 56,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.white),
                    onPressed: () {
                      // TODO: Delete item
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Delete Item'),
                          content: const Text(
                            'Are you sure you want to delete this item?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Item deleted')),
                                );
                                Navigator.of(context).pop();
                              },
                              child: const Text(
                                'Delete',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    bool isBold = false,
  }) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.grey[700], size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            label,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            color: const Color(0xFF2C2C2C),
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
