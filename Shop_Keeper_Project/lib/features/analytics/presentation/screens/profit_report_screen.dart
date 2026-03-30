import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shop_keeper_project/features/sales/presentation/bloc/sales_cubit.dart';
import 'package:shop_keeper_project/core/theme/app_theme.dart';
import 'package:shop_keeper_project/core/widgets/glass_card.dart';

class ProfitReportScreen extends StatefulWidget {
  const ProfitReportScreen({super.key});

  @override
  State<ProfitReportScreen> createState() => _ProfitReportScreenState();
}

class _ProfitReportScreenState extends State<ProfitReportScreen> {
  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    context.read<SalesCubit>().loadSalesByRange(DateTime(now.year, now.month, 1), now);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackgroundMain,
      appBar: AppBar(
        title: const Text('PROFIT REPORT', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 2)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        actions: [
          BlocBuilder<SalesCubit, SalesState>(
            builder: (context, state) {
              if (state is SalesLoaded && state.sales.isNotEmpty) {
                return IconButton(
                  icon: const Icon(Icons.share_rounded, color: AppTheme.accentTeal),
                  onPressed: () => _shareProfitReport(state.sales),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: BlocBuilder<SalesCubit, SalesState>(
        builder: (context, state) {
          if (state is SalesLoading) {
            return const Center(child: CircularProgressIndicator(color: AppTheme.primaryIndigo));
          }
          if (state is SalesLoaded && state.sales.isNotEmpty) {
            final sales = state.sales;
            final totalRevenue = sales.fold<double>(0, (sum, s) => sum + s.totalAmount);
            final totalProfit = sales.fold<double>(0, (sum, s) => sum + s.totalProfit);
            final totalCost = totalRevenue - totalProfit;
            final marginPct = totalRevenue > 0 ? (totalProfit / totalRevenue * 100) : 0.0;

            // Group by product for top-performers
            final Map<String, double> productProfits = {};
            for (final sale in sales) {
              productProfits[sale.productName] = (productProfits[sale.productName] ?? 0) + sale.totalProfit;
            }
            final sortedProducts = productProfits.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
            final top5 = sortedProducts.take(5).toList();

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Overview Cards
                  Row(
                    children: [
                      Expanded(child: _buildMetricCard('Total Revenue', '₹${totalRevenue.toStringAsFixed(0)}', AppTheme.primaryIndigo)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildMetricCard('Total Cost', '₹${totalCost.toStringAsFixed(0)}', AppTheme.dangerRose)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _buildMetricCard('Net Profit', '₹${totalProfit.toStringAsFixed(0)}', AppTheme.successEmerald)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildMetricCard('Margin', '${marginPct.toStringAsFixed(1)}%', AppTheme.accentTeal)),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Profit Pie Chart
                  const Text('COST vs PROFIT', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppTheme.accentTeal, letterSpacing: 1.5)),
                  const SizedBox(height: 16),
                  GlassCard(
                    padding: const EdgeInsets.all(20),
                    child: SizedBox(
                      height: 200,
                      child: PieChart(
                        PieChartData(
                          sectionsSpace: 4,
                          centerSpaceRadius: 50,
                          sections: [
                            PieChartSectionData(
                              value: totalCost,
                              color: AppTheme.dangerRose,
                              title: 'Cost\n${(totalCost / totalRevenue * 100).toStringAsFixed(0)}%',
                              titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.white),
                              radius: 50,
                            ),
                            PieChartSectionData(
                              value: totalProfit,
                              color: AppTheme.successEmerald,
                              title: 'Profit\n${marginPct.toStringAsFixed(0)}%',
                              titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.white),
                              radius: 50,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Top Products
                  const Text('TOP PROFIT PRODUCTS', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppTheme.accentTeal, letterSpacing: 1.5)),
                  const SizedBox(height: 16),
                  ...top5.asMap().entries.map((entry) {
                    final i = entry.key;
                    final prod = entry.value;
                    final barWidth = top5.isNotEmpty ? (prod.value / top5.first.value) : 0.0;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: GlassCard(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 24, height: 24,
                                      decoration: BoxDecoration(
                                        color: AppTheme.primaryIndigo.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Center(child: Text('#${i + 1}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppTheme.primaryIndigo))),
                                    ),
                                    const SizedBox(width: 10),
                                    Text(prod.key, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.textWhite)),
                                  ],
                                ),
                                Text('₹${prod.value.toStringAsFixed(0)}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.successEmerald)),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: barWidth,
                                minHeight: 4,
                                backgroundColor: Colors.white.withOpacity(0.05),
                                color: AppTheme.successEmerald,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 40),
                ],
              ),
            );
          }
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.pie_chart_rounded, size: 64, color: AppTheme.textMuted.withOpacity(0.2)),
                const SizedBox(height: 16),
                const Text('No data for reports.', style: TextStyle(color: AppTheme.textMuted)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMetricCard(String label, String value, Color color) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: color, letterSpacing: 1)),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white)),
        ],
      ),
    );
  }

  void _shareProfitReport(List<dynamic> sales) {
    final totalRevenue = sales.fold<double>(0, (sum, s) => sum + s.totalAmount);
    final totalProfit = sales.fold<double>(0, (sum, s) => sum + s.totalProfit);
    final margin = totalRevenue > 0 ? (totalProfit / totalRevenue * 100) : 0.0;

    // Group by product for top-performers in share report
    final Map<String, double> prodProfits = {};
    for (final sale in sales) {
      prodProfits[sale.productName] = (prodProfits[sale.productName] ?? 0) + sale.totalProfit;
    }
    final sorted = prodProfits.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final top3 = sorted.take(3).toList();

    final buffer = StringBuffer();
    buffer.writeln('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    buffer.writeln('      SHOPKEEPER PROFIT REPORT');
    buffer.writeln('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    buffer.writeln('Period: ${DateFormat('MMMM yyyy').format(DateTime.now())}');
    buffer.writeln('Generated: ${DateFormat('dd MMM, HH:mm').format(DateTime.now())}');
    buffer.writeln('');
    buffer.writeln('FINANCIAL SUMMARY:');
    buffer.writeln('Total Revenue: ₹${totalRevenue.toStringAsFixed(2)}');
    buffer.writeln('Total Cost:    ₹${(totalRevenue - totalProfit).toStringAsFixed(2)}');
    buffer.writeln('Net Profit:    ₹${totalProfit.toStringAsFixed(2)}');
    buffer.writeln('Profit Margin: ${margin.toStringAsFixed(1)}%');
    buffer.writeln('');
    if (top3.isNotEmpty) {
      buffer.writeln('TOP PERFORMING PRODUCTS:');
      for (var i = 0; i < top3.length; i++) {
        buffer.writeln('${i + 1}. ${top3[i].key}: ₹${top3[i].value.toStringAsFixed(2)}');
      }
      buffer.writeln('');
    }
    buffer.writeln('Total Transactions: ${sales.length}');
    buffer.writeln('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    buffer.writeln('Generated via ShopKeeper PRO OS');

    Share.share(buffer.toString(), subject: 'Profit Audit - ${DateFormat('MMM yyyy').format(DateTime.now())}');
  }
}
