class AppConstants {
  static const String appName = 'ShopKeeper';
  
  // Hive Box Names
  static const String productsBox = 'products_box';
  static const String salesBox = 'sales_box';
  static const String expensesBox = 'expenses_box';
  static const String inventoryLogsBox = 'inventory_logs_box';
  static const String syncQueueBox = 'sync_queue_box';

  // Categories
  static const List<String> productCategories = [
    'Sweets/Bakery',
    'Biscuits/Snacks',
    'Beverages',
    'Grains/Pulses',
    'Dairy',
    'General Store',
    'Other',
  ];

  static const List<String> expenseCategories = [
    'Rent',
    'Electricity',
    'Transport',
    'Purchase (Inventory)',
    'Salary',
    'Maintenance',
    'Other',
  ];
}
