import 'package:flutter/material.dart';

class FoodItem {
  final String name;
  final String category;
  final String subcategory;
  final DateTime expirationDate;
  final Color statusColor;
  final IconData icon;
  final Color iconBackgroundColor;
  final DateTime purchaseDate;
  final int? quantity;
  final String? quantityUnit;
  final String? notes;

  FoodItem({
    required this.name,
    required this.category,
    required this.subcategory,
    required this.expirationDate,
    required this.statusColor,
    required this.icon,
    required this.iconBackgroundColor,
    required this.purchaseDate,
    this.quantity,
    this.quantityUnit,
    this.notes,
  });

  String get expirationStatus {
    final now = DateTime.now();
    final difference = expirationDate.difference(now).inDays;

    if (difference < 0) {
      if (difference == -1) {
        return 'Expired yesterday';
      }
      return 'Expired ${-difference} days ago';
    } else if (difference == 0) {
      return 'Expires today';
    } else if (difference == 1) {
      return 'Expires Tomorrow';
    } else {
      return 'Expires in $difference days';
    }
  }
}

