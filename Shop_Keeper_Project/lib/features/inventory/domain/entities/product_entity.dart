import 'package:equatable/equatable.dart';
import 'package:dartz/dartz.dart';
import 'package:shop_keeper_project/core/error/failures.dart';

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
  final DateTime? updatedAt;
  final String? imageUrl;
  final String? barcode;

  bool get isLowStock => stockQuantity <= minStockAlert;

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
    this.updatedAt,
    this.imageUrl,
    this.barcode,
  });

  @override
  List<Object?> get props => [
    id, name, category, buyPrice, sellPrice, stockQuantity, minStockAlert, userId, createdAt, updatedAt, imageUrl, barcode
  ];

  ProductEntity copyWith({
    String? id,
    String? name,
    String? category,
    double? buyPrice,
    double? sellPrice,
    int? stockQuantity,
    int? minStockAlert,
    String? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? imageUrl,
    String? barcode,
  }) {
    return ProductEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      buyPrice: buyPrice ?? this.buyPrice,
      sellPrice: sellPrice ?? this.sellPrice,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      minStockAlert: minStockAlert ?? this.minStockAlert,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      imageUrl: imageUrl ?? this.imageUrl,
      barcode: barcode ?? this.barcode,
    );
  }

  Either<Failure, bool> validate() {
    if (name.isEmpty) return const Left(ValidationFailure('Product name cannot be empty'));
    if (buyPrice < 0) return const Left(ValidationFailure('Buy price cannot be negative'));
    if (sellPrice < 0) return const Left(ValidationFailure('Sell price cannot be negative'));
    if (stockQuantity < 0) return const Left(ValidationFailure('Initial stock cannot be negative'));
    if (userId.isEmpty || userId == 'unknown') return const Left(ValidationFailure('Invalid User ID'));
    return const Right(true);
  }
}
