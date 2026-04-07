import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:shop_keeper_project/core/theme/app_colors.dart';
import 'package:shop_keeper_project/core/widgets/glass_card.dart';
import 'package:shop_keeper_project/core/widgets/empty_state_widget.dart';
import 'package:shop_keeper_project/core/widgets/confirm_dialog.dart';
import 'package:shop_keeper_project/core/widgets/custom_text_field.dart';
import 'package:shop_keeper_project/core/widgets/primary_button.dart';
import 'package:shop_keeper_project/core/widgets/premium_loader.dart';
import 'package:shop_keeper_project/core/utils/app_error_handler.dart';
import 'package:shop_keeper_project/core/localization/app_strings.dart';
import 'package:shop_keeper_project/features/inventory/presentation/bloc/inventory_cubit.dart';
import 'package:shop_keeper_project/features/inventory/domain/entities/product_entity.dart';
import 'package:shop_keeper_project/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:shop_keeper_project/features/sales/presentation/bloc/sales_cubit.dart';
import 'package:shop_keeper_project/features/sales/data/models/sale_model.dart';
import 'package:shop_keeper_project/core/widgets/product_card.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    context.read<InventoryCubit>().loadProducts();
  }

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
          AppStrings.get('inventory_hub').toUpperCase(),
          style: GoogleFonts.outfit(fontWeight: FontWeight.w900, letterSpacing: 2, fontSize: 15),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary.withOpacity(0.2)),
              ),
              child: const Icon(LucideIcons.calculator, color: AppColors.primary, size: 18),
            ),
            onPressed: () => context.push('/inventory/restock'),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: Column(
        children: [
          // Executive Search Terminal
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
            child: Container(
              height: 54,
              decoration: BoxDecoration(
                color: AppColors.surface.withOpacity(0.8),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.glassBorder),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 15, offset: const Offset(0, 8))
                ],
              ),
              child: TextField(
                controller: _searchController,
                style: GoogleFonts.outfit(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w600),
                onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
                decoration: InputDecoration(
                  hintText: AppStrings.get('search_products').toUpperCase(),
                  hintStyle: GoogleFonts.outfit(color: AppColors.textMuted, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1),
                  prefixIcon: const Icon(LucideIcons.search, color: AppColors.primary, size: 18),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(LucideIcons.x, color: AppColors.textMuted, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                ),
              ),
            ),
          ),

          // Inventory Summary Card
          BlocBuilder<InventoryCubit, InventoryState>(
            builder: (context, state) {
              if (state is InventoryLoaded && state.products.isNotEmpty) {
                final lowStockCount = state.products.where((p) => p.stockQuantity <= p.minStockAlert).length;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: GlassCard(
                    padding: const EdgeInsets.all(24),
                    backgroundOpacity: 0.05,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildSummaryItem(
                          'TOTAL ITEMS',
                          '${state.products.length}',
                          AppColors.textMuted,
                        ),
                        Container(width: 1, height: 32, color: AppColors.glassBorder),
                        _buildSummaryItem(
                          'TOTAL VALUE',
                          '₹${NumberFormat('#,##0').format(state.products.fold(0.0, (sum, p) => sum + (p.sellPrice * p.stockQuantity)))}',
                          AppColors.primary,
                        ),
                        Container(width: 1, height: 32, color: AppColors.glassBorder),
                        _buildSummaryItem(
                          'LOW STOCK',
                          '$lowStockCount',
                          lowStockCount > 0 ? AppColors.error : AppColors.success,
                        ),
                      ],
                    ),
                  ),
                ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.1);
              }
              return const SizedBox.shrink();
            },
          ),

          const SizedBox(height: 16),

          // Virtual Showroom List
          Expanded(
            child: BlocBuilder<InventoryCubit, InventoryState>(
              builder: (context, state) {
                if (state is InventoryLoading) {
                  return const PremiumLoader(message: 'ACCESSING ASSET VAULT...');
                }
                if (state is InventoryError) {
                  return Center(
                    child: Text(
                      'SYSTEM ERROR: ${state.message.toUpperCase()}', 
                      style: GoogleFonts.outfit(color: AppColors.error, fontWeight: FontWeight.w900, letterSpacing: 1)
                    ),
                  );
                }
                if (state is InventoryLoaded) {
                  final filtered = state.products.where((p) {
                    if (_searchQuery.isEmpty) return true;
                    return p.name.toLowerCase().contains(_searchQuery) ||
                        p.category.toLowerCase().contains(_searchQuery);
                  }).toList();

                  if (filtered.isEmpty) {
                    return EmptyStateWidget(
                      icon: LucideIcons.package2,
                      title: _searchQuery.isEmpty ? AppStrings.get('no_stock_items') : AppStrings.get('no_results'),
                      message: _searchQuery.isEmpty
                          ? AppStrings.get('empty_inventory_message')
                          : 'REPLY SEARCH QUERY OR ADD NEW ASSETS',
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 100),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final product = filtered[index];
                      return Dismissible(
                        key: Key('product-${product.id}'),
                        direction: DismissDirection.endToStart,
                        confirmDismiss: (direction) async {
                          return await ConfirmDialog.danger(
                            context,
                            title: AppStrings.get('confirm_delete').toUpperCase(),
                            message: '${AppStrings.get('delete_warning')}\n\nERASING: ${product.name.toUpperCase()}',
                          );
                        },
                        background: Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: AppColors.error.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: AppColors.error.withOpacity(0.1)),
                          ),
                          padding: const EdgeInsets.only(right: 24),
                          alignment: Alignment.centerRight,
                          child: const Icon(LucideIcons.trash2, color: AppColors.error, size: 24),
                        ),
                        onDismissed: (direction) {
                          context.read<InventoryCubit>().deleteProduct(product.id);
                          AppErrorHandler.showInfo(context, 'ASSET RECYCLED');
                        },
                        child: _buildProductTile(product, index),
                      );
                    },
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/inventory/add'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: AppColors.goldGradient,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 8),
              )
            ],
          ),
          child: const Icon(LucideIcons.plus, color: Colors.black, size: 24),
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w900, color: color),
        ),
        const SizedBox(height: 6),
        Text(
          label.toUpperCase(),
          style: GoogleFonts.outfit(fontSize: 8, fontWeight: FontWeight.w800, color: AppColors.textMuted, letterSpacing: 1),
        ),
      ],
    );
  }

  Widget _buildProductTile(ProductEntity product, int index) {
    final isLowStock = product.stockQuantity <= product.minStockAlert;
    final statusColor = product.stockQuantity == 0 
        ? AppColors.error 
        : (isLowStock ? AppColors.warning : AppColors.success);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        backgroundOpacity: 0.03,
        padding: EdgeInsets.zero,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () => _showDialogOptions(context, product),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Product Specimen Icon/Image
                Container(
                  width: 54, height: 54,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.glassBorder),
                  ),
                  child: Center(
                    child: product.imageUrl != null 
                        ? const Icon(LucideIcons.image, color: AppColors.primary, size: 20)
                        : const Icon(LucideIcons.package, color: AppColors.primary, size: 24),
                  ),
                ),
                const SizedBox(width: 16),

                // Core Data
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name.toUpperCase(),
                        style: GoogleFonts.outfit(
                          fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textPrimary,
                        ),
                        maxLines: 1, overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        product.category.toUpperCase(),
                        style: GoogleFonts.outfit(fontSize: 9, color: AppColors.textMuted, fontWeight: FontWeight.w800, letterSpacing: 1),
                      ),
                    ],
                  ),
                ),

                // Stock & Valuation
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '₹${NumberFormat('#,##0').format(product.sellPrice)}',
                      style: GoogleFonts.outfit(
                        fontSize: 15, fontWeight: FontWeight.w900, color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    _buildStockTag(product.stockQuantity, statusColor),
                  ],
                ),

                const SizedBox(width: 12),
                const Icon(LucideIcons.chevronRight, color: AppColors.textMuted, size: 16),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 300.ms, delay: (40 * index).ms).slideX(begin: 0.05);
  }

  Widget _buildStockTag(int quantity, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Text(
        '$quantity UNITS',
        style: GoogleFonts.outfit(
          fontSize: 8, fontWeight: FontWeight.w900, color: color, letterSpacing: 0.5,
        ),
      ),
    );
  }

  void _showDialogOptions(BuildContext context, ProductEntity product) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          border: Border(top: BorderSide(color: AppColors.glassBorder)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.textMuted, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 32),
            _buildOptionTile(
              LucideIcons.eye, 
              'ASSET INTELLIGENCE', 
              'VIEW DETAILED SPECIFICATIONS', 
              () {
                Navigator.pop(ctx);
                context.push('/inventory/detail', extra: product);
              }
            ),
            _buildOptionTile(
              LucideIcons.edit3, 
              'REVISE PARAMETERS', 
              'MODIFY PRODUCT DATA', 
              () {
                Navigator.pop(ctx);
                context.push('/inventory/edit/${product.id}');
              }
            ),
            _buildOptionTile(
              LucideIcons.packageSearch, 
              'ADJUST QUANTITY', 
              'MANUAL STOCK CORRECTION', 
              () {
                Navigator.pop(ctx);
                _showStockUpdateDialog(context, product);
              }
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionTile(IconData icon, String title, String subtitle, VoidCallback onTap) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.05), borderRadius: BorderRadius.circular(12)),
        child: Icon(icon, color: AppColors.primary, size: 20),
      ),
      title: Text(title, style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w900, color: AppColors.textPrimary, letterSpacing: 1)),
      subtitle: Text(subtitle, style: GoogleFonts.outfit(fontSize: 11, color: AppColors.textMuted, fontWeight: FontWeight.w600)),
      trailing: const Icon(LucideIcons.chevronRight, color: AppColors.textMuted, size: 16),
    );
  }

  void _showStockUpdateDialog(BuildContext context, ProductEntity product) {
    final quantityController = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 24, right: 24, top: 12),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          border: Border(top: BorderSide(color: AppColors.glassBorder)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.textMuted, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 32),
            Text(
              'STOCK CORRECTION',
              style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.textPrimary, letterSpacing: 2),
            ),
            const SizedBox(height: 32),
            CustomTextField(
              controller: quantityController,
              label: 'QUANTITY CHANGE',
              hintText: 'e.g., 10 or -5',
              prefixIcon: LucideIcons.packageSearch,
              keyboardType: const TextInputType.numberWithOptions(signed: true),
            ),
            const SizedBox(height: 40),
            PrimaryButton(
              text: 'UPDATE VAULT',
              onPressed: () {
                final change = int.tryParse(quantityController.text) ?? 0;
                final action = change >= 0 ? 'ADD' : 'ADJUST';
                context.read<InventoryCubit>().updateStock(product.id, change, action);
                Navigator.pop(ctx);
                HapticFeedback.mediumImpact();
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
