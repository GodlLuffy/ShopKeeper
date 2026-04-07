import 'package:equatable/equatable.dart';

class SalesSummary extends Equatable {
  final double totalRevenue;
  final double totalProfit;
  final int orderCount;

  const SalesSummary({
    required this.totalRevenue,
    required this.totalProfit,
    required this.orderCount,
  });

  @override
  List<Object?> get props => [totalRevenue, totalProfit, orderCount];

  double get averageOrderValue => orderCount > 0 ? totalRevenue / orderCount : 0.0;
  double get profitMargin => totalRevenue > 0 ? (totalProfit / totalRevenue) * 100 : 0.0;
}
