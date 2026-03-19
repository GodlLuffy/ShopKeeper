import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shop_keeper_project/features/sales/presentation/bloc/sales_cubit.dart';
import 'package:shop_keeper_project/core/theme/app_theme.dart';
import 'package:intl/intl.dart';
import 'package:shop_keeper_project/core/widgets/empty_state_widget.dart';

class SalesHistoryScreen extends StatefulWidget {
  const SalesHistoryScreen({super.key});

  @override
  State<SalesHistoryScreen> createState() => _SalesHistoryScreenState();
}

class _SalesHistoryScreenState extends State<SalesHistoryScreen> {
  String _filter = 'Today';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sales History'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                _buildFilterChip('Today'),
                const SizedBox(width: 8),
                _buildFilterChip('This Week'),
                const SizedBox(width: 8),
                _buildFilterChip('This Month'),
              ],
            ),
          ),
        ),
      ),
      body: BlocBuilder<SalesCubit, SalesState>(
        builder: (context, state) {
          if (state is SalesLoading) return const Center(child: CircularProgressIndicator());
          if (state is SalesLoaded) {
            final sales = state.sales; // In real app, filter this list
            if (sales.isEmpty) {
              return const EmptyStateWidget(
                icon: Icons.receipt_long_outlined,
                title: 'No Sales Found',
                message: 'You have not made any sales for this period.',
              );
            }
            
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: sales.length,
              itemBuilder: (context, index) {
                final sale = sales[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    title: Text(sale.productName, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('${sale.quantitySold} units • ${DateFormat('hh:mm a').format(sale.date)}'),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('₹${sale.totalAmount}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        Text('Profit: ₹${sale.totalProfit}', style: const TextStyle(fontSize: 12, color: AppTheme.successColor)),
                      ],
                    ),
                  ),
                );
              },
            );
          }
          return const SizedBox();
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => GoRouter.of(context).push('/sales/add'),
        label: const Text('Add Sale'),
        icon: const Icon(Icons.add_shopping_cart),
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _filter == label;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (val) {
        if (val) setState(() => _filter = label);
        // Refresh cubit with filter in real app
      },
    );
  }
}
