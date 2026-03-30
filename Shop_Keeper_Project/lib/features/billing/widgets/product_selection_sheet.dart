import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shop_keeper_project/features/inventory/presentation/bloc/inventory_cubit.dart';
import '../bloc/billing_bloc.dart';
import '../bloc/billing_event.dart';

class ProductSelectionSheet extends StatefulWidget {
  const ProductSelectionSheet({super.key});

  @override
  State<ProductSelectionSheet> createState() => _ProductSelectionSheetState();
}

class _ProductSelectionSheetState extends State<ProductSelectionSheet> {
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    context.read<InventoryCubit>().loadProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
      height: MediaQuery.of(context).size.height * 0.75,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Add Product', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            decoration: InputDecoration(
              labelText: 'Search Products',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onChanged: (value) => setState(() => searchQuery = value.toLowerCase()),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: BlocBuilder<InventoryCubit, InventoryState>(
              builder: (context, state) {
                if (state is InventoryLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is InventoryLoaded) {
                  final filtered = state.products
                      .where((p) => p.name.toLowerCase().contains(searchQuery))
                      .toList();

                  if (filtered.isEmpty) {
                    return const Center(child: Text("No products found"));
                  }

                  return ListView.separated(
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final product = filtered[index];
                      final isOutOfStock = product.stockQuantity <= 0;
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isOutOfStock ? Colors.red.shade100 : Colors.deepPurple.shade100,
                          child: Icon(Icons.inventory_2, color: isOutOfStock ? Colors.red : Colors.deepPurple),
                        ),
                        title: Text(product.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Text("Stock: ${product.stockQuantity} | Price: ₹${product.sellPrice}"),
                        trailing: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isOutOfStock ? Colors.grey : Colors.deepPurple,
                          ),
                          onPressed: isOutOfStock
                              ? null
                              : () {
                                  context.read<BillingBloc>().add(AddToCart(product));
                                  Navigator.pop(context);
                                },
                          child: const Text('Add', style: TextStyle(color: Colors.white)),
                        ),
                      );
                    },
                  );
                }
                return const Center(child: Text("Failed to load products"));
              },
            ),
          ),
        ],
      ),
    );
  }
}
