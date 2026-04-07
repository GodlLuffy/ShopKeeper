import 'package:cloud_firestore/cloud_firestore.dart';

abstract class CustomerRemoteDataSource {
  Future<void> saveCustomer(Map<String, dynamic> data);
  Future<void> deleteCustomer(String id, String userId);
  Future<void> saveTransaction(Map<String, dynamic> data, String userId);
}

class CustomerRemoteDataSourceImpl implements CustomerRemoteDataSource {
  final FirebaseFirestore? firestore;

  CustomerRemoteDataSourceImpl({this.firestore});

  @override
  Future<void> saveCustomer(Map<String, dynamic> data) async {
    if (firestore == null) return;
    final userId = data['shopId'] as String;
    await firestore!
        .collection('users')
        .doc(userId)
        .collection('customers')
        .doc(data['id'])
        .set(data, SetOptions(merge: true));
  }

  @override
  Future<void> deleteCustomer(String id, String userId) async {
    if (firestore == null) return;
    await firestore!
        .collection('users')
        .doc(userId)
        .collection('customers')
        .doc(id)
        .delete();
  }

  @override
  Future<void> saveTransaction(Map<String, dynamic> data, String userId) async {
    if (firestore == null) return;
    await firestore!
        .collection('users')
        .doc(userId)
        .collection('credit_transactions')
        .doc(data['id'])
        .set(data, SetOptions(merge: true));
  }
}
