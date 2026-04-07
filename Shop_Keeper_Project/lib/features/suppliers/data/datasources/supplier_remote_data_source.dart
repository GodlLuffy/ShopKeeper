import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shop_keeper_project/database/tables/supplier_table.dart';
import 'package:shop_keeper_project/database/tables/supplier_transaction_table.dart';

abstract class SupplierRemoteDataSource {
  Future<void> uploadSupplier(SupplierTable supplier);
  Future<void> deleteSupplier(String id);
  Future<void> uploadTransaction(SupplierTransactionTable transaction);
}

class SupplierRemoteDataSourceImpl implements SupplierRemoteDataSource {
  final FirebaseFirestore? firestore;
  final FirebaseAuth? auth;

  SupplierRemoteDataSourceImpl({this.firestore, this.auth});

  @override
  Future<void> uploadSupplier(SupplierTable supplier) async {
    if (firestore == null) return;
    final user = auth?.currentUser;
    if (user == null) return;

    await firestore!
        .collection('users')
        .doc(user.uid)
        .collection('suppliers')
        .doc(supplier.id)
        .set(supplier.toMap(), SetOptions(merge: true));
  }

  @override
  Future<void> deleteSupplier(String id) async {
    if (firestore == null) return;
    final user = auth?.currentUser;
    if (user == null) return;

    await firestore!
        .collection('users')
        .doc(user.uid)
        .collection('suppliers')
        .doc(id)
        .delete();
  }

  @override
  Future<void> uploadTransaction(SupplierTransactionTable transaction) async {
    if (firestore == null) return;
    final user = auth?.currentUser;
    if (user == null) return;

    await firestore!
        .collection('users')
        .doc(user.uid)
        .collection('supplier_transactions')
        .doc(transaction.id)
        .set(transaction.toMap(), SetOptions(merge: true));
  }
}
