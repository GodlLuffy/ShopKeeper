import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shop_keeper_project/features/sales/presentation/bloc/sales_cubit.dart';
import 'package:shop_keeper_project/features/expenses/presentation/bloc/expenses_cubit.dart';
import 'package:shop_keeper_project/core/theme/app_theme.dart';
import 'package:shop_keeper_project/core/widgets/glass_card.dart';

class ProfitReportScreen extends StatelessWidget {
  const ProfitReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profit Report')),
      body: BlocBuilder<SalesCubit, SalesState>(
        builder: (context, salesState) {
          return BlocBuilder<ExpensesCubit, ExpensesState>(
            builder: (context, expState) {
              double totalSales = 0;
              double totalProfit = 0;
              double totalExpenses = 0;

              if (salesState is SalesLoaded) {
                totalSales = salesState.sales.fold(0, (sum, s) => sum + s.totalAmount);
                totalProfit = salesState.sales.fold(0, (sum, s) => sum + s.totalProfit);
              }
              if (expState is ExpensesLoaded) {
                totalExpenses = expState.expenses.fold(0, (sum, e) => sum + e.amount);
              }

              final netProfit = totalProfit - totalExpenses;

              return Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    GlassCard(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          children: [
                            Text('Net Monthly Profit', style: Theme.of(context).textTheme.titleLarge),
                            const SizedBox(height: 12),
                            Text(
                              '₹$netProfit',
                              style: TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                                color: netProfit >= 0 ? AppTheme.successColor : AppTheme.errorColor,
                              ),
                            ),
                            const SizedBox(height: 24),
                            const Divider(),
                            const SizedBox(height: 24),
                            _buildRow('Gross Sales', '₹$totalSales'),
                            _buildRow('Inventory Profit', '₹$totalProfit', color: AppTheme.primaryColor),
                            _buildRow('Shop Expenses', '₹$totalExpenses', color: AppTheme.errorColor),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'This report is based on all recorded transactions in the current local database.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 18)),
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}
