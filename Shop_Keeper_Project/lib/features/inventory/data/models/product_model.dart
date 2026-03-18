import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shop_keeper_project/features/inventory/domain/entities/product_entity.dart';
import 'package:shop_keeper_project/database/tables/product_table.dart';

class ProductModel extends ProductEntity {
  const ProductModel({
    required super.id,
    required super.name,
    required super.category,
    required super.buyPrice,
    required super.sellPrice,
    required super.stockQuantity,
    required super.minStockAlert,
    required super.userId,
    required super.createdAt,
    super.imageUrl,
    super.barcode,
  });

  factory ProductModel.fromTable(ProductTable table) {
    return ProductModel(
      id: table.id,
      name: table.name,
      category: table.category,
      buyPrice: table.buyPrice,
      sellPrice: table.sellPrice,
      stockQuantity: table.stockQuantity,
      minStockAlert: table.minStockAlert,
      userId: table.userId,
      createdAt: table.createdAt,
      imageUrl: table.imageUrl,
      barcode: table.barcode,
    );
  }

  ProductTable toTable({bool isSynced = false}) {
    return ProductTable(
      id: id,
      name: name,
      category: category,
      buyPrice: buyPrice,
      sellPrice: sellPrice,
      stockQuantity: stockQuantity,
      minStockAlert: minStockAlert,
      userId: userId,
      createdAt: createdAt,
      isSynced: isSynced,
      imageUrl: imageUrl,
      barcode: barcode,
    );
  }

  factory ProductModel.fromMap(Map<String, dynamic> map, String id) {
    return ProductModel(
      id: id,
      name: map['name'] ?? '',
      category: map['category'] ?? '',
      buyPrice: (map['buyPrice'] ?? 0).toDouble(),
      sellPrice: (map['sellPrice'] ?? 0).toDouble(),
      stockQuantity: map['stockQuantity'] ?? 0,
      minStockAlert: map['minStockAlert'] ?? 0,
      userId: map['userId'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      imageUrl: map['imageUrl'],
      barcode: map['barcode'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'category': category,
      'buyPrice': buyPrice,
      'sellPrice': sellPrice,
      'stockQuantity': stockQuantity,
      'minStockAlert': minStockAlert,
      'userId': userId,
      'createdAt': createdAt,
      'imageUrl': imageUrl,
      'barcode': barcode,
    };
  }
}
