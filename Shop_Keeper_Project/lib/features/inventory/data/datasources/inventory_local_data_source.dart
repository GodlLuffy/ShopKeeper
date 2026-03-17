import 'package:hive_flutter/hive_flutter.dart';
import 'package:shop_keeper_project/database/tables/product_table.dart';
import 'package:shop_keeper_project/database/tables/inventory_log_table.dart';

abstract class InventoryLocalDataSource {
  Future<List<ProductTable>> getProducts();
  Future<void> saveProduct(ProductTable product);
  Future<void> deleteProduct(String id);
  Future<void> saveInventoryLog(InventoryLogTable log);
}

class InventoryLocalDataSourceImpl implements InventoryLocalDataSource {
  final Box<ProductTable> productBox;
  final Box<InventoryLogTable> logBox;

  InventoryLocalDataSourceImpl({
    required this.productBox,
    required this.logBox,
  });

  @override
  Future<List<ProductTable>> getProducts() async {
    return productBox.values.toList();
  }

  @override
  Future<void> saveProduct(ProductTable product) async {
    await productBox.put(product.id, product);
  }

  @override
  Future<void> deleteProduct(String id) async {
    await productBox.delete(id);
  }

  @override
  Future<void> saveInventoryLog(InventoryLogTable log) async {
    await logBox.put(log.id, log);
  }
}
