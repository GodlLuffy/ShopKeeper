import 'package:hive/hive.dart';

part 'product_table.g.dart';

@HiveType(typeId: 0)
class ProductTable extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String category;

  @HiveField(3)
  final double buyPrice;

  @HiveField(4)
  final double sellPrice;

  @HiveField(5)
  late int stockQuantity;

  @HiveField(6)
  final int minStockAlert;

  @HiveField(7)
  final String userId;

  @HiveField(8)
  final DateTime createdAt;

  @HiveField(9)
  final bool isSynced;

  @HiveField(10)
  final String? imageUrl;

  @HiveField(11)
  final String? barcode;

  @HiveField(12)
  final DateTime? updatedAt;

  ProductTable({
    required this.id,
    required this.name,
    required this.category,
    required this.buyPrice,
    required this.sellPrice,
    required this.stockQuantity,
    required this.minStockAlert,
    required this.userId,
    required this.createdAt,
    this.updatedAt,
    this.isSynced = false,
    this.imageUrl,
    this.barcode,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'buyPrice': buyPrice,
      'sellPrice': sellPrice,
      'stockQuantity': stockQuantity,
      'minStockAlert': minStockAlert,
      'userId': userId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'imageUrl': imageUrl,
      'barcode': barcode,
    };
  }
}
