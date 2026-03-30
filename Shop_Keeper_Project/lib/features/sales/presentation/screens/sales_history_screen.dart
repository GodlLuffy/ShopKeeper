import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shop_keeper_project/features/sales/presentation/bloc/sales_cubit.dart';
import 'package:shop_keeper_project/core/theme/app_theme.dart';
import 'package:intl/intl.dart';
import 'package:shop_keeper_project/core/widgets/empty_state_widget.dart';
import 'package:shop_keeper_project/core/widgets/glass_card.dart';

class SalesHistoryScreen extends StatefulWidget {
  const SalesHistoryScreen({super.key});

  @override
  State<SalesHistoryScreen> createState() => _SalesHistoryScreenState();
}

class _SalesHistoryScreenState extends State<SalesHistoryScreen> {
  String _filter = 'Today';
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackgroundMain,
      appBar: AppBar(
        title: const Text('SALES HISTORY', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 2)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(130),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.05))),
            ),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  style: const TextStyle(color: AppTheme.textWhite),
                  onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
                  decoration: InputDecoration(
                    hintText: 'Search sales...',
                    hintStyle: const TextStyle(color: AppTheme.textMuted),
                    prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.textMuted),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, color: AppTheme.textMuted),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildFilterChip('Today'),
                    const SizedBox(width: 8),
                    _buildFilterChip('This Week'),
                    const SizedBox(width: 8),
                    _buildFilterChip('This Month'),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      body: BlocBuilder<SalesCubit, SalesState>(
        builder: (context, state) {
          if (state is SalesLoading) {
            return const Center(child: CircularProgressIndicator(color: AppTheme.primaryIndigo));
          }
          if (state is SalesLoaded) {
            final allSales = state.sales;
            final filtered = allSales.where((s) {
              if (_searchQuery.isEmpty) return true;
              return s.productName.toLowerCase().contains(_searchQuery) ||
                  s.id.toLowerCase().contains(_searchQuery);
            }).toList();

            if (allSales.isEmpty) {
              return const EmptyStateWidget(
                icon: Icons.receipt_long_rounded,
                title: 'No Recorded Sales',
                message: 'Start generating revenue to see your history here.',
              );
            }

            if (filtered.isEmpty) {
              return const EmptyStateWidget(
                icon: Icons.search_off_rounded,
                title: 'No Results Found',
                message: 'Try a different search term.',
              );
            }
            
            return Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.topLeft,
                  radius: 1.5,
                  colors: [
                    AppTheme.accentTeal.withOpacity(0.03),
                    Colors.transparent,
                  ],
                ),
              ),
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 100),
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final sale = filtered[index];
                  return GlassCard(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      title: Text(
                        sale.productName, 
                        style: const TextStyle(fontWeight: FontWeight.w800, color: AppTheme.textWhite, fontSize: 15),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          '${sale.quantitySold} units • ${DateFormat('hh:mm a').format(sale.date)}', 
                          style: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
                        ),
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '₹${sale.totalAmount.toStringAsFixed(0)}', 
                            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17, color: AppTheme.accentTeal),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '+₹${sale.totalProfit.toStringAsFixed(0)}', 
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.successEmerald),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          }
          return const SizedBox();
        },
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            colors: [AppTheme.primaryIndigo, AppTheme.accentTeal],
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryIndigo.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: () => GoRouter.of(context).push('/sales/add'),
          backgroundColor: Colors.transparent,
          elevation: 0,
          label: const Text('NEW SALE', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.2)),
          icon: const Icon(Icons.add_shopping_cart_rounded),
        ),
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
      },
      selectedColor: AppTheme.primaryIndigo.withOpacity(0.3),
      backgroundColor: AppTheme.darkBackgroundLayer,
      labelStyle: TextStyle(
        color: isSelected ? AppTheme.textWhite : AppTheme.textMuted,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        fontSize: 12,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: isSelected ? AppTheme.primaryIndigo : Colors.white.withOpacity(0.05),
        ),
      ),
    );
  }
}
