import 'package:equatable/equatable.dart';
import 'package:dartz/dartz.dart';
import 'package:shop_keeper_project/core/error/failures.dart';

class SaleEntity extends Equatable {
  final String id;
  final String productId;
  final String productName;
  final int quantitySold;
  final double salePrice;
  final double totalAmount;
  final double totalProfit;
  final DateTime date;
  final String userId;
  final DateTime? updatedAt;

  const SaleEntity({
    required this.id,
    required this.productId,
    required this.productName,
    required this.quantitySold,
    required this.salePrice,
    required this.totalAmount,
    required this.totalProfit,
    required this.date,
    required this.userId,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id, productId, productName, quantitySold, salePrice, totalAmount, totalProfit, date, userId, updatedAt
  ];

  SaleEntity copyWith({
    String? id,
    String? productId,
    String? productName,
    int? quantitySold,
    double? salePrice,
    double? totalAmount,
    double? totalProfit,
    DateTime? date,
    String? userId,
    DateTime? updatedAt,
  }) {
    return SaleEntity(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      quantitySold: quantitySold ?? this.quantitySold,
      salePrice: salePrice ?? this.salePrice,
      totalAmount: totalAmount ?? this.totalAmount,
      totalProfit: totalProfit ?? this.totalProfit,
      date: date ?? this.date,
      userId: userId ?? this.userId,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Either<Failure, bool> validate() {
    if (productId.isEmpty) return const Left(ValidationFailure('Product ID cannot be empty'));
    if (quantitySold <= 0) return const Left(ValidationFailure('Quantity sold must be greater than 0'));
    if (salePrice < 0) return const Left(ValidationFailure('Sale price cannot be negative'));
    if (totalAmount < 0) return const Left(ValidationFailure('Total amount cannot be negative'));
    if (userId.isEmpty || userId == 'unknown') return const Left(ValidationFailure('Invalid User ID'));
    return const Right(true);
  }
}
