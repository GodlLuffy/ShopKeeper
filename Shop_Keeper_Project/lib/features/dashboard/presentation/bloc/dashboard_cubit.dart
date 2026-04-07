import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shop_keeper_project/features/sales/domain/usecases/get_sales_by_range.dart';
import 'package:shop_keeper_project/features/expenses/domain/usecases/get_expenses_by_date.dart';
import 'package:shop_keeper_project/features/inventory/domain/usecases/get_products.dart';
import 'package:shop_keeper_project/core/usecases/usecase.dart';

part 'dashboard_state.dart';

class DashboardCubit extends Cubit<DashboardState> {
  final GetSalesByRange getSalesByRange;
  final GetExpensesByDate getExpensesByDate;
  final GetProducts getProducts;

  DashboardCubit({
    required this.getSalesByRange,
    required this.getExpensesByDate,
    required this.getProducts,
  }) : super(DashboardInitial());

  Future<void> loadDashboard() async {
    emit(DashboardLoading());

    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);
    final startOfMonth = DateTime(now.year, now.month, 1);
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));

    try {
      // Fetch today's sales
      double todayRevenue = 0, todayProfit = 0;
      int todaySaleCount = 0;
      final todayResult = await getSalesByRange(SalesRangeParams(start: startOfDay, end: endOfDay));
      todayResult.fold(
        (_) {},
        (sales) {
          todayRevenue = sales.fold(0.0, (sum, s) => sum + s.totalAmount);
          todayProfit = sales.fold(0.0, (sum, s) => sum + s.totalProfit);
          todaySaleCount = sales.length;
        },
      );

      // Fetch monthly sales
      double monthlyRevenue = 0, monthlyProfit = 0;
      int monthlySaleCount = 0;
      final monthResult = await getSalesByRange(SalesRangeParams(start: startOfMonth, end: endOfDay));
      monthResult.fold(
        (_) {},
        (sales) {
          monthlyRevenue = sales.fold(0.0, (sum, s) => sum + s.totalAmount);
          monthlyProfit = sales.fold(0.0, (sum, s) => sum + s.totalProfit);
          monthlySaleCount = sales.length;
        },
      );

      // Fetch weekly sales for chart
      List<double> weeklyData = List.filled(7, 0);
      final weekResult = await getSalesByRange(SalesRangeParams(
        start: DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day),
        end: endOfDay,
      ));
      weekResult.fold(
        (_) {},
        (sales) {
          for (final sale in sales) {
            final dayIndex = sale.date.weekday - 1; // Mon=0 ... Sun=6
            if (dayIndex >= 0 && dayIndex < 7) {
              weeklyData[dayIndex] += sale.totalAmount;
            }
          }
        },
      );

      // Fetch today's expenses
      double todayExpenses = 0;
      final expResult = await getExpensesByDate(now);
      expResult.fold(
        (_) {},
        (expenses) {
          todayExpenses = expenses.fold(0.0, (sum, e) => sum + e.amount);
        },
      );

      // Fetch inventory stats
      int totalProducts = 0, lowStockCount = 0, outOfStockCount = 0;
      final prodResult = await getProducts(NoParams());
      prodResult.fold(
        (_) {},
        (products) {
          totalProducts = products.length;
          lowStockCount = products.where((p) => p.stockQuantity > 0 && p.stockQuantity <= 5).length;
          outOfStockCount = products.where((p) => p.stockQuantity <= 0).length;
        },
      );

      emit(DashboardLoaded(
        todayRevenue: todayRevenue,
        todayProfit: todayProfit,
        todayExpenses: todayExpenses,
        todaySaleCount: todaySaleCount,
        monthlyRevenue: monthlyRevenue,
        monthlyProfit: monthlyProfit,
        monthlySaleCount: monthlySaleCount,
        weeklyRevenueData: weeklyData,
        totalProducts: totalProducts,
        lowStockCount: lowStockCount,
        outOfStockCount: outOfStockCount,
      ));
    } catch (e) {
      emit(DashboardError('Failed to load dashboard: $e'));
    }
  }
}
