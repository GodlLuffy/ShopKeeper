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
  final String? imageUrl;
  final String? barcode;

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
    this.barcode,
  });

  @override
  List<Object?> get props => [
    id, name, category, buyPrice, sellPrice, stockQuantity, minStockAlert, userId, createdAt, imageUrl, barcode
  ];

  Either<Failure, bool> validate() {
    if (name.isEmpty) return const Left(ValidationFailure('Product name cannot be empty'));
    if (buyPrice < 0) return const Left(ValidationFailure('Buy price cannot be negative'));
    if (sellPrice < 0) return const Left(ValidationFailure('Sell price cannot be negative'));
    if (stockQuantity < 0) return const Left(ValidationFailure('Initial stock cannot be negative'));
    if (userId.isEmpty || userId == 'unknown') return const Left(ValidationFailure('Invalid User ID'));
    return const Right(true);
  }
}
