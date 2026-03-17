import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shop_keeper_project/features/expenses/presentation/bloc/expenses_cubit.dart';
import 'package:shop_keeper_project/core/theme/app_theme.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Shop Analytics')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Sales vs Expenses (Last 7 Days)'),
            const SizedBox(height: 16),
            SizedBox(
              height: 250,
              child: _buildLineChart(),
            ),
            const SizedBox(height: 32),
            _buildSectionTitle('Expense Breakdown'),
            const SizedBox(height: 16),
            SizedBox(
              height: 250,
              child: _buildPieChart(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
    );
  }

  Widget _buildLineChart() {
    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: [
              const FlSpot(0, 3),
              const FlSpot(1, 1),
              const FlSpot(2, 4),
              const FlSpot(3, 2),
              const FlSpot(4, 5),
              const FlSpot(5, 3),
              const FlSpot(6, 4),
            ],
            isCurved: true,
            color: AppTheme.primaryColor,
            barWidth: 4,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(show: true, color: AppTheme.primaryColor.withOpacity(0.1)),
          ),
          LineChartBarData(
            spots: [
              const FlSpot(0, 1),
              const FlSpot(1, 2),
              const FlSpot(2, 1.5),
              const FlSpot(3, 3),
              const FlSpot(4, 2),
              const FlSpot(5, 2.5),
              const FlSpot(6, 1),
            ],
            isCurved: true,
            color: AppTheme.errorColor,
            barWidth: 4,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(show: true, color: AppTheme.errorColor.withOpacity(0.05)),
          ),
        ],
      ),
    );
  }

  Widget _buildPieChart(BuildContext context) {
    return BlocBuilder<ExpensesCubit, ExpensesState>(
      builder: (context, state) {
        if (state is ExpensesLoaded) {
          final categories = <String, double>{};
          for (var e in state.expenses) {
            categories[e.category] = (categories[e.category] ?? 0) + e.amount;
          }

          if (categories.isEmpty) {
            return const Center(child: Text("No expenses to show."));
          }

          return PieChart(
            PieChartData(
              sections: categories.entries.map((entry) {
                return PieChartSectionData(
                  color: _getCategoryColor(entry.key),
                  value: entry.value,
                  title: entry.key,
                  radius: 50,
                  titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                );
              }).toList(),
            ),
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Rent/Bills': return Colors.blue;
      case 'Stock Purchase': return Colors.orange;
      case 'Staff Salary': return Colors.purple;
      default: return Colors.grey;
    }
  }
}
