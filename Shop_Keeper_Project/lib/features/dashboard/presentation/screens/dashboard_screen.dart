import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shop_keeper_project/features/sales/presentation/bloc/sales_cubit.dart';
import 'package:shop_keeper_project/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:shop_keeper_project/features/sales/domain/usecases/get_sales_by_range.dart';
import 'package:shop_keeper_project/injection_container.dart' as di;

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  double _monthlyEarnings = 0.0;

  @override
  void initState() {
    super.initState();  
    context.read<SalesCubit>().loadTodaySales();
    _fetchMonthlyEarnings();
  }

  Future<void> _fetchMonthlyEarnings() async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
    
    final result = await di.sl<GetSalesByRange>().call(SalesRangeParams(start: startOfMonth, end: endOfMonth));
    result.fold(
      (failure) => null,
      (sales) {
        if (mounted) {
          setState(() {
            _monthlyEarnings = sales.fold(0.0, (sum, sale) => sum + sale.totalAmount);
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: BlocBuilder<SalesCubit, SalesState>(
        builder: (context, state) {
          double todayRevenue = 0.0;
          double todayProfit = 0.0;

          if (state is SalesLoaded) {
            todayRevenue = state.sales.fold(0.0, (sum, sale) => sum + sale.totalAmount);
            todayProfit = state.sales.fold(0.0, (sum, sale) => sum + sale.totalProfit);
          }

          final authState = context.read<AuthCubit>().state;
          String shopName = 'ShopKeeper';
          if (authState is Authenticated) {
            shopName = authState.user.shopName.isNotEmpty ? authState.user.shopName : authState.user.name;
          }

          return CustomScrollView(
            slivers: [
              _buildHeader(shopName, todayRevenue),
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    _buildQuickActions(context),
                    const SizedBox(height: 32),
                    
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.0),
                      child: Text(
                        'Overview',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildOverviewCards(todayProfit, _monthlyEarnings),
                    
                    const SizedBox(height: 32),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.0),
                      child: Text(
                        'Weekly Sales Trend',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildWeeklyTrendChart(),
                    
                    const SizedBox(height: 48), // Bottom Padding
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(String shopName, double revenue) {
    return SliverAppBar(
      expandedHeight: 180,
      pinned: true,
      elevation: 0,
      backgroundColor: const Color(0xFF7C3AED), // Premium Purple
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF7C3AED), Color(0xFF6D28D9)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Hello, $shopName!',
                    style: TextStyle(fontSize: 18, color: Colors.white.withOpacity(0.9), fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '₹${revenue.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 42, color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: -1),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Today's Revenue",
                    style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.9), fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.settings, color: Colors.white),
          onPressed: () => context.push('/settings'),
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _ActionButton(
            icon: Icons.point_of_sale_rounded,
            color: const Color(0xFF6D28D9),
            label: 'Sale',
            onTap: () => context.push('/sales/add'),
          ),
          _ActionButton(
            icon: Icons.inventory_2_rounded,
            color: const Color(0xFFF59E0B),
            label: 'Stock In',
            onTap: () => context.push('/inventory/add'),
          ),
          _ActionButton(
            icon: Icons.receipt_long_rounded,
            color: const Color(0xFFEF4444),
            label: 'Expense',
            onTap: () => context.push('/expenses/add'),
          ),
          _ActionButton(
            icon: Icons.psychology_rounded,
            color: const Color(0xFF10B981),
            label: 'AI',
            onTap: () => context.push('/ai-assistant'),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewCards(double profit, double monthly) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Row(
        children: [
          Expanded(
            child: _OverviewBox(
              icon: Icons.trending_up_rounded,
              iconColor: const Color(0xFF10B981),
              title: "Today's Profit",
              amount: "₹${profit.toInt()}",
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _OverviewBox(
              icon: Icons.account_balance_wallet_rounded,
              iconColor: const Color(0xFF6D28D9),
              title: "Monthly Earnings",
              amount: "₹${monthly.toInt()}",
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyTrendChart() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Container(
        height: 220,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))],
        ),
        child: Column(
          children: [
            Expanded(
              child: Align(
                alignment: Alignment.bottomRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 32.0, bottom: 8.0),
                  child: Container(
                    width: 24,
                    height: 48, // Mock tiny bar on Thursday as seen in screenshot
                    decoration: const BoxDecoration(
                      color: Color(0xFF6D28D9),
                      borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
                    ),
                  ),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text('Fri', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
                  Text('Sat', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
                  Text('Sun', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
                  Text('Mon', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
                  Text('Tue', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
                  Text('Wed', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
                  Text('Thu', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({required this.icon, required this.color, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF475569), fontSize: 13)),
        ],
      ),
    );
  }
}

class _OverviewBox extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String amount;

  const _OverviewBox({required this.icon, required this.iconColor, required this.title, required this.amount});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 24),
          const SizedBox(height: 16),
          Text(title, style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF64748B), fontSize: 13)),
          const SizedBox(height: 8),
          Text(amount, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
        ],
      ),
    );
  }
}
