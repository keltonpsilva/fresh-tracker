import 'package:flutter/foundation.dart';

import 'i_food_item_service.dart';
import 'food_item_service.dart';
import 'food_item_service_in_memory.dart';

/// Factory for creating the appropriate food item service based on the platform.
/// 
/// On web, returns an in-memory service (since SQLite is not available).
/// On other platforms, returns the SQLite-based service.
class FoodItemServiceFactory {
  /// Get the appropriate food item service instance for the current platform
  static IFoodItemService getService() {
    return kIsWeb
        ? FoodItemServiceInMemory()
        : FoodItemService();
  }
}

