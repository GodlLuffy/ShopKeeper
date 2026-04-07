import 'package:hive_flutter/hive_flutter.dart';
import 'package:shop_keeper_project/database/tables/supplier_table.dart';
import 'package:shop_keeper_project/database/tables/supplier_transaction_table.dart';
import 'package:shop_keeper_project/features/suppliers/domain/entities/supplier.dart' as entity;

abstract class SupplierLocalDataSource {
  Future<List<SupplierTable>> getSuppliers();
  Future<void> cacheSupplier(SupplierTable supplier);
  Future<void> deleteSupplier(String id);
  Future<List<SupplierTransactionTable>> getTransactions(String supplierId);
  Future<void> cacheTransaction(SupplierTransactionTable transaction);
}

class SupplierLocalDataSourceImpl implements SupplierLocalDataSource {
  final Box<SupplierTable> supplierBox;
  final Box<SupplierTransactionTable> transactionBox;

  SupplierLocalDataSourceImpl({
    required this.supplierBox,
    required this.transactionBox,
  });

  @override
  Future<List<SupplierTable>> getSuppliers() async {
    return supplierBox.values.toList();
  }

  @override
  Future<void> cacheSupplier(SupplierTable supplier) async {
    await supplierBox.put(supplier.id, supplier);
  }

  @override
  Future<void> deleteSupplier(String id) async {
    await supplierBox.delete(id);
    // Also cleanup transactions (optional, but good practice)
    final keysToDelete = transactionBox.keys.where((k) {
      final tx = transactionBox.get(k);
      return tx?.supplierId == id;
    }).toList();
    await transactionBox.deleteAll(keysToDelete);
  }

  @override
  Future<List<SupplierTransactionTable>> getTransactions(String supplierId) async {
    return transactionBox.values
        .where((tx) => tx.supplierId == supplierId)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  @override
  Future<void> cacheTransaction(SupplierTransactionTable transaction) async {
    await transactionBox.put(transaction.id, transaction);
  }
}
