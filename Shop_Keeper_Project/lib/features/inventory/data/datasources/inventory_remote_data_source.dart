import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shop_keeper_project/features/inventory/data/models/product_model.dart';

abstract class InventoryRemoteDataSource {
  Future<List<ProductModel>> getProducts(String userId);
  Future<void> saveProduct(ProductModel product);
  Future<void> deleteProduct(String id);
  Future<void> saveInventoryLog(Map<String, dynamic> logMap);
}

class InventoryRemoteDataSourceImpl implements InventoryRemoteDataSource {
  final FirebaseFirestore? firestore;

  InventoryRemoteDataSourceImpl({this.firestore});

  @override
  Future<List<ProductModel>> getProducts(String userId) async {
    if (firestore == null) return [];
    final snapshot = await firestore!
        .collection('products')
        .where('userId', isEqualTo: userId)
        .get();
    return snapshot.docs.map((doc) => ProductModel.fromMap(doc.data(), doc.id)).toList();
  }

  @override
  Future<void> saveProduct(ProductModel product) async {
    if (firestore == null) return;
    await firestore!.collection('products').doc(product.id).set(product.toMap());
  }

  @override
  Future<void> deleteProduct(String id) async {
    if (firestore == null) return;
    await firestore!.collection('products').doc(id).delete();
  }

  @override
  Future<void> saveInventoryLog(Map<String, dynamic> logMap) async {
    if (firestore == null) return;
    await firestore!.collection('inventoryLogs').add(logMap);
  }
}
