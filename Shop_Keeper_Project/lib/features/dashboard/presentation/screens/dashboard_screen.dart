import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shop_keeper_project/features/sales/presentation/bloc/sales_cubit.dart';
import 'package:shop_keeper_project/features/expenses/presentation/bloc/expenses_cubit.dart';
import 'package:shop_keeper_project/features/inventory/presentation/bloc/inventory_cubit.dart';
import 'package:shop_keeper_project/core/theme/app_theme.dart';
import 'package:shop_keeper_project/features/sales/presentation/screens/add_sale_screen.dart';
import 'package:shop_keeper_project/features/inventory/presentation/screens/product_list_screen.dart';
import 'package:shop_keeper_project/features/expenses/presentation/screens/expense_list_screen.dart';
import 'package:shop_keeper_project/features/ai_assistant/presentation/screens/ai_assistant_screen.dart';
import 'package:shop_keeper_project/features/analytics/presentation/screens/analytics_screen.dart';

import 'package:shop_keeper_project/features/inventory/presentation/screens/low_stock_screen.dart';
import 'package:shop_keeper_project/features/settings/presentation/screens/settings_screen.dart';
import 'package:shop_keeper_project/features/analytics/presentation/screens/profit_report_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  void _refreshData() {
    context.read<SalesCubit>().loadTodaySales();
    context.read<ExpensesCubit>().loadTodayExpenses();
    context.read<InventoryCubit>().loadProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ShopKeeper Dashboard'),
        actions: [
          IconButton(icon: const Icon(Icons.settings), onPressed: () => _navigate(const SettingsScreen())),
          IconButton(icon: const Icon(Icons.refresh), onPressed: _refreshData),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigate(const AIAssistantScreen()),
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.assistant, color: Colors.white),
      ),
      body: RefreshIndicator(
        onRefresh: () async => _refreshData(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSummaryCard(),
              const SizedBox(height: 24),
              Text('Quick Actions', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 16),
              _buildQuickActions(),
              const SizedBox(height: 24),
              _buildStockAlerts(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    return BlocBuilder<SalesCubit, SalesState>(
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

            return InkWell(
              onTap: () => _navigate(const ProfitReportScreen()),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildStat('Total Sales', '₹$totalSales', Colors.blue),
                          _buildStat('Expenses', '₹$totalExpenses', AppTheme.errorColor),
                        ],
                      ),
                      const Divider(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildStat('Gross Profit', '₹$totalProfit', AppTheme.successColor),
                          _buildStat('Net Profit', '₹$netProfit', netProfit >= 0 ? AppTheme.primaryColor : AppTheme.errorColor, isLarge: true),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildStat(String label, String value, Color color, {bool isLarge = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
        Text(value, style: TextStyle(
          fontSize: isLarge ? 24 : 20, 
          fontWeight: FontWeight.bold, 
          color: color
        )),
      ],
    );
  }

  Widget _buildQuickActions() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildActionCard('New Sale', Icons.shopping_cart, AppTheme.primaryColor, () => _navigate(const AddSaleScreen())),
        _buildActionCard('Inventory', Icons.inventory_2, Colors.orange, () => _navigate(const ProductListScreen())),
        _buildActionCard('Expenses', Icons.payments, AppTheme.errorColor, () => _navigate(const ExpenseListScreen())),
        _buildActionCard('Reports', Icons.bar_chart, Colors.purple, () => _navigate(const AnalyticsScreen())),
      ],
    );
  }

  Widget _buildActionCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.5)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildStockAlerts() {
    return BlocBuilder<InventoryCubit, InventoryState>(
      builder: (context, state) {
        if (state is InventoryLoaded) {
          final lowStockItems = state.products.where((p) => p.stockQuantity <= p.minStockAlert).toList();
          if (lowStockItems.isEmpty) return const SizedBox();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              InkWell(
                onTap: () => _navigate(const LowStockScreen()),
                child: const Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: AppTheme.errorColor),
                    SizedBox(width: 8),
                    Text('Low Stock Alerts', style: TextStyle(color: AppTheme.errorColor, fontWeight: FontWeight.bold, fontSize: 18)),
                    Spacer(),
                    Icon(Icons.chevron_right, color: AppTheme.errorColor),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              ...lowStockItems.map((p) => Card(
                color: AppTheme.errorColor.withOpacity(0.05),
                child: ListTile(
                  title: Text(p.name),
                  subtitle: Text('Only ${p.stockQuantity} left! (Alert at ${p.minStockAlert})'),
                  trailing: TextButton(
                    onPressed: () => _navigate(const ProductListScreen()),
                    child: const Text('Update'),
                  ),
                ),
              )),
            ],
          );
        }
        return const SizedBox();
      },
    );
  }

  void _navigate(Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }
}
