import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shop_keeper_project/features/sales/data/models/sale_model.dart';

abstract class SalesRemoteDataSource {
  Future<List<SaleModel>> getSalesByDate(String userId, DateTime date);
  Future<List<SaleModel>> getSalesByRange(String userId, DateTime start, DateTime end);
  Future<void> saveSale(SaleModel sale);
}

class SalesRemoteDataSourceImpl implements SalesRemoteDataSource {
  final FirebaseFirestore? firestore;

  SalesRemoteDataSourceImpl({this.firestore});

  @override
  Future<List<SaleModel>> getSalesByDate(String userId, DateTime date) async {
    if (firestore == null) return [];
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

    final snapshot = await firestore!
        .collection('users')
        .doc(userId)
        .collection('sales')
        .where('date', isGreaterThanOrEqualTo: startOfDay)
        .where('date', isLessThanOrEqualTo: endOfDay)
        .get();
        
    return snapshot.docs.map((doc) => SaleModel.fromMap(doc.data(), doc.id)).toList();
  }

  @override
  Future<List<SaleModel>> getSalesByRange(String userId, DateTime start, DateTime end) async {
    if (firestore == null) return [];
    final snapshot = await firestore!
        .collection('users')
        .doc(userId)
        .collection('sales')
        .where('date', isGreaterThanOrEqualTo: start)
        .where('date', isLessThanOrEqualTo: end)
        .get();
    return snapshot.docs.map((doc) => SaleModel.fromMap(doc.data(), doc.id)).toList();
  }

  @override
  Future<void> saveSale(SaleModel sale) async {
    if (firestore == null) return;
    await firestore!
        .collection('users')
        .doc(sale.userId)
        .collection('sales')
        .doc(sale.id)
        .set(sale.toMap());
  }
}
