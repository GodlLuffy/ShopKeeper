part of 'dashboard_cubit.dart';

abstract class DashboardState extends Equatable {
  const DashboardState();
  @override
  List<Object?> get props => [];
}

class DashboardInitial extends DashboardState {}

class DashboardLoading extends DashboardState {}

class DashboardLoaded extends DashboardState {
  final double todayRevenue;
  final double todayProfit;
  final double todayExpenses;
  final int todaySaleCount;
  final double monthlyRevenue;
  final double monthlyProfit;
  final int monthlySaleCount;
  final List<double> weeklyRevenueData; // Mon–Sun
  final int totalProducts;
  final int lowStockCount;
  final int outOfStockCount;

  const DashboardLoaded({
    required this.todayRevenue,
    required this.todayProfit,
    required this.todayExpenses,
    required this.todaySaleCount,
    required this.monthlyRevenue,
    required this.monthlyProfit,
    required this.monthlySaleCount,
    required this.weeklyRevenueData,
    required this.totalProducts,
    required this.lowStockCount,
    required this.outOfStockCount,
  });

  double get todayNetProfit => todayProfit - todayExpenses;

  @override
  List<Object?> get props => [
    todayRevenue, todayProfit, todayExpenses, todaySaleCount,
    monthlyRevenue, monthlyProfit, monthlySaleCount,
    weeklyRevenueData, totalProducts, lowStockCount, outOfStockCount,
  ];
}

class DashboardError extends DashboardState {
  final String message;
  const DashboardError(this.message);
  @override
  List<Object?> get props => [message];
}
