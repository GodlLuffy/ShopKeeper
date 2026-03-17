import 'package:equatable/equatable.dart';

class ProductEntity extends Equatable {
  final String id;
  final String name;
  final String category;  
  final double buyPrice;
  final double sellPrice;
  final int stockQuantity;
  final int minStockAlert;
  final String userId;
  final DateTime createdAt;
  final String? imageUrl;

  const ProductEntity({
    required this.id,
    required this.name,
    required this.category,
    required this.buyPrice,
    required this.sellPrice,
    required this.stockQuantity,
    required this.minStockAlert,
    required this.userId,
    required this.createdAt,
    this.imageUrl,
  });

  @override
  List<Object?> get props => [
    id, name, category, buyPrice, sellPrice, stockQuantity, minStockAlert, userId, createdAt, imageUrl
  ];
}
