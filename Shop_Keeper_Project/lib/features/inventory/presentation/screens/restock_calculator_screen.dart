import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shop_keeper_project/core/theme/app_theme.dart';
import 'package:shop_keeper_project/core/widgets/glass_card.dart';
import 'package:shop_keeper_project/core/widgets/premium_loader.dart';
import 'package:shop_keeper_project/features/inventory/presentation/bloc/inventory_cubit.dart';
import 'package:shop_keeper_project/features/inventory/domain/entities/product_entity.dart';

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
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppTheme.darkBackgroundMain,
      appBar: AppBar(
        title: const Text('RESTOCK CALCULATOR', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 2)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: theme.colorScheme.onSurface),
        actions: [
          BlocBuilder<InventoryCubit, InventoryState>(
            builder: (context, state) {
              if (state is InventoryLoaded && state.products.isNotEmpty) {
                return IconButton(
                  icon: const Icon(Icons.share_rounded, color: AppTheme.accentTeal),
                  tooltip: 'Share Order List',
                  onPressed: () => _shareRestockList(state.products),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: BlocBuilder<InventoryCubit, InventoryState>(
        builder: (context, state) {
          if (state is InventoryLoading) {
            return const PremiumLoader();
          }
          if (state is InventoryLoaded) {
            return _buildContent(state.products, theme);
          }
          if (state is InventoryError) {
            return Center(child: Text('Error: ${state.message}', style: const TextStyle(color: AppTheme.dangerRose)));
          }
          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildContent(List<ProductEntity> products, ThemeData theme) {
    final outOfStock = products.where((p) => p.stockQuantity <= 0).toList();
    final lowStock = products.where((p) => p.stockQuantity > 0 && p.stockQuantity <= p.minStockAlert).toList();
    
    final needsRestock = _showOutOfStockOnly ? outOfStock : [...outOfStock, ...lowStock];
    needsRestock.sort((a, b) => a.stockQuantity.compareTo(b.stockQuantity));

    final totalRestockValue = _calculateTotalRestock(needsRestock);

    return Column(
      children: [
        _buildHeader(products.length, outOfStock.length, lowStock.length, totalRestockValue),
        _buildControls(theme),
        Expanded(
          child: needsRestock.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle_rounded, size: 64, color: AppTheme.successEmerald.withOpacity(0.3)),
                      const SizedBox(height: 16),
                      const Text('ALL STOCKS LOOKING GOOD!', style: TextStyle(color: AppTheme.successEmerald, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                      const SizedBox(height: 8),
                      Text('No products need restocking right now', style: TextStyle(color: AppTheme.textMuted.withOpacity(0.5))),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: needsRestock.length,
                  itemBuilder: (context, index) {
                    final product = needsRestock[index];
                    return _buildProductCard(product, theme);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildHeader(int total, int outOfStock, int lowStock, double totalValue) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.dangerRose.withOpacity(0.1), AppTheme.warningAmber.withOpacity(0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.dangerRose.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildMiniStat('OUT OF STOCK', '$outOfStock', AppTheme.dangerRose, Icons.remove_shopping_cart_rounded),
              ),
              Container(width: 1, height: 50, color: Colors.white.withOpacity(0.1)),
              Expanded(
                child: _buildMiniStat('LOW STOCK', '$lowStock', AppTheme.warningAmber, Icons.trending_down_rounded),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.darkBackgroundLayer.withOpacity(0.5),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('ESTIMATED RESTOCK COST', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppTheme.textMuted, letterSpacing: 1.5)),
                    const SizedBox(height: 4),
                    Text('₹${totalValue.toStringAsFixed(0)}', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: AppTheme.accentTeal)),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryIndigo.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.shopping_bag_rounded, color: AppTheme.primaryIndigo, size: 28),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String label, String value, Color color, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: color, letterSpacing: 1)),
              Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildControls(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppTheme.darkBackgroundLayer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(Icons.flag_rounded, color: AppTheme.accentTeal, size: 18),
                  const SizedBox(width: 12),
                  const Text('Target Stock:', style: TextStyle(color: AppTheme.textMuted, fontSize: 12, fontWeight: FontWeight.w600)),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 60,
                    child: TextField(
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppTheme.textWhite, fontWeight: FontWeight.w900),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      controller: TextEditingController(text: _targetStock.toString()),
                      onSubmitted: (value) {
                        setState(() {
                          _targetStock = int.tryParse(value) ?? 50;
                        });
                      },
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: _showOutOfStockOnly ? AppTheme.dangerRose.withOpacity(0.15) : AppTheme.darkBackgroundLayer,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _showOutOfStockOnly ? AppTheme.dangerRose.withOpacity(0.3) : Colors.transparent),
              ),
              child: Row(
                children: [
                  Icon(Icons.filter_alt_rounded, color: _showOutOfStockOnly ? AppTheme.dangerRose : AppTheme.textMuted, size: 18),
                  const SizedBox(width: 8),
                  Text('Critical Only', style: TextStyle(color: _showOutOfStockOnly ? AppTheme.dangerRose : AppTheme.textMuted, fontSize: 12, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(ProductEntity product, ThemeData theme) {
    final qtyNeeded = _targetStock - product.stockQuantity;
    final cost = qtyNeeded * product.buyPrice;
    final isOutOfStock = product.stockQuantity <= 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: (isOutOfStock ? AppTheme.dangerRose : AppTheme.warningAmber).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isOutOfStock ? Icons.remove_shopping_cart_rounded : Icons.inventory_2_rounded,
                    color: isOutOfStock ? AppTheme.dangerRose : AppTheme.warningAmber,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(product.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppTheme.textWhite)),
                      const SizedBox(height: 2),
                      Text(product.category, style: TextStyle(fontSize: 11, color: AppTheme.textMuted.withOpacity(0.7))),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('₹${cost.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: AppTheme.accentTeal)),
                    Text('needed', style: TextStyle(fontSize: 10, color: AppTheme.textMuted.withOpacity(0.5))),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildInfoChip(
                    icon: Icons.inventory_rounded,
                    label: 'Current',
                    value: '${product.stockQuantity}',
                    color: isOutOfStock ? AppTheme.dangerRose : AppTheme.warningAmber,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward_rounded, color: AppTheme.textMuted, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildInfoChip(
                    icon: Icons.flag_rounded,
                    label: 'Target',
                    value: '$_targetStock',
                    color: AppTheme.accentTeal,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.add_rounded, color: AppTheme.textMuted, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildInfoChip(
                    icon: Icons.shopping_cart_rounded,
                    label: 'Order',
                    value: '$qtyNeeded',
                    color: AppTheme.primaryIndigo,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.darkBackgroundMain.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Buy Price: ₹${product.buyPrice.toStringAsFixed(2)}', style: TextStyle(fontSize: 11, color: AppTheme.textMuted.withOpacity(0.7))),
                  Text('Total Cost: ₹${cost.toStringAsFixed(0)}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.textWhite)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip({required IconData icon, required String label, required String value, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: color)),
          Text(label, style: TextStyle(fontSize: 9, color: AppTheme.textMuted.withOpacity(0.7))),
        ],
      ),
    );
  }

  double _calculateTotalRestock(List<ProductEntity> products) {
    double total = 0;
    for (final product in products) {
      final qtyNeeded = _targetStock - product.stockQuantity;
      if (qtyNeeded > 0) {
        total += qtyNeeded * product.buyPrice;
      }
    }
    return total;
  }

  void _shareRestockList(List<ProductEntity> products) {
    final outOfStock = products.where((p) => p.stockQuantity <= 0).toList();
    final lowStock = products.where((p) => p.stockQuantity > 0 && p.stockQuantity <= p.minStockAlert).toList();
    final needsRestock = [...outOfStock, ...lowStock];
    needsRestock.sort((a, b) => a.stockQuantity.compareTo(b.stockQuantity));

    final buffer = StringBuffer();
    buffer.writeln('━━━━━━━━━━━━━━━━━━━━━━━━');
    buffer.writeln('    RESTOCK ORDER LIST');
    buffer.writeln('━━━━━━━━━━━━━━━━━━━━━━━━');
    buffer.writeln('Target Stock Level: $_targetStock');
    buffer.writeln('Generated: ${DateTime.now().toString().substring(0, 16)}');
    buffer.writeln('');
    
    if (outOfStock.isNotEmpty) {
      buffer.writeln('⚠️ OUT OF STOCK (${outOfStock.length}):');
      for (final p in outOfStock) {
        final qty = _targetStock - p.stockQuantity;
        buffer.writeln('• ${p.name} - Order: $qty (₹${(qty * p.buyPrice).toStringAsFixed(0)})');
      }
      buffer.writeln('');
    }
    
    if (lowStock.isNotEmpty) {
      buffer.writeln('📉 LOW STOCK (${lowStock.length}):');
      for (final p in lowStock) {
        final qty = _targetStock - p.stockQuantity;
        buffer.writeln('• ${p.name} - Order: $qty (₹${(qty * p.buyPrice).toStringAsFixed(0)})');
      }
      buffer.writeln('');
    }
    
    final total = _calculateTotalRestock(needsRestock);
    buffer.writeln('━━━━━━━━━━━━━━━━━━━━━━━━');
    buffer.writeln('TOTAL ESTIMATED COST: ₹${total.toStringAsFixed(0)}');
    buffer.writeln('━━━━━━━━━━━━━━━━━━━━━━━━');
    buffer.writeln('Generated via ShopKeeper PRO OS');

    Clipboard.setData(ClipboardData(text: buffer.toString()));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle_outline_rounded, color: Colors.white, size: 20),
              SizedBox(width: 12),
              Text('Restock list copied to clipboard!', style: TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
          backgroundColor: AppTheme.successEmerald,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }
}
