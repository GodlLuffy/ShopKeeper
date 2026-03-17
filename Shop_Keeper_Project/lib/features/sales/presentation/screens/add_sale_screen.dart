import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shop_keeper_project/features/sales/presentation/bloc/sales_cubit.dart';
import 'package:shop_keeper_project/features/inventory/presentation/bloc/inventory_cubit.dart';
import 'package:shop_keeper_project/features/inventory/domain/entities/product_entity.dart';
import 'package:shop_keeper_project/features/sales/data/models/sale_model.dart';
import 'package:shop_keeper_project/core/theme/app_theme.dart';
import 'package:uuid/uuid.dart';

class AddSaleScreen extends StatefulWidget {
  const AddSaleScreen({super.key});

  @override
  State<AddSaleScreen> createState() => _AddSaleScreenState();
}

class _AddSaleScreenState extends State<AddSaleScreen> {
  ProductEntity? _selectedProduct;
  final _quantityController = TextEditingController(text: '1');
  double _total = 0.0;

  void _calculateTotal() {
    if (_selectedProduct != null) {
      final qty = int.tryParse(_quantityController.text) ?? 0;
      setState(() {
        _total = _selectedProduct!.sellPrice * qty;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Sale')),
      body: BlocBuilder<InventoryCubit, InventoryState>(
        builder: (context, invState) {
          if (invState is! InventoryLoaded) {
            return const Center(child: CircularProgressIndicator());
          }

          final products = invState.products;

          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Select Product', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 12),
                DropdownButtonFormField<ProductEntity>(
                  isExpanded: true,
                  hint: const Text('Search or select product'),
                  value: _selectedProduct,
                  items: products.map((p) => DropdownMenuItem(
                    value: p,
                    child: Text('${p.name} (Stock: ${p.stockQuantity})'),
                  )).toList(),
                  onChanged: (val) {
                    setState(() => _selectedProduct = val);
                    _calculateTotal();
                  },
                ),
                const SizedBox(height: 24),
                
                if (_selectedProduct != null) ...[
                  Text('Quantity', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _quantityController,
                    keyboardType: TextInputType.number,
                    onChanged: (_) => _calculateTotal(),
                    decoration: const InputDecoration(
                      hintText: 'Enter quantity',
                      suffixText: 'packets/pcs',
                    ),
                  ),
                  const SizedBox(height: 40),
                  
                  // Summary Card
                  Card(
                    color: AppTheme.primaryColor.withOpacity(0.05),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Unit Price'),
                              Text('₹${_selectedProduct!.sellPrice}', style: const TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const Divider(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('TOTAL AMOUNT', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              Text('₹$_total', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const Spacer(),
                  
                  ElevatedButton(
                    onPressed: (_selectedProduct!.stockQuantity <= 0) ? null : () {
                      final qty = int.tryParse(_quantityController.text) ?? 0;
                      final profit = (_selectedProduct!.sellPrice - _selectedProduct!.buyPrice) * qty;
                      
                      final sale = SaleModel(
                        id: const Uuid().v4(),
                        productId: _selectedProduct!.id,
                        productName: _selectedProduct!.name,
                        quantitySold: qty,
                        salePrice: _selectedProduct!.sellPrice,
                        totalAmount: _total,
                        totalProfit: profit,
                        date: DateTime.now(),
                        userId: _selectedProduct!.userId,
                      );
                      
                      context.read<SalesCubit>().addSale(sale);
                      Navigator.pop(context);
                    },
                    child: Text(_selectedProduct!.stockQuantity <= 0 ? 'OUT OF STOCK' : 'CONFIRM SALE'),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
