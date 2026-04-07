import 'package:flutter/material.dart';
import 'package:shop_keeper_project/core/widgets/premium_loader.dart';
import 'package:shop_keeper_project/core/localization/app_strings.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shop_keeper_project/features/dashboard/presentation/bloc/dashboard_cubit.dart';
import 'package:shop_keeper_project/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:shop_keeper_project/core/widgets/glass_card.dart';
import 'package:shop_keeper_project/core/theme/app_colors.dart';
import 'package:shop_keeper_project/core/theme/app_theme.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shop_keeper_project/features/billing/bloc/billing_bloc.dart';
import 'package:shop_keeper_project/features/billing/bloc/billing_state.dart';
import 'package:shop_keeper_project/features/inventory/presentation/bloc/inventory_cubit.dart';
import 'package:shop_keeper_project/features/customers/presentation/bloc/customer_cubit.dart';
import 'package:shop_keeper_project/features/suppliers/presentation/bloc/supplier_cubit.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    context.read<DashboardCubit>().loadDashboard();
    context.read<SupplierCubit>().loadSuppliers();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<BillingBloc, BillingState>(
          listener: (context, state) {
            if (state is BillGenerated) {
              context.read<DashboardCubit>().loadDashboard();
            }
          },
        ),
        BlocListener<InventoryCubit, InventoryState>(
          listener: (context, state) {
             context.read<DashboardCubit>().loadDashboard();
          },
        ),
      ],
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: BlocBuilder<DashboardCubit, DashboardState>(
          builder: (context, state) {
            if (state is DashboardLoading) {
              return const PremiumLoader(message: 'Loading Executive Data...');
            }

            final data = state is DashboardLoaded ? state : null;
            final authState = context.read<AuthCubit>().state;
            String shopName = 'SHOPKEEPER PRO';
            if (authState is Authenticated) {
              shopName = authState.user.shopName.isNotEmpty 
                  ? authState.user.shopName.toUpperCase() 
                  : authState.user.name.toUpperCase();
            }

            return RefreshIndicator(
              onRefresh: () async {
                await context.read<DashboardCubit>().loadDashboard();
                if (context.mounted) {
                  await context.read<CustomerCubit>().loadCustomers();
                  await context.read<SupplierCubit>().loadSuppliers();
                }
              },
              backgroundColor: AppColors.surface,
              color: AppColors.primary,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                slivers: [
                  _buildExecutiveHeader(context, shopName, data?.todayRevenue ?? 0),
                  SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 24),
                        _buildPremiumQuickActions(context).animate().fade().slideY(begin: 0.1),
                        const SizedBox(height: 32),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          child: Text(
                            AppStrings.get('financial_overview').toUpperCase(),
                            style: GoogleFonts.outfit(
                              fontSize: 14, 
                              fontWeight: FontWeight.w900, 
                              color: AppColors.textPrimary, 
                              letterSpacing: 2.0,
                            ),
                          ).animate().fade().slideX(begin: -0.1),
                        ),
                        const SizedBox(height: 16),
                        _buildLuxuryOverviewCards(context, data).animate().fade().slideY(begin: 0.1),

                        const SizedBox(height: 24),
                        _buildInventoryAlerts(context, data).animate().fade().slideY(begin: 0.1),
                        const SizedBox(height: 12),
                        _buildCreditAlerts(context).animate().fade().slideY(begin: 0.1),
                        const SizedBox(height: 12),
                        _buildSupplierAlerts(context).animate().fade().slideY(begin: 0.1),

                        const SizedBox(height: 48),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    AppStrings.get('smart_insights').toUpperCase(), 
                                    style: GoogleFonts.outfit(
                                      fontWeight: FontWeight.w900, 
                                      color: AppColors.textSecondary, 
                                      fontSize: 10, 
                                      letterSpacing: 1.5,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    AppStrings.get('business_health').toUpperCase(), 
                                    style: GoogleFonts.outfit(
                                      fontWeight: FontWeight.w900, 
                                      color: AppColors.textPrimary, 
                                      fontSize: 20,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.1), 
                                  borderRadius: BorderRadius.circular(20), 
                                  border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                                ),
                                child: Text(
                                  AppStrings.get('ai_powered').toUpperCase(), 
                                  style: const TextStyle(
                                    color: AppColors.primary, 
                                    fontSize: 9, 
                                    fontWeight: FontWeight.w900, 
                                    letterSpacing: 1,
                                  ),
                                ),
                              ),
                            ],
                          ).animate().fade().slideX(begin: -0.1),
                        ),
                        const SizedBox(height: 16),
                        _buildAIInsightsCards(context, data).animate().fade().slideY(begin: 0.1),

                        const SizedBox(height: 48),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          child: Text(
                            AppStrings.get('revenue_trend').toUpperCase(),
                            style: GoogleFonts.outfit(
                              fontSize: 14, 
                              fontWeight: FontWeight.w900, 
                              color: AppColors.textPrimary, 
                              letterSpacing: 2.0,
                            ),
                          ).animate().fade().slideX(begin: -0.1),
                        ),
                        const SizedBox(height: 16),
                        _buildLuxuryChart(context, data?.weeklyRevenueData).animate().fade().slideY(begin: 0.1),

                        const SizedBox(height: 60),
                        Center(
                          child: Text(
                            'DEVELOPED BY ANUP',
                            style: GoogleFonts.outfit(
                              fontSize: 9, 
                              fontWeight: FontWeight.w900, 
                              color: AppColors.textMuted.withOpacity(0.5), 
                              letterSpacing: 2,
                            ),
                          ),
                        ),
                        const SizedBox(height: 48),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildExecutiveHeader(BuildContext context, String shopName, double revenue) {
    return SliverAppBar(
      expandedHeight: 260,
      pinned: true,
      elevation: 0,
      stretch: true,
      backgroundColor: AppColors.background,
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [StretchMode.zoomBackground, StretchMode.blurBackground],
        background: Container(
          decoration: const BoxDecoration(
            color: AppColors.background,
          ),
          child: Stack(
            children: [
              // Subtle Glows
              Positioned(
                top: -100,
                right: -50,
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.08),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              gradient: AppColors.goldGradient,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(
                              LucideIcons.shoppingBag, 
                              size: 18, 
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              shopName, 
                              style: GoogleFonts.outfit(
                                fontSize: 13, 
                                color: AppColors.textPrimary, 
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),
                      Text(
                        AppStrings.get('todays_revenue').toUpperCase(), 
                        style: GoogleFonts.outfit(
                          fontSize: 11, 
                          color: AppColors.textSecondary, 
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2.0,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '₹',
                            style: GoogleFonts.outfit(
                              fontSize: 24, 
                              color: AppColors.primary, 
                              fontWeight: FontWeight.w600,
                              height: 1.6,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            NumberFormat('#,##,###').format(revenue),
                            style: GoogleFonts.outfit(
                              fontSize: 52, 
                              color: AppColors.textPrimary, 
                              fontWeight: FontWeight.w900, 
                              letterSpacing: -1.0,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: IconButton(
            onPressed: () => context.push('/settings'), 
            icon: const Icon(LucideIcons.settings, color: AppColors.textPrimary, size: 22),
          ),
        ),
      ],
    );
  }

  Widget _buildPremiumQuickActions(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Row(
        children: [
          _buildQuickActionItem(context, AppStrings.get('pos_billing'), LucideIcons.shoppingBag, AppColors.primary, () => context.push('/billing')),
          _buildQuickActionItem(context, AppStrings.get('inventory_label'), LucideIcons.package, AppColors.textSecondary, () => context.push('/inventory')),
          _buildQuickActionItem(context, AppStrings.get('customers_action'), LucideIcons.users, AppColors.textSecondary, () => context.push('/customers')),
          _buildQuickActionItem(context, AppStrings.get('expenses_action'), LucideIcons.wallet, AppColors.error, () => context.push('/expenses')),
          _buildQuickActionItem(context, 'SUPPLIERS', LucideIcons.truck, AppColors.textSecondary, () => context.push('/suppliers')),
          _buildQuickActionItem(context, AppStrings.get('ai_scanner'), LucideIcons.scan, AppColors.primary, () => context.push('/ai-assistant')),
        ],
      ),
    );
  }

  Widget _buildQuickActionItem(BuildContext context, String label, IconData icon, Color color, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 28.0),
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.glassBorder),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 10),
            Text(
              label.toUpperCase(), 
              style: GoogleFonts.outfit(
                fontSize: 9, 
                fontWeight: FontWeight.w900, 
                color: AppColors.textSecondary,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLuxuryOverviewCards(BuildContext context, DashboardLoaded? data) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildLuxuryStatCard(
                  label: AppStrings.get('todays_profit'),
                  value: '₹${(data?.todayProfit ?? 0).toInt()}',
                  icon: LucideIcons.trendingUp,
                  color: AppColors.success,
                  onTap: () => context.push('/profit-report'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildLuxuryStatCard(
                  label: AppStrings.get('monthly_revenue'),
                  value: '₹${(data?.monthlyRevenue ?? 0).toInt()}',
                  icon: LucideIcons.calendar,
                  color: AppColors.primary,
                  onTap: () => context.push('/analytics'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildLuxuryStatCard(
                  label: AppStrings.get('todays_expenses'),
                  value: '₹${(data?.todayExpenses ?? 0).toInt()}',
                  icon: LucideIcons.minusCircle,
                  color: AppColors.error,
                  onTap: () => context.push('/expenses'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildLuxuryStatCard(
                  label: AppStrings.get('net_profit_summary'),
                  value: '₹${(data?.todayNetProfit ?? 0).toInt()}',
                  icon: LucideIcons.award,
                  color: AppColors.success,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLuxuryStatCard({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: GlassCard(
        padding: const EdgeInsets.all(20),
        backgroundOpacity: 0.1,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color.withOpacity(0.8), size: 18),
                if (onTap != null)
                  const Icon(LucideIcons.arrowUpRight, color: AppColors.textSecondary, size: 14),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              label.toUpperCase(), 
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.w900, 
                color: AppColors.textSecondary, 
                fontSize: 9, 
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              value, 
              style: GoogleFonts.outfit(
                fontSize: 22, 
                fontWeight: FontWeight.w900, 
                color: AppColors.textPrimary, 
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInventoryAlerts(BuildContext context, DashboardLoaded? data) {
    if (data == null || (data.lowStockCount == 0 && data.outOfStockCount == 0)) return const SizedBox.shrink();
    return _buildLuxuryAlertTile(
      context: context,
      icon: LucideIcons.alertTriangle,
      title: 'STOCK ALERTS',
      subtitle: '${data.lowStockCount} low stock • ${data.outOfStockCount} out of stock',
      color: AppColors.error,
      onTap: () => context.push('/inventory'),
    );
  }

  Widget _buildCreditAlerts(BuildContext context) {
    return BlocBuilder<CustomerCubit, CustomerState>(
      builder: (context, state) {
        if (state is CustomerLoaded && state.totalOutstanding > 0) {
          return _buildLuxuryAlertTile(
            context: context,
            icon: LucideIcons.userX,
            title: 'CREDIT ALERTS',
            subtitle: '${state.customersWithCredit} customers • ₹${NumberFormat('#,##0').format(state.totalOutstanding)} outstanding',
            color: AppColors.error,
            onTap: () => context.push('/customers'),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildSupplierAlerts(BuildContext context) {
    return BlocBuilder<SupplierCubit, SupplierState>(
      builder: (context, state) {
        if (state is SupplierLoaded) {
          final totalDebt = state.suppliers.fold(0.0, (sum, s) => sum + s.balance);
          if (totalDebt > 0) {
            return _buildLuxuryAlertTile(
              context: context,
              icon: LucideIcons.truck,
              title: 'SUPPLIER ARREARS',
              subtitle: '₹${NumberFormat('#,##0').format(totalDebt)} total outstanding to suppliers',
              color: AppColors.textSecondary,
              onTap: () => context.push('/suppliers'),
            );
          }
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildLuxuryAlertTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: GestureDetector(
        onTap: onTap,
        child: GlassCard(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          backgroundOpacity: 0.05,
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1), 
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title.toUpperCase(), 
                      style: GoogleFonts.outfit(
                        fontSize: 10, 
                        fontWeight: FontWeight.w900, 
                        color: color, 
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: GoogleFonts.outfit(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
              const Icon(LucideIcons.chevronRight, color: AppColors.textSecondary, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAIInsightsCards(BuildContext context, DashboardLoaded? data) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: [
          if (data != null && data.lowStockCount > 0)
            _buildInsightTile(
              icon: LucideIcons.sparkles,
              title: AppStrings.get('restock_recommended').toUpperCase(),
              subtitle: '${data.lowStockCount} items require immediate inventory update.',
              actionLabel: 'RESTOCK',
              onAction: () => context.push('/inventory/restock'),
              isWarning: true,
            ),
          const SizedBox(height: 16),
          _buildInsightTile(
            icon: LucideIcons.barChart3,
            title: 'EXECUTIVE SUMMARY',
            subtitle: data != null
                ? '${data.monthlySaleCount} operations validated this month • ${data.totalProducts} units active.'
                : 'Aggregating metrics...',
          ),
        ],
      ),
    );
  }

  Widget _buildInsightTile({
    required IconData icon,
    required String title,
    required String subtitle,
    String? actionLabel,
    VoidCallback? onAction,
    bool isWarning = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isWarning ? AppColors.error.withOpacity(0.3) : AppColors.glassBorder,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: isWarning ? AppColors.error : AppColors.primary, size: 22),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title, 
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.w900, 
                    color: AppColors.textPrimary,
                    fontSize: 11,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle, 
                  style: GoogleFonts.outfit(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
                ),
              ],
            ),
          ),
          if (actionLabel != null)
            TextButton(
              onPressed: onAction,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                textStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1.0),
              ),
              child: Text(actionLabel),
            )
        ],
      ),
    ).animate().shimmer(delay: 2.seconds, duration: 2.seconds);
  }

  Widget _buildLuxuryChart(BuildContext context, List<double>? weeklyData) {
    final data = weeklyData ?? List.filled(7, 0.0);
    final maxY = data.fold<double>(0, (a, b) => a > b ? a : b);
    final chartMax = maxY > 0 ? maxY * 1.3 : 10000.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: GlassCard(
        padding: const EdgeInsets.fromLTRB(10, 24, 24, 16),
        backgroundOpacity: 0.05,
        child: SizedBox(
          height: 220,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: chartMax,
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  getTooltipColor: (_) => AppColors.surface,
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    return BarTooltipItem(
                      '₹${NumberFormat('#,###').format(rod.toY)}', 
                      GoogleFonts.outfit(color: AppColors.textPrimary, fontWeight: FontWeight.w900, fontSize: 12),
                    );
                  },
                ),
              ),
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      const days = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
                      final idx = value.toInt();
                      return SideTitleWidget(
                        axisSide: meta.axisSide,
                        space: 12,
                        child: Text(
                          idx < days.length ? days[idx] : '', 
                          style: GoogleFonts.outfit(color: AppColors.textSecondary, fontWeight: FontWeight.w900, fontSize: 9),
                        ),
                      );
                    },
                  ),
                ),
                leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              gridData: FlGridData(
                show: true, 
                drawVerticalLine: false,
                getDrawingHorizontalLine: (value) => FlLine(color: AppColors.glassBorder, strokeWidth: 1, dashArray: [5, 5]),
              ),
              borderData: FlBorderData(show: false),
              barGroups: List.generate(7, (i) => _makeLuxuryBarData(i, data[i], chartMax)),
            ),
          ),
        ),
      ),
    );
  }

  BarChartGroupData _makeLuxuryBarData(int x, double y, double max) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          gradient: AppColors.goldGradient,
          width: 18,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
          backDrawRodData: BackgroundBarChartRodData(
            show: true, 
            toY: max,
            color: AppColors.surface,
          ),
        ),
      ],
    );
  }
}

