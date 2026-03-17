import 'package:equatable/equatable.dart';

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
  });

  @override
  List<Object?> get props => [
    id, productId, productName, quantitySold, salePrice, totalAmount, totalProfit, date, userId
  ];
}
