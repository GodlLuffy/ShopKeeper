import 'package:flutter/material.dart';
import 'package:shop_keeper_project/core/widgets/premium_loader.dart';
import 'package:shop_keeper_project/core/localization/app_strings.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shop_keeper_project/features/dashboard/presentation/bloc/dashboard_cubit.dart';
import 'package:shop_keeper_project/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:shop_keeper_project/core/widgets/glass_card.dart';
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
    final theme = Theme.of(context);

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
        backgroundColor: theme.scaffoldBackgroundColor,
        body: BlocBuilder<DashboardCubit, DashboardState>(
          builder: (context, state) {
            if (state is DashboardLoading) {
              return const PremiumLoader();
            }

            final data = state is DashboardLoaded ? state : null;
            final authState = context.read<AuthCubit>().state;
            String shopName = 'ShopKeeper';
            if (authState is Authenticated) {
              shopName = authState.user.shopName.isNotEmpty ? authState.user.shopName : authState.user.name;
            }

            return RefreshIndicator(
              onRefresh: () async {
                await context.read<DashboardCubit>().loadDashboard();
                if (context.mounted) {
                  await context.read<CustomerCubit>().loadCustomers();
                  await context.read<SupplierCubit>().loadSuppliers();
                }
              },
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                slivers: [
                  _buildSaaSHeader(context, shopName, data?.todayRevenue ?? 0),
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
                            AppStrings.get('financial_overview'),
                            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface, letterSpacing: -0.5),
                          ).animate().fade().slideX(begin: -0.1),
                        ),
                        const SizedBox(height: 16),
                        _buildGlassOverviewCards(context, data).animate().fade().slideY(begin: 0.1),

                        const SizedBox(height: 24),
                        _buildInventoryAlerts(context, data).animate().fade().slideY(begin: 0.1),
                        const SizedBox(height: 12),
                        _buildCreditAlerts(context).animate().fade().slideY(begin: 0.1),
                        const SizedBox(height: 12),
                        _buildSupplierAlerts(context).animate().fade().slideY(begin: 0.1),

                        const SizedBox(height: 32),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(AppStrings.get('smart_insights'), style: TextStyle(fontWeight: FontWeight.w900, color: theme.colorScheme.onSurfaceVariant, fontSize: 10, letterSpacing: 1.5)),
                                  const SizedBox(height: 4),
                                  Text(AppStrings.get('business_health'), style: TextStyle(fontWeight: FontWeight.w900, color: theme.colorScheme.onSurface, fontSize: 18)),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(color: AppTheme.accentTeal.withOpacity(0.1), borderRadius: BorderRadius.circular(20), border: Border.all(color: AppTheme.accentTeal.withOpacity(0.2))),
                                child: Text(AppStrings.get('ai_powered'), style: const TextStyle(color: AppTheme.accentTeal, fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: 1)),
                              ),
                            ],
                          ).animate().fade().slideX(begin: -0.1),
                        ),
                        const SizedBox(height: 16),
                        _buildAIInsightsCards(context, data).animate().fade().slideY(begin: 0.1),

                        const SizedBox(height: 32),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          child: Text(
                            AppStrings.get('revenue_trend'),
                            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface, letterSpacing: -0.5),
                          ).animate().fade().slideX(begin: -0.1),
                        ),
                        const SizedBox(height: 16),
                        _buildFlChartWeeklyTrend(context, data?.weeklyRevenueData).animate().fade().slideY(begin: 0.1),

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

  Widget _buildSaaSHeader(BuildContext context, String shopName, double revenue) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SliverAppBar(
      expandedHeight: 240,
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: isDark 
                ? const LinearGradient(
                    colors: [Color(0xFF030014), Color(0xFF0B0815)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  )
                : AppTheme.premiumGradient,
          ),
          child: SafeArea(
            bottom: false,
            child: Stack(
              children: [
                Positioned(
                  right: -50, top: -50,
                  child: Container(
                    width: 200, height: 200,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: AppTheme.primaryOrchid.withOpacity(isDark ? 0.1 : 0.05)),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(color: (isDark ? Colors.white : Colors.black).withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                            child: Icon(Icons.storefront, color: theme.colorScheme.onSurface),
                          ),
                          const SizedBox(width: 12),
                          Text(shopName, style: TextStyle(fontSize: 20, color: theme.colorScheme.onSurface, fontWeight: FontWeight.w600)),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Text(AppStrings.get('todays_revenue'), style: TextStyle(fontSize: 14, color: theme.colorScheme.onSurfaceVariant, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 4),
                      Text(
                        '₹${revenue.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 48, 
                          color: isDark ? AppTheme.softOrchidGlow : AppTheme.primaryOrchid, 
                          fontWeight: FontWeight.w900, 
                          letterSpacing: -2.5, 
                          shadows: [
                            Shadow(
                              color: isDark ? AppTheme.primaryOrchid.withOpacity(0.5) : Colors.black.withOpacity(0.1),
                              blurRadius: 30,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        IconButton(onPressed: () => context.push('/settings'), icon: Icon(Icons.settings, color: theme.colorScheme.onSurface)),
      ],
    );
  }

  Widget _buildPremiumQuickActions(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          _buildQuickAction(context, AppStrings.get('pos_billing'), Icons.point_of_sale_rounded, AppTheme.primaryIndigo, () => context.push('/billing')),
          const SizedBox(width: 24),
          _buildQuickAction(context, AppStrings.get('inventory_label'), Icons.inventory_2_outlined, AppTheme.accentTeal, () => context.push('/inventory')),
          const SizedBox(width: 24),
          _buildQuickAction(context, AppStrings.get('customers_action'), Icons.people_outline_rounded, AppTheme.successEmerald, () => context.push('/customers')),
          const SizedBox(width: 24),
          _buildQuickAction(context, AppStrings.get('expenses_action'), Icons.payments_outlined, AppTheme.dangerRose, () => context.push('/expenses')),
          const SizedBox(width: 24),
          _buildQuickAction(context, 'SUPPLIERS', LucideIcons.truck, AppTheme.primaryOrchid, () => context.push('/suppliers')),
          const SizedBox(width: 24),
          _buildQuickAction(context, AppStrings.get('ai_scanner'), Icons.qr_code_scanner_rounded, Colors.amber, () => context.push('/ai-assistant')),
        ],
      ),
    );
  }

  Widget _buildQuickAction(BuildContext context, String label, IconData icon, Color color, VoidCallback onTap) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
            child: Icon(icon, color: color),
          ),
          const SizedBox(height: 8),
          Text(label, style: TextStyle(fontSize: 10, color: theme.colorScheme.onSurface)),
        ],
      ),
    );
  }

  Widget _buildGlassOverviewCards(BuildContext context, DashboardLoaded? data) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => context.push('/profit-report'),
                  child: _buildStatCard(context, AppStrings.get('todays_profit'), '₹${(data?.todayProfit ?? 0).toStringAsFixed(0)}', Icons.trending_up_rounded, AppTheme.successEmerald),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () => context.push('/analytics'),
                  child: _buildStatCard(context, AppStrings.get('monthly_revenue'), '₹${(data?.monthlyRevenue ?? 0).toStringAsFixed(0)}', Icons.account_balance_wallet_rounded, AppTheme.primaryIndigo),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildStatCard(context, AppStrings.get('todays_expenses'), '₹${(data?.todayExpenses ?? 0).toStringAsFixed(0)}', Icons.money_off_rounded, AppTheme.dangerRose)),
              const SizedBox(width: 12),
              Expanded(child: _buildStatCard(context, AppStrings.get('net_profit_summary'), '₹${(data?.todayNetProfit ?? 0).toStringAsFixed(0)}', Icons.workspace_premium_rounded, AppTheme.accentTeal)),
            ],
          ),
        ],
      ),
    );
  }
  Widget _buildStatCard(BuildContext context, String label, String value, IconData icon, Color color) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppTheme.premiumShadow,
        border: Border.all(color: theme.colorScheme.primary.withOpacity(0.1)),
      ),
      child: GlassCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 12),
            Text(label, style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurfaceVariant, fontSize: 11, letterSpacing: 0.5)),
            const SizedBox(height: 4),
            Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: theme.colorScheme.onSurface, letterSpacing: -0.5)),
          ],
        ),
      ),
    );
  }

  Widget _buildInventoryAlerts(BuildContext context, DashboardLoaded? data) {
    final theme = Theme.of(context);
    if (data == null || (data.lowStockCount == 0 && data.outOfStockCount == 0)) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: GestureDetector(
        onTap: () => context.push('/inventory'),
        child: GlassCard(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: AppTheme.warningAmber.withOpacity(0.15), shape: BoxShape.circle),
                  child: const Icon(Icons.inventory_2_rounded, color: AppTheme.warningAmber, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(AppStrings.get('stock_alerts'), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppTheme.warningAmber, letterSpacing: 1)),
                      const SizedBox(height: 4),
                      Text(
                        '${data.lowStockCount} low stock • ${data.outOfStockCount} out of stock',
                        style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                const Text('VIEW', style: TextStyle(color: AppTheme.accentTeal, fontWeight: FontWeight.w800)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCreditAlerts(BuildContext context) {
    return BlocBuilder<CustomerCubit, CustomerState>(
      builder: (context, state) {
        if (state is CustomerLoaded && state.totalOutstanding > 0) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: GestureDetector(
              onTap: () => context.push('/customers'),
              child: GlassCard(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: AppTheme.dangerRose.withOpacity(0.15), shape: BoxShape.circle),
                        child: const Icon(Icons.account_balance_wallet_rounded, color: AppTheme.dangerRose, size: 22),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('CREDIT ALERTS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppTheme.dangerRose, letterSpacing: 1)),
                            const SizedBox(height: 4),
                            Text(
                              '${state.customersWithCredit} customers • ₹${NumberFormat('#,##0').format(state.totalOutstanding)} outstanding',
                              style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ),
                      const Text('VIEW', style: TextStyle(color: AppTheme.accentTeal, fontWeight: FontWeight.w800)),
                    ],
                  ),
                ),
              ),
            ),
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
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: GestureDetector(
                onTap: () => context.push('/suppliers'),
                child: GlassCard(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(color: AppTheme.primaryOrchid.withOpacity(0.15), shape: BoxShape.circle),
                          child: const Icon(LucideIcons.truck, color: AppTheme.primaryOrchid, size: 22),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('SUPPLIER DEBT', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppTheme.primaryOrchid, letterSpacing: 1)),
                              const SizedBox(height: 4),
                              Text(
                                '₹${NumberFormat('#,##0').format(totalDebt)} outstanding to suppliers',
                                style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.onSurfaceVariant),
                              ),
                            ],
                          ),
                        ),
                        const Text('VIEW', style: TextStyle(color: AppTheme.accentTeal, fontWeight: FontWeight.w800)),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildAIInsightsCards(BuildContext context, DashboardLoaded? data) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: [
          if (data != null && data.lowStockCount > 0)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.primaryIndigo.withOpacity(0.2), AppTheme.accentTeal.withOpacity(0.2)],
                  begin: Alignment.topLeft, end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.primaryIndigo.withOpacity(0.5)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_rounded, color: AppTheme.dangerRose),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(AppStrings.get('restock_recommended'), style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
                        Text('${data.lowStockCount} products running low on stock.', style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant)),
                      ],
                    ),
                  ),
                    TextButton(
                    onPressed: () => context.push('/inventory/restock'),
                    child: const Text('RESTOCK', style: TextStyle(color: AppTheme.accentTeal, fontWeight: FontWeight.bold)),
                  )
                ],
              ),
            ).animate().shimmer(delay: 1.seconds, duration: 2.seconds),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.accentTeal.withOpacity(0.1), AppTheme.primaryIndigo.withOpacity(0.1)],
                begin: Alignment.topLeft, end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.accentTeal.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.insights_rounded, color: AppTheme.accentTeal),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${AppStrings.get('business_health')} 🚀', style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
                      Text(
                        data != null
                            ? '${data.monthlySaleCount} sales this month • ${data.totalProducts} products'
                            : 'Loading insights...',
                        style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFlChartWeeklyTrend(BuildContext context, List<double>? weeklyData) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final data = weeklyData ?? List.filled(7, 0);
    final maxY = data.fold<double>(0, (a, b) => a > b ? a : b);
    final double chartMax = maxY > 0 ? maxY * 1.2 : 10000;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: GlassCard(
        padding: const EdgeInsets.all(20),
        child: SizedBox(
          height: 200,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: chartMax,
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  getTooltipColor: (_) => theme.colorScheme.surface,
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    return BarTooltipItem('₹${rod.toY.toStringAsFixed(0)}', TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.bold));
                  },
                ),
              ),
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                      final idx = value.toInt();
                      return SideTitleWidget(
                        axisSide: meta.axisSide,
                        child: Text(idx < days.length ? days[idx] : '', style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontWeight: FontWeight.w500, fontSize: 12)),
                      );
                    },
                  ),
                ),
                leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              gridData: FlGridData(
                show: true, drawVerticalLine: false,
                getDrawingHorizontalLine: (value) => FlLine(color: (isDark ? Colors.white : Colors.black).withOpacity(0.05), strokeWidth: 1),
              ),
              borderData: FlBorderData(show: false),
              barGroups: List.generate(7, (i) => _makeGroupData(context, i, data[i])),
            ),
          ),
        ),
      ),
    );
  }

  BarChartGroupData _makeGroupData(BuildContext context, int x, double y) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: AppTheme.primaryIndigo,
          width: 14,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
          backDrawRodData: BackgroundBarChartRodData(
            show: true, toY: 10000,
            color: (isDark ? Colors.white : Colors.black).withOpacity(0.02),
          ),
        ),
      ],
    );
  }
}
