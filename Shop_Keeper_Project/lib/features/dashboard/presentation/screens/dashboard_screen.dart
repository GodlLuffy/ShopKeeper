import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shop_keeper_project/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:shop_keeper_project/features/sales/presentation/bloc/sales_cubit.dart';
import 'package:shop_keeper_project/features/expenses/presentation/bloc/expenses_cubit.dart';
import 'package:shop_keeper_project/core/theme/app_theme.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    context.read<SalesCubit>().loadTodaySales();
    context.read<ExpensesCubit>().loadTodayExpenses();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Shop Dashboard'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => context.read<AuthCubit>().logout(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _buildCard(
                  title: 'Sales',
                  valueWidget: BlocBuilder<SalesCubit, SalesState>(
                    builder: (context, state) {
                      if (state is SalesLoaded) {
                        final total = state.sales.fold(0.0, (sum, item) => sum + item.totalAmount);
                        return Text('₹$total',
                            style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold));
                      }
                      return const Text('₹0',
                          style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold));
                    },
                  ),
                  icon: Icons.bar_chart,
                  color: Colors.blue,
                  onTap: () => context.push('/sales'),
                ),
                _buildCard(
                  title: 'Profit',
                  valueWidget: BlocBuilder<SalesCubit, SalesState>(
                    builder: (context, state) {
                      if (state is SalesLoaded) {
                        final total = state.sales.fold(0.0, (sum, item) => sum + item.totalProfit);
                        return Text('₹$total',
                            style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold));
                      }
                      return const Text('₹0',
                          style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold));
                    },
                  ),
                  icon: Icons.trending_up,
                  color: AppTheme.successColor,
                  onTap: () => context.push('/analytics'),
                ),
                _buildCard(
                  title: 'Expenses',
                  valueWidget: BlocBuilder<ExpensesCubit, ExpensesState>(
                    builder: (context, state) {
                      if (state is ExpensesLoaded) {
                        final total = state.expenses.fold(0.0, (sum, item) => sum + item.amount);
                        return Text('₹$total',
                            style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold));
                      }
                      return const Text('₹0',
                          style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold));
                    },
                  ),
                  icon: Icons.money_off,
                  color: AppTheme.errorColor,
                  onTap: () => context.push('/expenses'),
                ),
                _buildCard(
                  title: 'Stock Alert',
                  valueWidget: const Text('Manage',
                      style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                  icon: Icons.warning,
                  color: AppTheme.accentColor,
                  onTap: () => context.push('/inventory'),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _actionButton("Sale", Icons.add, () => context.push('/sales/add')),
                _actionButton("Product", Icons.inventory_2, () => context.push('/inventory/add')),
                _actionButton("Expense", Icons.money, () => context.push('/expenses/add')),
                _actionButton("AI Assist", Icons.psychology, () => context.push('/ai-assistant')),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required Widget valueWidget,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, 5),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 32),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(color: Colors.white, fontSize: 16)),
            const SizedBox(height: 4),
            valueWidget,
          ],
        ),
      ),
    );
  }

  Widget _actionButton(String title, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.white,
            child: Icon(icon, color: Colors.black, size: 28),
          ),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF334155))),
        ],
      ),
    );
  }
}
