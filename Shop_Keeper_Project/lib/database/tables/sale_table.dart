import 'package:hive/hive.dart';

part 'sale_table.g.dart';

@HiveType(typeId: 1)
class SaleTable extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String productId;

  @HiveField(2)
  final String productName;

  @HiveField(3)
  final int quantitySold;

  @HiveField(4)
  final double salePrice;

  @HiveField(5)
  final double totalAmount;

  @HiveField(6)
  final double totalProfit;

  @HiveField(7)
  final DateTime date;

  @HiveField(8)
  final String userId;

  @HiveField(9)
  final bool isSynced;

  SaleTable({
    required this.id,
    required this.productId,
    required this.productName,
    required this.quantitySold,
    required this.salePrice,
    required this.totalAmount,
    required this.totalProfit,
    required this.date,
    required this.userId,
    this.isSynced = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'productId': productId,
      'productName': productName,
      'quantitySold': quantitySold,
      'salePrice': salePrice,
      'totalAmount': totalAmount,
      'totalProfit': totalProfit,
      'date': date.toIso8601String(),
      'userId': userId,
    };
  }
}
