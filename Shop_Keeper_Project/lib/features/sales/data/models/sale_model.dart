import 'package:shop_keeper_project/features/sales/domain/entities/sale_entity.dart';
import 'package:shop_keeper_project/database/tables/sale_table.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SaleModel extends SaleEntity {
  const SaleModel({
    required super.id,
    required super.productId,
    required super.productName,
    required super.quantitySold,
    required super.salePrice,
    required super.totalAmount,
    required super.totalProfit,
    required super.date,
    required super.userId,
  });

  factory SaleModel.fromTable(SaleTable table) {
    return SaleModel(
      id: table.id,
      productId: table.productId,
      productName: table.productName,
      quantitySold: table.quantitySold,
      salePrice: table.salePrice,
      totalAmount: table.totalAmount,
      totalProfit: table.totalProfit,
      date: table.date,
      userId: table.userId,
    );
  }

  SaleTable toTable({bool isSynced = false}) {
    return SaleTable(
      id: id,
      productId: productId,
      productName: productName,
      quantitySold: quantitySold,
      salePrice: salePrice,
      totalAmount: totalAmount,
      totalProfit: totalProfit,
      date: date,
      userId: userId,
      isSynced: isSynced,
    );
  }

  factory SaleModel.fromMap(Map<String, dynamic> map, String id) {
    return SaleModel(
      id: id,
      productId: map['productId'] ?? '',
      productName: map['productName'] ?? '',
      quantitySold: map['quantitySold'] ?? 0,
      salePrice: (map['salePrice'] ?? 0).toDouble(),
      totalAmount: (map['totalAmount'] ?? 0).toDouble(),
      totalProfit: (map['totalProfit'] ?? 0).toDouble(),
      date: (map['date'] as Timestamp).toDate(),
      userId: map['userId'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productName': productName,
      'quantitySold': quantitySold,
      'salePrice': salePrice,
      'totalAmount': totalAmount,
      'totalProfit': totalProfit,
      'date': date,
      'userId': userId,
    };
  }
}
