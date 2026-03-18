import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shop_keeper_project/features/sales/presentation/bloc/sales_cubit.dart';
import 'package:shop_keeper_project/features/inventory/presentation/bloc/inventory_cubit.dart';
import 'package:shop_keeper_project/features/inventory/domain/entities/product_entity.dart';
import 'package:shop_keeper_project/features/sales/data/models/sale_model.dart';
import 'package:shop_keeper_project/core/theme/app_theme.dart';
import 'package:uuid/uuid.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:shop_keeper_project/features/auth/presentation/bloc/auth_cubit.dart';

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

  void _showBarcodeScanner(List<ProductEntity> products) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SizedBox(
        height: 400,
        child: MobileScanner(
          onDetect: (capture) {
            final List<Barcode> barcodes = capture.barcodes;
            if (barcodes.isNotEmpty) {
              final code = barcodes.first.rawValue;
              final product = products.firstWhere(
                (p) => p.barcode == code,
                orElse: () => products.firstWhere((p) => false, orElse: () => _selectedProduct ?? products.first), // Fallback or handle not found
              );
              
              if (product.barcode == code) {
                setState(() {
                  _selectedProduct = product;
                  _calculateTotal();
                });
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Product not found for this barcode')),
                );
              }
            }
          },
        ),
      ),
    );
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
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<ProductEntity>(
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
                    ),
                    const SizedBox(width: 12),
                    IconButton.filledTonal(
                      icon: const Icon(Icons.qr_code_scanner),
                      onPressed: () => _showBarcodeScanner(products),
                    ),
                  ],
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
                        userId: (context.read<AuthCubit>().state is Authenticated) 
                            ? (context.read<AuthCubit>().state as Authenticated).user.uid 
                            : (context.read<AuthCubit>().state is PinRequired)
                                ? (context.read<AuthCubit>().state as PinRequired).user.uid
                                : 'unknown',
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
