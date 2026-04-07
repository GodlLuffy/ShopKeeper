import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shop_keeper_project/features/sales/presentation/bloc/sales_cubit.dart';
import 'package:shop_keeper_project/features/sales/domain/entities/sale_entity.dart';
import 'package:shop_keeper_project/core/theme/app_colors.dart';
import 'package:shop_keeper_project/core/theme/app_theme.dart';
import 'package:shop_keeper_project/core/widgets/glass_card.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:shop_keeper_project/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:shop_keeper_project/core/utils/statement_pdf_renderer.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  late DateTime _startDate;
  late DateTime _endDate;
  String _selectedRange = 'This Month';

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _startDate = DateTime(now.year, now.month, 1);
    _endDate = now;
    _loadData();
  }

  void _loadData() {
    context.read<SalesCubit>().loadSalesByRange(_startDate, _endDate);
  }

  void _selectPreset(String preset) {
    final now = DateTime.now();
    setState(() {
      _selectedRange = preset;
      switch (preset) {
        case 'Today':
          _startDate = DateTime(now.year, now.month, now.day);
          _endDate = now;
          break;
        case 'This Week':
          _startDate = now.subtract(Duration(days: now.weekday - 1));
          _endDate = now;
          break;
        case 'This Month':
          _startDate = DateTime(now.year, now.month, 1);
          _endDate = now;
          break;
        case 'Last 3 Months':
          _startDate = DateTime(now.year, now.month - 2, 1);
          _endDate = now;
          break;
        case 'Custom':
          _showCustomDatePicker();
          return;
      }
    });
    _loadData();
  }

  Future<void> _showCustomDatePicker() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
      currentDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primaryIndigo,
              onPrimary: Colors.white,
              surface: AppColors.darkBackgroundLayer,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
        _selectedRange = 'Custom';
      });
      _loadData();
    }
  }

  void _downloadStatementPDF(List<SaleEntity> sales) {
    final authState = context.read<AuthCubit>().state;
    String shopName = 'ShopKeeper PRO';
    if (authState is Authenticated) {
      shopName = authState.user.shopName.isNotEmpty 
          ? authState.user.shopName 
          : authState.user.name;
    }

    StatementPdfRenderer.shareStatement(
      sales: sales,
      startDate: _startDate,
      endDate: _endDate,
      shopName: shopName,
      periodName: _selectedRange,
    );
  }

  void _exportToCSV(List<SaleEntity> sales) {
    final buffer = StringBuffer();
    buffer.writeln('Date,Product,Quantity,Price,Total,Profit');
    for (final sale in sales) {
      buffer.writeln(
        '${DateFormat('yyyy-MM-dd').format(sale.date)},${sale.productName},${sale.quantitySold},${sale.salePrice},${sale.totalAmount},${sale.totalProfit}',
      );
    }

    final totalRevenue = sales.fold<double>(0, (sum, s) => sum + s.totalAmount);
    final totalProfit = sales.fold<double>(0, (sum, s) => sum + s.totalProfit);
    buffer.writeln('');
    buffer.writeln('Total,,,,${totalRevenue.toStringAsFixed(2)},${totalProfit.toStringAsFixed(2)}');

    Share.share(
      buffer.toString(),
      subject: 'ShopKeeper Sales Report (${DateFormat('dd MMM').format(_startDate)} - ${DateFormat('dd MMM yyyy').format(_endDate)})',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackgroundMain,
      appBar: AppBar(
        title: const Text('RETAIL ANALYTICS', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 2)),
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
                      icon: const Icon(Icons.picture_as_pdf_outlined, color: AppColors.accentTeal),
                      tooltip: 'Download PDF Statement',
                      onPressed: () => _downloadStatementPDF(state.sales),
                    ),
                    IconButton(
                      icon: const Icon(Icons.share_outlined, color: AppColors.textMuted),
                      tooltip: 'Export CSV',
                      onPressed: () => _exportToCSV(state.sales),
                    ),
                    const SizedBox(width: 8),
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
          // Date Range Filter
          _buildDateFilters().animate().fadeIn(duration: 300.ms),
          const SizedBox(height: 8),
          // Date Range Display
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                const Icon(Icons.date_range_rounded, color: AppColors.textMuted, size: 16),
                const SizedBox(width: 8),
                Text(
                  '${DateFormat('dd MMM yyyy').format(_startDate)} — ${DateFormat('dd MMM yyyy').format(_endDate)}',
                  style: const TextStyle(color: AppColors.textMuted, fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: BlocBuilder<SalesCubit, SalesState>(
              builder: (context, state) {
                if (state is SalesLoading) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.primaryIndigo));
                }
                if (state is SalesLoaded) {
                  final sales = state.sales;
                  if (sales.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.bar_chart_rounded, size: 64, color: AppColors.textMuted.withOpacity(0.2)),
                          const SizedBox(height: 16),
                          const Text('No data for this period.', style: TextStyle(color: AppColors.textMuted)),
                        ],
                      ),
                    );
                  }

                  final totalRevenue = sales.fold<double>(0, (sum, s) => sum + s.totalAmount);
                  final totalProfit = sales.fold<double>(0, (sum, s) => sum + s.totalProfit);

                  return Container(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: Alignment.topRight, radius: 1.5,
                        colors: [AppColors.primaryIndigo.withOpacity(0.05), Colors.transparent],
                      ),
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Summary Cards
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
                                  child: _buildMiniStat('REVENUE', '₹${totalRevenue.toStringAsFixed(0)}', AppColors.primaryIndigo),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: AppColors.darkBackgroundLayer,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: AppTheme.premiumShadow,
                                    border: Border.all(color: AppColors.successEmerald.withOpacity(0.1)),
                                  ),
                                  child: _buildMiniStat('PROFIT', '₹${totalProfit.toStringAsFixed(0)}', AppColors.successEmerald),
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
                                  child: _buildMiniStat('SALES', '${sales.length}', AppColors.accentTeal),
                                ),
                              ),
                            ],
                          ).animate().fadeIn(duration: 400.ms),
                          const SizedBox(height: 24),

                          _buildChartSection(
                            title: 'SALES PERFORMANCE',
                            subtitle: 'Daily revenue trends',
                            chartData: _getChartData(sales, (s) => s.totalAmount),
                            color: AppColors.primaryIndigo,
                          ).animate().fadeIn(duration: 400.ms, delay: 100.ms),
                          const SizedBox(height: 24),
                          _buildChartSection(
                            title: 'PROFIT MARGINS',
                            subtitle: 'Daily net gains',
                            chartData: _getChartData(sales, (s) => s.totalProfit),
                            color: AppColors.successEmerald,
                          ).animate().fadeIn(duration: 400.ms, delay: 200.ms),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  );
                }
                return const SizedBox();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: ['Today', 'This Week', 'This Month', 'Last 3 Months', 'Custom'].map((preset) {
          final isSelected = _selectedRange == preset;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => _selectPreset(preset),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primaryIndigo : Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? AppColors.primaryIndigo : Colors.white.withOpacity(0.1),
                  ),
                ),
                child: Text(
                  preset,
                  style: TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w700,
                    color: isSelected ? Colors.white : AppColors.textMuted,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMiniStat(String label, String value, Color color) {
    return GlassCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: color, letterSpacing: 1)),
          const SizedBox(height: 6),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildChartSection({
    required String title,
    required String subtitle,
    required List<FlSpot> chartData,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.accentTeal, letterSpacing: 1.5)),
              const SizedBox(height: 4),
              Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.darkBackgroundLayer,
            borderRadius: BorderRadius.circular(24),
            boxShadow: AppTheme.premiumShadow,
            border: Border.all(color: color.withOpacity(0.1)),
          ),
          child: GlassCard(
            padding: const EdgeInsets.fromLTRB(8, 24, 16, 16),
            child: AspectRatio(
              aspectRatio: 1.6,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true, drawVerticalLine: false,
                    getDrawingHorizontalLine: (value) => FlLine(color: Colors.white.withOpacity(0.03), strokeWidth: 1),
                  ),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true, reservedSize: 30, interval: 5,
                        getTitlesWidget: (value, meta) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              value.toInt().toString(),
                              style: TextStyle(fontSize: 10, color: AppColors.textMuted.withOpacity(0.7), fontWeight: FontWeight.bold),
                            ),
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
                      gradient: LinearGradient(colors: [color, color.withOpacity(0.5)]),
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                          radius: 3, color: color, strokeWidth: 2, strokeColor: AppColors.darkBackgroundLayer,
                        ),
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          begin: Alignment.topCenter, end: Alignment.bottomCenter,
                          colors: [color.withOpacity(0.15), color.withOpacity(0.0)],
                        ),
                      ),
                    ),
                  ],
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipColor: (_) => AppColors.darkBackgroundLayer.withOpacity(0.8),
                      tooltipRoundedRadius: 12,
                      getTooltipItems: (touchedSpots) {
                        return touchedSpots.map((spot) {
                          return LineTooltipItem('₹${spot.y.toStringAsFixed(0)}', const TextStyle(color: Colors.white, fontWeight: FontWeight.bold));
                        }).toList();
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  List<FlSpot> _getChartData(List<dynamic> sales, double Function(dynamic) getValue) {
    final Map<int, double> groupedData = {};
    for (var sale in sales) {
      final day = sale.date.day;
      groupedData[day] = (groupedData[day] ?? 0) + getValue(sale);
    }

    final List<FlSpot> spots = [];
    final sortedDays = groupedData.keys.toList()..sort();
    for (final day in sortedDays) {
      spots.add(FlSpot(day.toDouble(), groupedData[day]!));
    }
    return spots.isEmpty ? [const FlSpot(0, 0)] : spots;
  }
}
