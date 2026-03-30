import 'package:flutter/material.dart';
import 'package:shop_keeper_project/core/widgets/product_card.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shop_keeper_project/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:shop_keeper_project/features/inventory/presentation/bloc/inventory_cubit.dart';
import 'package:shop_keeper_project/features/inventory/domain/entities/product_entity.dart';
import 'package:shop_keeper_project/core/widgets/empty_state_widget.dart';
import 'package:shop_keeper_project/core/theme/app_theme.dart';
import 'package:shop_keeper_project/core/widgets/confirm_dialog.dart';
import 'package:shop_keeper_project/features/sales/data/models/sale_model.dart';
import 'package:shop_keeper_project/core/widgets/premium_loader.dart';
import 'package:shop_keeper_project/core/localization/app_strings.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/services.dart';
import 'package:shop_keeper_project/features/sales/presentation/bloc/sales_cubit.dart';
import 'package:go_router/go_router.dart';
import 'package:shop_keeper_project/core/widgets/custom_text_field.dart';
import 'package:shop_keeper_project/core/utils/app_error_handler.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final TextEditingController _searchController = TextEditingController();
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          AppStrings.get('inventory_hub'),
          style: TextStyle(
            fontWeight: FontWeight.w900, 
            letterSpacing: 1.5, 
            fontSize: 16,
            color: theme.colorScheme.onSurface,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: theme.colorScheme.onSurface),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: (isDark ? Colors.white : Colors.black).withOpacity(0.05)),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
                ],
              ),
              child: TextField(
                controller: _searchController,
                style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 14),
                decoration: InputDecoration(
                  hintText: AppStrings.get('search_products'),
                  hintStyle: TextStyle(color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5)),
                  prefixIcon: Icon(Icons.search_rounded, color: theme.colorScheme.onSurfaceVariant),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 15),
                  suffixIcon: _searchQuery.isNotEmpty 
                    ? IconButton(
                        icon: Icon(Icons.close_rounded, color: theme.colorScheme.onSurfaceVariant, size: 20),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.toLowerCase();
                  });
                },
              ),
            ),
          ),
          
          Expanded(
            child: BlocBuilder<InventoryCubit, InventoryState>(
              builder: (context, state) {
                if (state is InventoryLoading) {
                  return const PremiumLoader();
                } else if (state is InventoryLoaded) {
                  final allProducts = state.products;
                  final products = allProducts.where((p) => 
                    p.name.toLowerCase().contains(_searchQuery) || 
                    p.category.toLowerCase().contains(_searchQuery)
                  ).toList();

                  if (allProducts.isEmpty) {
                    return EmptyStateWidget(
                      icon: Icons.inventory_2_outlined,
                      title: AppStrings.get('no_stock_items'),
                      message: AppStrings.get('empty_inventory_message'),
                    );
                  }

                  if (products.isEmpty && _searchQuery.isNotEmpty) {
                    return Center(
                      child: Text(AppStrings.get('no_results'), style: TextStyle(color: theme.colorScheme.onSurfaceVariant)),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      
                      return Dismissible(
                        key: Key('product-${product.id}'),
                        direction: DismissDirection.endToStart,
                        confirmDismiss: (direction) async {
                          return await ConfirmDialog.danger(
                            context,
                            title: AppStrings.get('confirm_delete'),
                            message: '${AppStrings.get('delete_warning')}\n\nRemoving: ${product.name}',
                          );
                        },
                        background: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: AppTheme.dangerRose.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppTheme.dangerRose.withOpacity(0.3)),
                          ),
                          padding: const EdgeInsets.only(right: 24),
                          alignment: Alignment.centerRight,
                          child: const Icon(Icons.delete_sweep_rounded, color: AppTheme.dangerRose, size: 28),
                        ),
                        onDismissed: (direction) {
                          context.read<InventoryCubit>().deleteProduct(product.id);
                          AppErrorHandler.showSuccess(context, '${product.name} ${AppStrings.get('item_removed')}');
                        },
                        child: ProductCard(
                          product: product,
                          onTap: () => _showDialogOptions(context, product),
                          onQuickSale: () {
                            HapticFeedback.mediumImpact();
                            final profit = product.sellPrice - product.buyPrice;
                            final sale = SaleModel(
                              id: const Uuid().v4(),
                              productId: product.id,
                              productName: product.name,
                              quantitySold: 1,
                              salePrice: product.sellPrice,
                              totalAmount: product.sellPrice,
                              totalProfit: profit,
                              date: DateTime.now(),
                              userId: (context.read<AuthCubit>().state is Authenticated)
                                  ? (context.read<AuthCubit>().state as Authenticated).user.uid
                                  : (context.read<AuthCubit>().state is PinRequired)
                                      ? (context.read<AuthCubit>().state as PinRequired).user.uid
                                      : 'unknown',
                            );
                            context.read<SalesCubit>().addSale(sale);
                            Future.delayed(const Duration(milliseconds: 300), () {
                              if (context.mounted) {
                                context.read<InventoryCubit>().loadProducts();
                              }
                            });
                                AppErrorHandler.showSuccess(context, '${AppStrings.get('quick_sale')}: 1x ${product.name}');
                          },
                        ),
                      );
                    },
                  );
                } else if (state is InventoryError) {
                  return Center(child: Text('Error: ${state.message}', style: const TextStyle(color: AppTheme.dangerRose)));
                }
                return const SizedBox();
              },
            ),
          ),
        ],
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
              blurRadius: 15,
              offset: const Offset(0, 5),
            )
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: () => context.push('/inventory/add'),
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          elevation: 0,
          label: Text(AppStrings.get('new_product'), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1.5)),
          icon: const Icon(Icons.add_rounded, size: 24),
        ),
      ),
    );
  }

  void _showDialogOptions(BuildContext context, ProductEntity product) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            border: Border.all(color: (theme.brightness == Brightness.dark ? Colors.white : Colors.black).withOpacity(0.05), width: 1),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 40, 
                  height: 4, 
                  decoration: BoxDecoration(
                    color: (theme.brightness == Brightness.dark ? Colors.white24 : Colors.black12), 
                    borderRadius: BorderRadius.circular(4)
                  )
                ),
                const SizedBox(height: 24),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryIndigo.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.inventory_2_rounded, color: AppTheme.primaryIndigo),
                  ),
                  title: Text(AppStrings.get('adjust_stock'), style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
                  subtitle: Text('Manually update inventory count', style: TextStyle(color: theme.colorScheme.onSurfaceVariant)),
                  onTap: () {
                    Navigator.pop(ctx);
                    _showStockUpdateDialog(context, product);
                  },
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.accentTeal.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.edit_note_rounded, color: AppTheme.accentTeal),
                  ),
                  title: Text(AppStrings.get('edit_product_action'), style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
                  subtitle: Text(AppStrings.get('edit_product_hint'), style: TextStyle(color: theme.colorScheme.onSurfaceVariant)),
                  onTap: () {
                    Navigator.pop(ctx);
                    context.push('/inventory/edit/${product.id}');
                  },
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      }
    );
  }

  void _showStockUpdateDialog(BuildContext context, ProductEntity product) {
    final theme = Theme.of(context);
    final quantityController = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(32),
          side: BorderSide(color: (theme.brightness == Brightness.dark ? Colors.white : Colors.black).withOpacity(0.05)),
        ),
        title: Container(
          padding: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: (theme.brightness == Brightness.dark ? Colors.white : Colors.black).withOpacity(0.05))),
          ),
          child: Row(
            children: [
              const Icon(Icons.inventory_2_rounded, color: AppTheme.accentTeal, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '${AppStrings.get('adjust_stock')}: ${product.name.toUpperCase()}',
                  style: TextStyle(fontWeight: FontWeight.w900, color: theme.colorScheme.onSurface, fontSize: 13, letterSpacing: 1.5),
                ),
              ),
            ],
          ),
        ),
        content: Padding(
          padding: const EdgeInsets.only(top: 16),
          child: CustomTextField(
            label: AppStrings.get('quantity_change'),
            controller: quantityController,
            keyboardType: const TextInputType.numberWithOptions(signed: true),
            prefixIcon: Icons.add_circle_outline_rounded,
            hintText: "e.g., 5 or -2",
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(AppStrings.get('cancel'), style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1)),
          ),
          const SizedBox(width: 8),
          Container(
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: const LinearGradient(colors: [AppTheme.primaryIndigo, AppTheme.accentTeal]),
            ),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                padding: const EdgeInsets.symmetric(horizontal: 24),
              ),
              onPressed: () {
                final change = int.tryParse(quantityController.text) ?? 0;
                final action = change >= 0 ? 'ADD' : 'ADJUST';
                context.read<InventoryCubit>().updateStock(product.id, change, action);
                Navigator.pop(dialogContext);
                HapticFeedback.heavyImpact();
              },
              child: Text(AppStrings.get('confirm_action'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1)),
            ),
          ),
        ],
      ),
    );
  }
}
