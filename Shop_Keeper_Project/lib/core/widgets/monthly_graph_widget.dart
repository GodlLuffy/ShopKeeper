import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shop_keeper_project/core/theme/app_theme.dart';

class MonthlyGraphWidget extends StatelessWidget {
  final Map<String, int> productMovements;

  const MonthlyGraphWidget({super.key, required this.productMovements});

  @override
  Widget build(BuildContext context) {
    if (productMovements.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(child: Text('No stock data available for the graph')),
      );
    }

    final keys = productMovements.keys.toList();
    
    // Convert to BarChartGroupData
    List<BarChartGroupData> barGroups = [];
    for (int i = 0; i < keys.length; i++) {
      final value = productMovements[keys[i]]!.toDouble();
      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: value,
              color: value >= 0 ? AppTheme.successColor : AppTheme.errorColor,
              width: 16,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ),
      );
    }

    return SizedBox(
      height: 250,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: _getMaxY() + 10,
          minY: _getMinY() - 10,
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index >= 0 && index < keys.length) {
                    final name = keys[index];
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        name.length > 5 ? '${name.substring(0, 5)}..' : name,
                        style: const TextStyle(fontSize: 10, color: Color(0xFF64748B)),
                      ),
                    );
                  }
                  return const SizedBox();
                },
                reservedSize: 28,
              ),
            ),
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 20,
            getDrawingHorizontalLine: (value) {
              return const FlLine(
                color: Color(0xFFE2E8F0),
                strokeWidth: 1,
                dashArray: [5, 5],
              );
            },
          ),
          barGroups: barGroups,
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                return BarTooltipItem(
                  '${keys[group.x.toInt()]}\n${rod.toY.toInt()}',
                  const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  double _getMaxY() {
    if (productMovements.isEmpty) return 0;
    return productMovements.values.reduce((a, b) => a > b ? a : b).toDouble();
  }

  double _getMinY() {
    if (productMovements.isEmpty) return 0;
    // ensure min is 0 if all positive, else return actual minimum
    final trueMin = productMovements.values.reduce((a, b) => a < b ? a : b).toDouble();
    return trueMin < 0 ? trueMin : 0;
  }
}
