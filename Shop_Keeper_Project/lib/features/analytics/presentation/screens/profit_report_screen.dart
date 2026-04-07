import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shop_keeper_project/features/sales/presentation/bloc/sales_cubit.dart';
import 'package:shop_keeper_project/core/theme/app_colors.dart';
import 'package:shop_keeper_project/core/theme/app_theme.dart';
import 'package:shop_keeper_project/core/widgets/glass_card.dart';
import 'package:shop_keeper_project/core/services/profit_pdf_service.dart';

class ProfitReportScreen extends StatefulWidget {
  const ProfitReportScreen({super.key});

  @override
  State<ProfitReportScreen> createState() => _ProfitReportScreenState();
}

class _ProfitReportScreenState extends State<ProfitReportScreen> {
  bool _isDaily = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final now = DateTime.now();
    if (_isDaily) {
      context.read<SalesCubit>().loadTodaySales();
    } else {
      context.read<SalesCubit>().loadSalesByRange(DateTime(now.year, now.month, 1), now);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackgroundMain,
      appBar: AppBar(
        title: Text(
          _isDaily ? "TODAY'S PROFIT" : 'MONTHLY PROFIT',
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 2),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        actions: [
          BlocBuilder<SalesCubit, SalesState>(
            builder: (context, state) {
              if (state is SalesLoaded && state.sales.isNotEmpty) {
                return Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.picture_as_pdf_rounded, color: AppColors.primaryIndigo),
                      onPressed: () => ProfitPdfService.generateProfitReport(
                        sales: state.sales,
                        date: DateTime.now(),
                        isDaily: _isDaily,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.share_rounded, color: AppColors.accentTeal),
                      onPressed: () => _shareProfitReport(state.sales),
                    ),
                  ],
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Period Toggle
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.darkBackgroundLayer,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
              ),
              child: Row(
                children: [
                  _buildToggleItem('DAILY AUDIT', _isDaily, () {
                    setState(() => _isDaily = true);
                    _loadData();
                  }),
                  _buildToggleItem('MONTHLY SUMMARY', !_isDaily, () {
                    setState(() => _isDaily = false);
                    _loadData();
                  }),
                ],
              ),
            ),
          ),
          Expanded(
            child: BlocBuilder<SalesCubit, SalesState>(
              builder: (context, state) {
                if (state is SalesLoading) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.primaryIndigo));
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
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: AppColors.darkBackgroundLayer,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: AppTheme.premiumShadow,
                                  border: Border.all(color: AppColors.primaryIndigo.withOpacity(0.1)),
                                ),
                                child: _buildMetricCard('Total Revenue', '₹${totalRevenue.toStringAsFixed(0)}', AppColors.primaryIndigo),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: AppColors.darkBackgroundLayer,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: AppTheme.premiumShadow,
                                  border: Border.all(color: AppColors.dangerRose.withOpacity(0.1)),
                                ),
                                child: _buildMetricCard('Total Cost', '₹${totalCost.toStringAsFixed(0)}', AppColors.dangerRose),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: AppColors.darkBackgroundLayer,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: AppTheme.premiumShadow,
                                  border: Border.all(color: AppColors.successEmerald.withOpacity(0.1)),
                                ),
                                child: _buildMetricCard('Net Profit', '₹${totalProfit.toStringAsFixed(0)}', AppColors.successEmerald),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: AppColors.darkBackgroundLayer,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: AppTheme.premiumShadow,
                                  border: Border.all(color: AppColors.accentTeal.withOpacity(0.1)),
                                ),
                                child: _buildMetricCard('Margin', '${marginPct.toStringAsFixed(1)}%', AppColors.accentTeal),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),

                        // Profit Pie Chart
                        const Text('COST vs PROFIT', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.accentTeal, letterSpacing: 1.5)),
                        const SizedBox(height: 16),
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.darkBackgroundLayer,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: AppTheme.premiumShadow,
                            border: Border.all(color: AppColors.accentTeal.withOpacity(0.1)),
                          ),
                          child: GlassCard(
                            padding: const EdgeInsets.all(24),
                            child: SizedBox(
                              height: 200,
                              child: PieChart(
                                PieChartData(
                                  sectionsSpace: 4,
                                  centerSpaceRadius: 50,
                                  sections: [
                                    PieChartSectionData(
                                      value: totalCost,
                                      color: AppColors.dangerRose,
                                      title: 'Cost\n${(totalCost / totalRevenue * 100).toStringAsFixed(0)}%',
                                      titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 0.5),
                                      radius: 50,
                                    ),
                                    PieChartSectionData(
                                      value: totalProfit,
                                      color: AppColors.successEmerald,
                                      title: 'Profit\n${marginPct.toStringAsFixed(0)}%',
                                      titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 0.5),
                                      radius: 50,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Top Products
                        const Text('TOP PROFIT PRODUCTS', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.accentTeal, letterSpacing: 1.5)),
                        const SizedBox(height: 16),
                        ...top5.asMap().entries.map((entry) {
                          final i = entry.key;
                          final prod = entry.value;
                          final barWidth = top5.isNotEmpty ? (prod.value / top5.first.value) : 0.0;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppColors.darkBackgroundLayer,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: AppTheme.premiumShadow,
                                border: Border.all(color: Colors.white.withOpacity(0.05)),
                              ),
                              child: GlassCard(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              width: 28, height: 28,
                                              decoration: BoxDecoration(
                                                color: AppColors.primaryIndigo.withOpacity(0.2),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Center(child: Text('#${i + 1}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: AppColors.primaryIndigo))),
                                            ),
                                            const SizedBox(width: 12),
                                            Text(prod.key, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textWhite)),
                                          ],
                                        ),
                                        Text('₹${prod.value.toStringAsFixed(0)}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: AppColors.successEmerald)),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(6),
                                      child: LinearProgressIndicator(
                                        value: barWidth,
                                        minHeight: 6,
                                        backgroundColor: Colors.white.withOpacity(0.05),
                                        color: AppColors.successEmerald,
                                      ),
                                    ),
                                  ],
                                ),
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
                      Icon(Icons.pie_chart_rounded, size: 64, color: AppColors.textMuted.withOpacity(0.2)),
                      const SizedBox(height: 16),
                      const Text('No data for reports.', style: TextStyle(color: AppColors.textMuted)),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleItem(String label, bool isActive, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? AppColors.primaryIndigo : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: isActive ? Colors.white : AppColors.textMuted,
                letterSpacing: 1,
              ),
            ),
          ),
        ),
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
