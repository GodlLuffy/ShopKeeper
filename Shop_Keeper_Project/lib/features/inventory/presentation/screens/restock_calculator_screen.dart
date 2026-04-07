import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:shop_keeper_project/core/theme/app_colors.dart';
import 'package:shop_keeper_project/core/widgets/glass_card.dart';
import 'package:shop_keeper_project/core/widgets/premium_loader.dart';
import 'package:shop_keeper_project/features/inventory/presentation/bloc/inventory_cubit.dart';
import 'package:shop_keeper_project/features/inventory/domain/entities/product_entity.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

class RestockCalculatorScreen extends StatefulWidget {
  const RestockCalculatorScreen({super.key});

  @override
  State<RestockCalculatorScreen> createState() => _RestockCalculatorScreenState();
}

class _RestockCalculatorScreenState extends State<RestockCalculatorScreen> {
  int _targetStock = 50;
  bool _showOutOfStockOnly = false;

  @override
  void initState() {
    super.initState();
    context.read<InventoryCubit>().loadProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(
          'CAPITAL PROJECTION', 
          style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 2.0, color: AppColors.textPrimary)
        ),
        centerTitle: true,
        actions: [
          BlocBuilder<InventoryCubit, InventoryState>(
            builder: (context, state) {
              if (state is InventoryLoaded && state.products.isNotEmpty) {
                return IconButton(
                  icon: const Icon(LucideIcons.share2, color: AppColors.primary, size: 20),
                  onPressed: () => _shareRestockList(state.products),
                );
              }
              return const SizedBox.shrink();
            },
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: BlocBuilder<InventoryCubit, InventoryState>(
        builder: (context, state) {
          if (state is InventoryLoading) {
            return const PremiumLoader(message: 'CALCULATING CAPITAL REQUIREMENTS...');
          }
          if (state is InventoryLoaded) {
            return _buildContent(state.products);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildContent(List<ProductEntity> products) {
    final outOfStock = products.where((p) => p.stockQuantity <= 0).toList();
    final lowStock = products.where((p) => p.stockQuantity > 0 && p.stockQuantity <= p.minStockAlert).toList();
    
    final needsRestock = _showOutOfStockOnly ? outOfStock : [...outOfStock, ...lowStock];
    needsRestock.sort((a, b) => a.stockQuantity.compareTo(b.stockQuantity));

    final totalRestockValue = _calculateTotalRestock(needsRestock);

    return Column(
      children: [
        _buildHeader(products.length, outOfStock.length, lowStock.length, totalRestockValue),
        _buildControls(),
        Expanded(
          child: needsRestock.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(28),
                        decoration: BoxDecoration(
                          color: AppColors.success.withOpacity(0.05),
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.success.withOpacity(0.2)),
                        ),
                        child: const Icon(LucideIcons.checkCircle2, size: 48, color: AppColors.success),
                      ),
                      const SizedBox(height: 32),
                      Text(
                        'OPTIMAL STATUS', 
                        style: GoogleFonts.outfit(color: AppColors.textPrimary, fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 3)
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'ALL ASSETS WITHIN NOMINAL PARAMETERS', 
                        style: GoogleFonts.outfit(color: AppColors.textMuted, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1)
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 600.ms).scale(begin: const Offset(0.9, 0.9))
              : ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(24),
                  itemCount: needsRestock.length,
                  itemBuilder: (context, index) {
                    final product = needsRestock[index];
                    return _buildProductCard(product, index);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildHeader(int total, int outOfStock, int lowStock, double totalValue) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: GlassCard(
        padding: const EdgeInsets.all(24),
        backgroundOpacity: 0.1,
        child: Column(
          children: [
            Row(
              children: [
                Expanded(child: _buildMiniStat('EXHAUSTED', '$outOfStock', AppColors.error, LucideIcons.packageX)),
                Container(width: 1, height: 32, color: AppColors.glassBorder),
                Expanded(child: _buildMiniStat('CRITICAL', '$lowStock', AppColors.warning, LucideIcons.trendingDown)),
              ],
            ),
            const Padding(padding: EdgeInsets.symmetric(vertical: 20), child: Divider(color: AppColors.glassBorder)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'EST. CAPITAL REQUIREMENT', 
                      style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w900, color: AppColors.textMuted, letterSpacing: 1.5)
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '₹${NumberFormat('#,##0').format(totalValue)}', 
                      style: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.w900, color: AppColors.textPrimary, letterSpacing: -1)
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(gradient: AppColors.goldGradient, borderRadius: BorderRadius.circular(16)),
                  child: const Icon(LucideIcons.calculator, color: Colors.black, size: 24),
                ),
              ],
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 500.ms).slideY(begin: -0.05);
  }

  Widget _buildMiniStat(String label, String value, Color color, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(height: 6),
        Text(value, style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
        Text(label, style: GoogleFonts.outfit(fontSize: 8, fontWeight: FontWeight.w900, color: color, letterSpacing: 1.5)),
      ],
    );
  }

  Widget _buildControls() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.surface.withOpacity(0.5),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.glassBorder),
              ),
              child: Row(
                children: [
                  const Icon(LucideIcons.target, color: AppColors.primary, size: 16),
                  const SizedBox(width: 12),
                  Text('GOAL:', style: GoogleFonts.outfit(color: AppColors.textMuted, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      keyboardType: TextInputType.number,
                      style: GoogleFonts.outfit(color: AppColors.primary, fontWeight: FontWeight.w900, fontSize: 15),
                      decoration: const InputDecoration(border: InputBorder.none, isDense: true),
                      controller: TextEditingController(text: _targetStock.toString()),
                      onSubmitted: (value) => setState(() => _targetStock = int.tryParse(value) ?? 50),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () => setState(() => _showOutOfStockOnly = !_showOutOfStockOnly),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _showOutOfStockOnly ? AppColors.error.withOpacity(0.1) : AppColors.surface.withOpacity(0.5),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _showOutOfStockOnly ? AppColors.error : AppColors.glassBorder),
              ),
              child: Icon(LucideIcons.filter, color: _showOutOfStockOnly ? AppColors.error : AppColors.textMuted, size: 18),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms, delay: 100.ms);
  }

  Widget _buildProductCard(ProductEntity product, int index) {
    final qtyNeeded = _targetStock - product.stockQuantity;
    final cost = qtyNeeded * product.buyPrice;
    final isOutOfStock = product.stockQuantity <= 0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        padding: const EdgeInsets.all(20),
        backgroundOpacity: 0.05,
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: (isOutOfStock ? AppColors.error : AppColors.warning).withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: (isOutOfStock ? AppColors.error : AppColors.warning).withOpacity(0.1)),
                  ),
                  child: Icon(isOutOfStock ? LucideIcons.packageX : LucideIcons.package2, color: isOutOfStock ? AppColors.error : AppColors.warning, size: 18),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(product.name.toUpperCase(), style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 13, color: AppColors.textPrimary)),
                      Text(product.category.toUpperCase(), style: GoogleFonts.outfit(fontSize: 9, color: AppColors.textMuted, fontWeight: FontWeight.w800, letterSpacing: 1)),
                    ],
                  ),
                ),
                Text('₹${NumberFormat('#,##0').format(cost)}', style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 16, color: AppColors.primary)),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                _buildStockInfo('HAND', '${product.stockQuantity}', isOutOfStock ? AppColors.error : AppColors.warning),
                const SizedBox(width: 12),
                _buildStockInfo('GOAL', '$_targetStock', AppColors.success),
                const SizedBox(width: 12),
                _buildStockInfo('REQUIRED', '$qtyNeeded', AppColors.primary),
              ],
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 300.ms, delay: (50 * index).ms).slideX(begin: 0.05);
  }

  Widget _buildStockInfo(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.03),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.08)),
        ),
        child: Column(
          children: [
            Text(value, style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 14, color: color)),
            Text(label, style: GoogleFonts.outfit(fontSize: 7, color: color.withOpacity(0.6), fontWeight: FontWeight.w900, letterSpacing: 1.2)),
          ],
        ),
      ),
    );
  }

  double _calculateTotalRestock(List<ProductEntity> products) {
    double total = 0;
    for (final product in products) {
      final qtyNeeded = _targetStock - product.stockQuantity;
      if (qtyNeeded > 0) total += qtyNeeded * product.buyPrice;
    }
    return total;
  }

  void _shareRestockList(List<ProductEntity> products) {
    final buffer = StringBuffer();
    buffer.writeln('✨ ASSET ACQUISITION MANIFEST');
    buffer.writeln('━━━━━━━━━━━━━━━━━━━━━━━━');
    buffer.writeln('DATE: ${DateFormat('dd MMM yyyy').format(DateTime.now())}');
    buffer.writeln('GOAL: $_targetStock UNITS/ASSET');
    buffer.writeln('━━━━━━━━━━━━━━━━━━━━━━━━\n');
    
    for (final p in products) {
      final qty = _targetStock - p.stockQuantity;
      if (qty > 0) {
        buffer.writeln('• ${p.name.toUpperCase()}');
        buffer.writeln('  REQUIRED: $qty | EST: ₹${NumberFormat('#,##0').format(qty * p.buyPrice)}\n');
      }
    }
    
    buffer.writeln('━━━━━━━━━━━━━━━━━━━━━━━━');
    buffer.writeln('CAPITAL REQUIRED: ₹${NumberFormat('#,##0').format(_calculateTotalRestock(products))}');
    buffer.writeln('━━━━━━━━━━━━━━━━━━━━━━━━');

    Clipboard.setData(ClipboardData(text: buffer.toString()));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('MANIFEST COPIED TO SECURE CLIPBOARD', style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 11, letterSpacing: 1.5)),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
