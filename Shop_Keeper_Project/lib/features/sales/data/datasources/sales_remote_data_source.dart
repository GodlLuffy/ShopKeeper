import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shop_keeper_project/features/sales/data/models/sale_model.dart';

abstract class SalesRemoteDataSource {
  Future<List<SaleModel>> getSalesByDate(String userId, DateTime date);
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
        .collection('sales')
        .where('userId', isEqualTo: userId)
        .where('date', isGreaterThanOrEqualTo: startOfDay)
        .where('date', isLessThanOrEqualTo: endOfDay)
        .get();
        
    return snapshot.docs.map((doc) => SaleModel.fromMap(doc.data(), doc.id)).toList();
  }

  @override
  Future<void> saveSale(SaleModel sale) async {
    if (firestore == null) return;
    await firestore!.collection('sales').doc(sale.id).set(sale.toMap());
  }
}
