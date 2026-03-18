import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shop_keeper_project/database/tables/product_table.dart';
import 'package:shop_keeper_project/database/tables/sale_table.dart';
import 'package:shop_keeper_project/database/tables/expense_table.dart';

class SyncService {
  final FirebaseFirestore? firestore;
  final FirebaseAuth? auth;
  final Box<ProductTable> productBox;
  final Box<SaleTable> saleBox;
  final Box<ExpenseTable> expenseBox;

  SyncService({
    this.firestore,
    this.auth,
    required this.productBox,
    required this.saleBox,
    required this.expenseBox,
  });

  Future<void> syncAll() async {
    final user = auth?.currentUser;
    if (firestore == null || user == null) return;

    final userId = user.uid;
    final batch = firestore!.batch();
    int operationCount = 0;

    // Sync Products
    final unsyncedProducts = productBox.values.where((p) => !p.isSynced).toList();
    for (var product in unsyncedProducts) {
      if (operationCount >= 500) break; // Firestore batch limit
      final ref = firestore!.collection('users').doc(userId).collection('products').doc(product.id);
      batch.set(ref, product.toMap());
      operationCount++;
    }

    // Sync Sales
    final unsyncedSales = saleBox.values.where((s) => !s.isSynced).toList();
    for (var sale in unsyncedSales) {
      if (operationCount >= 500) break;
      final ref = firestore!.collection('users').doc(userId).collection('sales').doc(sale.id);
      batch.set(ref, sale.toMap());
      operationCount++;
    }

    // Sync Expenses
    final unsyncedExpenses = expenseBox.values.where((e) => !e.isSynced).toList();
    for (var expense in unsyncedExpenses) {
      if (operationCount >= 500) break;
      final ref = firestore!.collection('users').doc(userId).collection('expenses').doc(expense.id);
      batch.set(ref, expense.toMap());
      operationCount++;
    }

    if (operationCount > 0) {
      await batch.commit();

      // Update local status after successful sync
      for (var product in unsyncedProducts) {
        final updated = ProductTable(
          id: product.id,
          name: product.name,
          category: product.category,
          buyPrice: product.buyPrice,
          sellPrice: product.sellPrice,
          stockQuantity: product.stockQuantity,
          minStockAlert: product.minStockAlert,
          userId: product.userId,
          createdAt: product.createdAt,
          isSynced: true,
          imageUrl: product.imageUrl,
          barcode: product.barcode,
        );
        await productBox.put(product.id, updated);
      }

      for (var sale in unsyncedSales) {
        final updated = SaleTable(
          id: sale.id,
          productId: sale.productId,
          productName: sale.productName,
          quantitySold: sale.quantitySold,
          salePrice: sale.salePrice,
          totalAmount: sale.totalAmount,
          totalProfit: sale.totalProfit,
          date: sale.date,
          userId: sale.userId,
          isSynced: true,
        );
        await saleBox.put(sale.id, updated);
      }

      for (var expense in unsyncedExpenses) {
        final updated = ExpenseTable(
          id: expense.id,
          title: expense.title,
          amount: expense.amount,
          category: expense.category,
          date: expense.date,
          userId: expense.userId,
          isSynced: true,
        );
        await expenseBox.put(expense.id, updated);
      }
    }
  }
}
