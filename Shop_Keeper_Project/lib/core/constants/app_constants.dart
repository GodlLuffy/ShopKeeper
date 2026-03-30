class AppConstants {
  AppConstants._();

  static const String appName = 'ShopKeeper PRO';
  static const String appVersion = '2.0.0';
  static const String buildNumber = 'PRO-2026';
  
  // Stock Thresholds
  static const int lowStockThreshold = 5;
  static const int criticalStockThreshold = 2;

  // Tax Defaults
  static const double defaultGstRate = 0.18; // 18%

  // Discount Limits
  static const double maxDiscountPercentage = 100;

  // Pagination
  static const int defaultPageSize = 50;

  // Currency
  static const String currencySymbol = '₹';
  static const String currencyCode = 'INR';

  // Hive Box Names
  static const String productsBox = 'products_box';
  static const String salesBox = 'sales_box';
  static const String expensesBox = 'expenses_box';
  static const String inventoryLogsBox = 'inventory_logs_box';
  static const String customersBox = 'customers_box';
  static const String creditTransactionsBox = 'credit_transactions_box';
  static const String syncQueueBox = 'sync_queue_box';
  static const String settingsBox = 'settings_box';

  // Hive Type Adapter IDs
  static const int productTableTypeId = 1;
  static const int saleTableTypeId = 2;
  static const int expenseTableTypeId = 3;
  static const int inventoryLogTableTypeId = 4;
  static const int customerTableTypeId = 5;
  static const int creditTransactionTableTypeId = 6;

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
