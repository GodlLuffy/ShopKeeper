import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:shop_keeper_project/features/sales/presentation/bloc/sales_cubit.dart';
import 'package:shop_keeper_project/core/theme/app_colors.dart';
import 'package:shop_keeper_project/core/widgets/empty_state_widget.dart';
import 'package:shop_keeper_project/core/widgets/glass_card.dart';
import 'package:shop_keeper_project/core/widgets/premium_loader.dart';

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
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(
          'FINANCIAL LEDGER',
          style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 2, color: AppColors.textPrimary),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Search & Filter Terminal
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
            child: Column(
              children: [
                Container(
                  height: 54,
                  decoration: BoxDecoration(
                    color: AppColors.surface.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.glassBorder),
                  ),
                  child: TextField(
                    controller: _searchController,
                    style: GoogleFonts.outfit(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w600),
                    onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
                    decoration: InputDecoration(
                      hintText: 'SEARCH TRANSACTIONS...',
                      hintStyle: GoogleFonts.outfit(color: AppColors.textMuted, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.5),
                      prefixIcon: const Icon(LucideIcons.search, color: AppColors.primary, size: 18),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
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
              ],
            ),
          ),

          // Ledger Entries
          Expanded(
            child: BlocBuilder<SalesCubit, SalesState>(
              builder: (context, state) {
                if (state is SalesLoading) {
                  return const PremiumLoader(message: 'ACCESSING TRANSACTION ARCHIVES...');
                }
                if (state is SalesLoaded) {
                  final filtered = state.sales.where((s) {
                    if (_searchQuery.isEmpty) return true;
                    return s.productName.toLowerCase().contains(_searchQuery) ||
                        s.id.toLowerCase().contains(_searchQuery);
                  }).toList();

                  if (state.sales.isEmpty) {
                    return const EmptyStateWidget(
                      icon: LucideIcons.receipt,
                      title: 'LEDGER EMPTY',
                      message: 'NO TRANSACTIONS DOCUMENTED IN THIS PERIOD',
                    );
                  }

                  if (filtered.isEmpty) {
                    return const EmptyStateWidget(
                      icon: LucideIcons.searchX,
                      title: 'ZERO MATCHES',
                      message: 'REPLY SEARCH PARAMETERS',
                    );
                  }
                  
                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 100),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final sale = filtered[index];
                      return _buildTransactionTile(sale, index);
                    },
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [AppColors.primary.withOpacity(0.8), AppColors.primary],
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: () => context.push('/sales/add'),
          backgroundColor: Colors.transparent,
          elevation: 0,
          label: Text('NEW SALE', style: GoogleFonts.outfit(fontWeight: FontWeight.w900, letterSpacing: 1.2, color: Colors.white)),
          icon: Icon(LucideIcons.shoppingCart, color: Colors.white, size: 20),
        ),
      ),
    );
  }

  Widget _buildTransactionTile(dynamic sale, int index) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        backgroundOpacity: 0.03,
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.05),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.primary.withOpacity(0.1)),
              ),
              child: const Icon(LucideIcons.receipt, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    sale.productName.toUpperCase(),
                    style: GoogleFonts.outfit(fontWeight: FontWeight.w800, color: AppColors.textPrimary, fontSize: 13),
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        '${sale.quantitySold} UNITS',
                        style: GoogleFonts.outfit(color: AppColors.textMuted, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1),
                      ),
                      const SizedBox(width: 8),
                      Container(width: 3, height: 3, decoration: const BoxDecoration(color: AppColors.textMuted, shape: BoxShape.circle)),
                      const SizedBox(width: 8),
                      Text(
                        DateFormat('hh:mm a').format(sale.date),
                        style: GoogleFonts.outfit(color: AppColors.textMuted, fontSize: 10, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '₹${NumberFormat('#,##0').format(sale.totalAmount)}',
                  style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 15, color: AppColors.primary, letterSpacing: 0.5),
                ),
                const SizedBox(height: 2),
                Text(
                  '+₹${NumberFormat('#,##0').format(sale.totalProfit)}',
                  style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w900, color: AppColors.success, letterSpacing: 0.5),
                ),
              ],
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 300.ms, delay: (40 * index).ms).slideX(begin: 0.05);
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _filter == label;
    return GestureDetector(
      onTap: () => setState(() => _filter = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? AppColors.primary : AppColors.glassBorder),
        ),
        child: Text(
          label.toUpperCase(),
          style: GoogleFonts.outfit(
            color: isSelected ? AppColors.primary : AppColors.textMuted,
            fontWeight: FontWeight.w900,
            fontSize: 10,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }
}

// Extension to support backgroundGradient for Action Chip feel on FAB
extension on FloatingActionButton {
  static Widget extended({
    required VoidCallback onPressed,
    required Widget label,
    required Widget icon,
    required LinearGradient backgroundGradient,
    required double elevation,
    required Color backgroundColor,
  }) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        gradient: backgroundGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: icon,
        label: label,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          padding: const EdgeInsets.symmetric(horizontal: 24),
        ),
      ),
    );
  }
}
