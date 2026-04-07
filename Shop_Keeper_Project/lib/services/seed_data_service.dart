import 'package:hive/hive.dart';
import 'package:flutter/foundation.dart';
import 'package:shop_keeper_project/database/tables/product_table.dart';
import 'package:shop_keeper_project/database/tables/expense_table.dart';
import 'package:shop_keeper_project/database/tables/customer_table.dart';

class SeedDataService {
  final Box<ProductTable> productBox;
  final Box<ExpenseTable> expenseBox;
  final Box<CustomerTable> customerBox;
  final Box settingsBox;

  SeedDataService({
    required this.productBox,
    required this.expenseBox,
    required this.customerBox,
    required this.settingsBox,
  });

  static const String _seededKey = 'demo_data_seeded';

  bool get isAlreadySeeded => settingsBox.get(_seededKey, defaultValue: false);

  Future<void> seedDemoDataIfNeeded() async {
    if (isAlreadySeeded) {
      debugPrint('SeedData: Demo data already seeded, skipping...');
      return;
    }

    debugPrint('SeedData: Loading demo data...');
    final now = DateTime.now();

    final demoProducts = [
      ProductTable(
        id: 'demo_prod_001',
        name: 'Parle-G Biscuit',
        category: 'Biscuits/Snacks',
        buyPrice: 8.0,
        sellPrice: 10.0,
        stockQuantity: 50,
        minStockAlert: 10,
        userId: 'demo_user',
        createdAt: now,
        barcode: '8901038300011',
      ),
      ProductTable(
        id: 'demo_prod_002',
        name: 'Amul Butter 500g',
        category: 'Dairy',
        buyPrice: 250.0,
        sellPrice: 280.0,
        stockQuantity: 12,
        minStockAlert: 5,
        userId: 'demo_user',
        createdAt: now,
      ),
      ProductTable(
        id: 'demo_prod_003',
        name: 'Tata Salt 1kg',
        category: 'Grains/Pulses',
        buyPrice: 22.0,
        sellPrice: 28.0,
        stockQuantity: 30,
        minStockAlert: 10,
        userId: 'demo_user',
        createdAt: now,
      ),
      ProductTable(
        id: 'demo_prod_004',
        name: 'Fortune Oil 1L',
        category: 'Grains/Pulses',
        buyPrice: 160.0,
        sellPrice: 185.0,
        stockQuantity: 4,
        minStockAlert: 10,
        userId: 'demo_user',
        createdAt: now,
      ),
      ProductTable(
        id: 'demo_prod_005',
        name: 'Pepsi 2L',
        category: 'Beverages',
        buyPrice: 75.0,
        sellPrice: 90.0,
        stockQuantity: 25,
        minStockAlert: 10,
        userId: 'demo_user',
        createdAt: now,
        barcode: '8901038300028',
      ),
      ProductTable(
        id: 'demo_prod_006',
        name: 'Maggi Noodles',
        category: 'Biscuits/Snacks',
        buyPrice: 12.0,
        sellPrice: 14.0,
        stockQuantity: 3,
        minStockAlert: 20,
        userId: 'demo_user',
        createdAt: now,
      ),
      ProductTable(
        id: 'demo_prod_007',
        name: 'Dabur Honey 500g',
        category: 'General Store',
        buyPrice: 280.0,
        sellPrice: 320.0,
        stockQuantity: 8,
        minStockAlert: 5,
        userId: 'demo_user',
        createdAt: now,
      ),
      ProductTable(
        id: 'demo_prod_008',
        name: 'Colgate Toothpaste 100g',
        category: 'General Store',
        buyPrice: 80.0,
        sellPrice: 95.0,
        stockQuantity: 20,
        minStockAlert: 10,
        userId: 'demo_user',
        createdAt: now,
      ),
      ProductTable(
        id: 'demo_prod_009',
        name: ' Britannia Cake Rusk',
        category: 'Sweets/Bakery',
        buyPrice: 45.0,
        sellPrice: 55.0,
        stockQuantity: 1,
        minStockAlert: 10,
        userId: 'demo_user',
        createdAt: now,
      ),
      ProductTable(
        id: 'demo_prod_010',
        name: 'Mother Dairy Paneer 200g',
        category: 'Dairy',
        buyPrice: 90.0,
        sellPrice: 110.0,
        stockQuantity: 15,
        minStockAlert: 8,
        userId: 'demo_user',
        createdAt: now,
      ),
    ];

    final demoExpenses = [
      ExpenseTable(
        id: 'demo_exp_001',
        title: 'Shop Rent - March',
        amount: 15000.0,
        category: 'Rent',
        date: now.subtract(const Duration(days: 5)),
        userId: 'demo_user',
      ),
      ExpenseTable(
        id: 'demo_exp_002',
        title: 'Electricity Bill',
        amount: 3500.0,
        category: 'Electricity',
        date: now.subtract(const Duration(days: 10)),
        userId: 'demo_user',
      ),
      ExpenseTable(
        id: 'demo_exp_003',
        title: 'Transport - Wholesale Market',
        amount: 800.0,
        category: 'Transport',
        date: now.subtract(const Duration(days: 3)),
        userId: 'demo_user',
      ),
      ExpenseTable(
        id: 'demo_exp_004',
        title: 'Stock Purchase - Beverages',
        amount: 12000.0,
        category: 'Purchase (Inventory)',
        date: now.subtract(const Duration(days: 7)),
        userId: 'demo_user',
      ),
    ];

    final demoCustomers = [
      CustomerTable(
        id: 'demo_cust_001',
        shopId: 'demo_shop',
        name: 'Ramesh Kumar',
        phone: '+91 98765 43210',
        totalCredit: 1500.0,
        lastTransactionDate: now.subtract(const Duration(days: 2)),
        createdAt: now.subtract(const Duration(days: 30)),
        notes: 'Regular customer, pays on weekends',
      ),
      CustomerTable(
        id: 'demo_cust_002',
        shopId: 'demo_shop',
        name: 'Sunita Devi',
        phone: '+91 99887 76655',
        totalCredit: 2500.0,
        lastTransactionDate: now.subtract(const Duration(days: 1)),
        createdAt: now.subtract(const Duration(days: 45)),
        notes: 'Neighbor, reliable payer',
      ),
      CustomerTable(
        id: 'demo_cust_003',
        shopId: 'demo_shop',
        name: 'Mohammed Rafi',
        phone: '+91 95555 12345',
        totalCredit: 500.0,
        lastTransactionDate: now.subtract(const Duration(days: 5)),
        createdAt: now.subtract(const Duration(days: 15)),
      ),
    ];

    try {
      for (final product in demoProducts) {
        await productBox.put(product.id, product);
      }
      debugPrint('SeedData: ${demoProducts.length} products seeded');

      for (final expense in demoExpenses) {
        await expenseBox.put(expense.id, expense);
      }
      debugPrint('SeedData: ${demoExpenses.length} expenses seeded');

      for (final customer in demoCustomers) {
        await customerBox.put(customer.id, customer);
      }
      debugPrint('SeedData: ${demoCustomers.length} customers seeded');

      await settingsBox.put(_seededKey, true);
      debugPrint('SeedData: Demo data seeded successfully!');
    } catch (e) {
      debugPrint('SeedData: Error seeding data: $e');
    }
  }

  Future<void> clearSeedData() async {
    await settingsBox.put(_seededKey, false);
    await productBox.clear();
    await expenseBox.clear();
    await customerBox.clear();
    debugPrint('SeedData: All demo data cleared');
  }
}
