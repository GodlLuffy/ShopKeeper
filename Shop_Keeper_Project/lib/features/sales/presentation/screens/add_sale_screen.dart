import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shop_keeper_project/features/sales/presentation/bloc/sales_cubit.dart';
import 'package:shop_keeper_project/features/inventory/presentation/bloc/inventory_cubit.dart';
import 'package:shop_keeper_project/features/inventory/domain/entities/product_entity.dart';
import 'package:shop_keeper_project/features/sales/data/models/sale_model.dart';
import 'package:shop_keeper_project/core/theme/app_theme.dart';
import 'package:shop_keeper_project/core/widgets/glass_card.dart';
import 'package:shop_keeper_project/core/widgets/custom_text_field.dart';
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
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: AppTheme.darkBackgroundLayer,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2))),
            const Padding(
              padding: EdgeInsets.all(24.0),
              child: Text('SCAN PRODUCT BARCODE', style: TextStyle(fontWeight: FontWeight.w900, color: AppTheme.textWhite, letterSpacing: 2)),
            ),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: MobileScanner(
                  onDetect: (capture) {
                    final List<Barcode> barcodes = capture.barcodes;
                    if (barcodes.isNotEmpty) {
                      final code = barcodes.first.rawValue?.trim() ?? '';
                      Navigator.pop(context);
                      
                      final matchedProducts = products.where((p) => 
                        (p.barcode != null && p.barcode == code) || 
                        p.name.toLowerCase().contains(code.toLowerCase())
                      ).toList();
                      
                      if (matchedProducts.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Product not found for this barcode'), backgroundColor: AppTheme.dangerRose),
                        );
                      } else if (matchedProducts.length == 1) {
                        setState(() {
                          _selectedProduct = matchedProducts.first;
                          _calculateTotal();
                        });
                      } else {
                        _showProductPickerDialog(matchedProducts);
                      }
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  void _showProductPickerDialog(List<ProductEntity> matchedProducts) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: AppTheme.darkBackgroundLayer,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('SELECT PRODUCT', style: TextStyle(color: AppTheme.textWhite, fontWeight: FontWeight.w900, fontSize: 16)),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: matchedProducts.length,
            itemBuilder: (context, index) {
              final p = matchedProducts[index];
              return ListTile(
                title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textWhite)),
                subtitle: Text('Stock: ${p.stockQuantity}', style: const TextStyle(color: AppTheme.textMuted)),
                trailing: const Icon(Icons.add_circle_outline, color: AppTheme.accentTeal),
                onTap: () {
                  Navigator.pop(dialogCtx);
                  setState(() {
                    _selectedProduct = p;
                    _calculateTotal();
                  });
                },
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackgroundMain,
      appBar: AppBar(
        title: const Text('NEW SALE', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 2)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: BlocBuilder<InventoryCubit, InventoryState>(
        builder: (context, invState) {
          if (invState is! InventoryLoaded) {
            return const Center(child: CircularProgressIndicator(color: AppTheme.primaryIndigo));
          }

          final products = invState.products;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('PRODUCT SELECTION', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: AppTheme.accentTeal, letterSpacing: 1.5)),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: AppTheme.darkBackgroundLayer,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white.withOpacity(0.05)),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButtonFormField<ProductEntity>(
                            dropdownColor: AppTheme.darkBackgroundLayer,
                            isExpanded: true,
                            hint: const Text('Select product', style: TextStyle(color: AppTheme.textMuted)),
                            style: const TextStyle(color: AppTheme.textWhite, fontWeight: FontWeight.w600),
                            value: _selectedProduct,
                            decoration: const InputDecoration(border: InputBorder.none),
                            items: products.map((p) => DropdownMenuItem(
                              value: p,
                              child: Text('${p.name} (${p.stockQuantity} in stock)'),
                            )).toList(),
                            onChanged: (val) {
                              setState(() => _selectedProduct = val);
                              _calculateTotal();
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: () => _showBarcodeScanner(products),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [AppTheme.primaryIndigo, AppTheme.accentTeal]),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(Icons.qr_code_scanner_rounded, color: Colors.white),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                
                if (_selectedProduct != null) ...[
                  CustomTextField(
                    label: 'QUANTITY TO SELL',
                    controller: _quantityController,
                    keyboardType: TextInputType.number,
                    onChanged: (_) => _calculateTotal(),
                    hintText: 'Enter amount...',
                    prefixIcon: Icons.shopping_basket_outlined,
                    suffixIcon: const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('units', style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  const Text('SALE SUMMARY', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: AppTheme.accentTeal, letterSpacing: 1.5)),
                  const SizedBox(height: 16),
                  GlassCard(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        _buildSummaryRow('Unit Price', '₹${_selectedProduct!.sellPrice}'),
                        const SizedBox(height: 12),
                        _buildSummaryRow('Quantity', 'x${_quantityController.text}'),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Divider(color: Colors.white10),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('TOTAL PAYABLE', style: TextStyle(fontWeight: FontWeight.w900, color: AppTheme.textMuted, fontSize: 13)),
                            Text('₹${_total.toStringAsFixed(2)}', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: AppTheme.accentTeal, letterSpacing: -1)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 48),
                  
                  Container(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: (_selectedProduct!.stockQuantity <= 0) 
                          ? LinearGradient(colors: [Colors.grey.withOpacity(0.2), Colors.grey.withOpacity(0.1)])
                          : const LinearGradient(colors: [AppTheme.primaryIndigo, AppTheme.accentTeal]),
                    ),
                    child: ElevatedButton(
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
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: Text(
                        (_selectedProduct!.stockQuantity <= 0 ? 'OUT OF STOCK' : 'CONFIRM TRANSACTION').toUpperCase(),
                        style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 2, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppTheme.textMuted, fontSize: 14)),
        Text(value, style: const TextStyle(color: AppTheme.textWhite, fontWeight: FontWeight.bold, fontSize: 16)),
      ],
    );
  }
}
