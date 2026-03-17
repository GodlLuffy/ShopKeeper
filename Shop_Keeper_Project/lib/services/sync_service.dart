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

    // Sync Products
    for (var product in productBox.values) {
      final ref = firestore!.collection('users').doc(userId).collection('products').doc(product.id);
      batch.set(ref, product.toMap());
    }

    // Sync Sales
    for (var sale in saleBox.values) {
      final ref = firestore!.collection('users').doc(userId).collection('sales').doc(sale.id);
      batch.set(ref, sale.toMap());
    }

    // Sync Expenses
    for (var expense in expenseBox.values) {
      final ref = firestore!.collection('users').doc(userId).collection('expenses').doc(expense.id);
      batch.set(ref, expense.toMap());
    }

    await batch.commit();
  }
}
