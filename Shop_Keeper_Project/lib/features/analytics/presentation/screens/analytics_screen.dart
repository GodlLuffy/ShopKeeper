import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:shop_keeper_project/features/sales/presentation/bloc/sales_cubit.dart';
import 'package:shop_keeper_project/core/theme/app_theme.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    context.read<SalesCubit>().loadSalesByRange(startOfMonth, now);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Monthly Analytics')),
      body: BlocBuilder<SalesCubit, SalesState>(
        builder: (context, state) {
          if (state is SalesLoading) return const Center(child: CircularProgressIndicator());
          if (state is SalesLoaded) {
            final sales = state.sales;
            if (sales.isEmpty) return const Center(child: Text('Not enough data for charts yet.'));

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                   _buildChartSection(
                    title: 'Sales Trend (Monthly)',
                    chartData: _getChartData(sales, (s) => s.totalAmount),
                    color: AppTheme.primaryColor,
                    yAxisLabel: '₹',
                  ),
                  const SizedBox(height: 32),
                  _buildChartSection(
                    title: 'Profit Trend (Monthly)',
                    chartData: _getChartData(sales, (s) => s.totalProfit),
                    color: AppTheme.successColor,
                    yAxisLabel: '₹',
                  ),
                ],
              ),
            );
          }
          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildChartSection({
    required String title,
    required List<FlSpot> chartData,
    required Color color,
    required String yAxisLabel,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        AspectRatio(
          aspectRatio: 1.7,
          child: LineChart(
            LineChartData(
              gridData: const FlGridData(show: false),
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        DateFormat('dd').format(DateTime.now().subtract(Duration(days: 30 - value.toInt()))),
                        style: const TextStyle(fontSize: 10),
                      );
                    },
                  ),
                ),
                leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(show: false),
              lineBarsData: [
                LineChartBarData(
                  spots: chartData,
                  isCurved: true,
                  color: color,
                  barWidth: 4,
                  isStrokeCapRound: true,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    color: color.withOpacity(0.1),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  List<FlSpot> _getChartData(List<dynamic> sales, double Function(dynamic) getValue) {
    // Group sales by day and convert to FlSpot
    final Map<int, double> groupedData = {};
    for (var sale in sales) {
      final day = sale.date.day;
      groupedData[day] = (groupedData[day] ?? 0) + getValue(sale);
    }

    final List<FlSpot> spots = [];
    final now = DateTime.now();
    for (int i = 1; i <= now.day; i++) {
       spots.add(FlSpot(i.toDouble(), groupedData[i] ?? 0));
    }
    return spots;
  }
}
