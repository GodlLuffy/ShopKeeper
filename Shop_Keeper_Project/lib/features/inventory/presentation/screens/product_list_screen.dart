import 'package:flutter/material.dart';
import 'package:shop_keeper_project/core/widgets/product_card.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shop_keeper_project/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:shop_keeper_project/features/inventory/presentation/bloc/inventory_cubit.dart';
import 'package:shop_keeper_project/features/inventory/domain/entities/product_entity.dart';
import 'package:shop_keeper_project/core/widgets/empty_state_widget.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/services.dart';
import 'package:shop_keeper_project/features/sales/presentation/bloc/sales_cubit.dart';
import 'package:shop_keeper_project/features/sales/data/models/sale_model.dart';
import 'package:go_router/go_router.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  @override
  void initState() {
    super.initState();
    context.read<InventoryCubit>().loadProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_business),
            onPressed: () => context.push('/inventory/add'),
            tooltip: 'Add Product',
          ),
        ],
      ),
      body: BlocBuilder<InventoryCubit, InventoryState>(
        builder: (context, state) {
          if (state is InventoryLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is InventoryLoaded) {
            final products = state.products;
            if (products.isEmpty) {
              return const EmptyStateWidget(
                icon: Icons.inventory_2_outlined,
                title: 'No Products Yet',
                message: 'Start by adding your first product.',
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                
                return Dismissible(
                  key: Key(product.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    padding: const EdgeInsets.only(right: 20),
                    alignment: Alignment.centerRight,
                    color: Colors.red,
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (direction) {
                    context.read<InventoryCubit>().deleteProduct(product.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${product.name} deleted')),
                    );
                  },
                  child: ProductCard(
                    product: product,
                    onTap: () => _showStockUpdateDialog(context, product),
                    onQuickSale: () {
                      HapticFeedback.heavyImpact();
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
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Quick sale: 1x ${product.name} sold!'), duration: const Duration(seconds: 1)),
                      );
                    },
                  ),
                );
              },
            );
          } else if (state is InventoryError) {
            return Center(child: Text('Error: ${state.message}'));
          }
          return const SizedBox();
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/inventory/add'),
        label: const Text('Add Product'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  // Legacy Add Product Dialog Removed In Favor of Dedicated Router Page

  void _showStockUpdateDialog(BuildContext context, ProductEntity product) {
    final quantityController = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Update ${product.name} Stock'),
        content: TextField(
          controller: quantityController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(hintText: 'Enter quantity change (e.g., 5 or -2)'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final change = int.tryParse(quantityController.text) ?? 0;
              final action = change >= 0 ? 'ADD' : 'ADJUST';
              context.read<InventoryCubit>().updateStock(product.id, change, action);
              Navigator.pop(dialogContext);
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }
}
