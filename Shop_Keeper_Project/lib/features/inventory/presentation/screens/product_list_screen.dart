import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shop_keeper_project/features/inventory/presentation/bloc/inventory_cubit.dart';
import 'package:shop_keeper_project/features/inventory/domain/entities/product_entity.dart';
import 'package:shop_keeper_project/core/theme/app_theme.dart';
import 'package:shop_keeper_project/features/inventory/data/models/product_model.dart';
import 'package:uuid/uuid.dart';

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
            onPressed: () => _showAddProductDialog(context),
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
              return const Center(child: Text('No products yet. Add your first product!'));
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                final isLowStock = product.stockQuantity <= product.minStockAlert;
                
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    title: Text(product.name, style: Theme.of(context).textTheme.titleLarge),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Category: ${product.category}'),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text('Stock: ', style: TextStyle(
                              color: isLowStock ? AppTheme.errorColor : Colors.black87,
                              fontWeight: isLowStock ? FontWeight.bold : FontWeight.normal,
                            )),
                            Text('${product.stockQuantity}', style: TextStyle(
                              color: isLowStock ? AppTheme.errorColor : AppTheme.successColor,
                              fontWeight: FontWeight.bold,
                            )),
                            if (isLowStock) 
                              const Padding(
                                padding: EdgeInsets.only(left: 8.0),
                                child: Icon(Icons.warning, color: AppTheme.errorColor, size: 16),
                              ),
                          ],
                        ),
                      ],
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('₹${product.sellPrice}', style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryColor
                        )),
                        const Text('Price', style: TextStyle(fontSize: 12)),
                      ],
                    ),
                    onTap: () => _showStockUpdateDialog(context, product),
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
        onPressed: () => _showAddProductDialog(context),
        label: const Text('Add Product'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  void _showAddProductDialog(BuildContext context) {
    final nameController = TextEditingController();
    final buyPriceController = TextEditingController();
    final sellPriceController = TextEditingController();
    final stockController = TextEditingController();
    final minStockController = TextEditingController();
    String category = 'General Store';

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('New Product'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Name')),
              DropdownButtonFormField<String>(
                value: category,
                items: ['General Store', 'Sweets/Bakery', 'Biscuits/Snacks', 'Other']
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (val) => category = val!,
                decoration: const InputDecoration(labelText: 'Category'),
              ),
              TextField(controller: buyPriceController, decoration: const InputDecoration(labelText: 'Buy Price'), keyboardType: TextInputType.number),
              TextField(controller: sellPriceController, decoration: const InputDecoration(labelText: 'Sell Price'), keyboardType: TextInputType.number),
              TextField(controller: stockController, decoration: const InputDecoration(labelText: 'Initial Stock'), keyboardType: TextInputType.number),
              TextField(controller: minStockController, decoration: const InputDecoration(labelText: 'Min Stock Alert'), keyboardType: TextInputType.number),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final product = ProductModel(
                id: const Uuid().v4(),
                name: nameController.text,
                category: category,
                buyPrice: double.tryParse(buyPriceController.text) ?? 10.0,
                sellPrice: double.tryParse(sellPriceController.text) ?? 20.0,
                stockQuantity: int.tryParse(stockController.text) ?? 10,
                minStockAlert: int.tryParse(minStockController.text) ?? 3,
                userId: 'dummy_user', // Fixed after Auth integration
                createdAt: DateTime.now(),
              );
              context.read<InventoryCubit>().addProduct(product);
              Navigator.pop(dialogContext);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

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
