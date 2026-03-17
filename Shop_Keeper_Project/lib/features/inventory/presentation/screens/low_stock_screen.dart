import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shop_keeper_project/features/inventory/presentation/bloc/inventory_cubit.dart';
import 'package:shop_keeper_project/core/theme/app_theme.dart';
import 'package:shop_keeper_project/features/inventory/presentation/screens/edit_product_screen.dart';

class LowStockScreen extends StatelessWidget {
  const LowStockScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Low Stock Alerts')),
      body: BlocBuilder<InventoryCubit, InventoryState>(
        builder: (context, state) {
          if (state is InventoryLoaded) {
            final lowStockItems = state.products.where((p) => p.stockQuantity <= p.minStockAlert).toList();
            if (lowStockItems.isEmpty) {
              return const Center(child: Text('All products are well stocked!'));
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: lowStockItems.length,
              itemBuilder: (context, index) {
                final product = lowStockItems[index];
                return Card(
                  color: AppTheme.errorColor.withOpacity(0.05),
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    title: Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('Only ${product.stockQuantity} left! (Alert at ${product.minStockAlert})'),
                    trailing: ElevatedButton(
                      onPressed: () => Navigator.push(
                        context, 
                        MaterialPageRoute(builder: (_) => EditProductScreen(product: product)),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        minimumSize: const Size(80, 40),
                      ),
                      child: const Text('Restock', style: TextStyle(fontSize: 14)),
                    ),
                  ),
                );
              },
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
