import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:uuid/uuid.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:intl/intl.dart';
import 'package:shop_keeper_project/features/sales/presentation/bloc/sales_cubit.dart';
import 'package:shop_keeper_project/features/inventory/presentation/bloc/inventory_cubit.dart';
import 'package:shop_keeper_project/features/inventory/domain/entities/product_entity.dart';
import 'package:shop_keeper_project/features/sales/data/models/sale_model.dart';
import 'package:shop_keeper_project/core/widgets/glass_card.dart';
import 'package:shop_keeper_project/core/widgets/custom_text_field.dart';
import 'package:shop_keeper_project/core/widgets/primary_button.dart';
import 'package:shop_keeper_project/core/theme/app_colors.dart';
import 'package:shop_keeper_project/core/utils/app_error_handler.dart';
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
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          border: Border(top: BorderSide(color: AppColors.glassBorder)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 24),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.textMuted, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 32),
            Text(
              'OPTICAL ACQUISITION',
              style: GoogleFonts.outfit(fontWeight: FontWeight.w900, color: AppColors.primary, letterSpacing: 2.5, fontSize: 13),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.glassBorder, width: 2),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: MobileScanner(
                    onDetect: (capture) {
                      final List<Barcode> barcodes = capture.barcodes;
                      if (barcodes.isNotEmpty) {
                        final code = barcodes.first.rawValue?.trim() ?? '';
                        Navigator.pop(context);
                        HapticFeedback.heavyImpact();
                        
                        final matchedProducts = products.where((p) => 
                          (p.barcode != null && p.barcode == code) || 
                          p.name.toLowerCase().contains(code.toLowerCase())
                        ).toList();
                        
                        if (matchedProducts.isEmpty) {
                          AppErrorHandler.showError(context, 'PRODUCT NOT FOUND IN VAULT');
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
            ),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  void _showProductPickerDialog(List<ProductEntity> matchedProducts) {
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
            Text('AMBIGUOUS SCAN DETECTED', style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 12, color: AppColors.textSecondary, letterSpacing: 1.5)),
            const SizedBox(height: 16),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: matchedProducts.length,
                itemBuilder: (context, index) {
                  final p = matchedProducts[index];
                  return ListTile(
                    onTap: () {
                      Navigator.pop(ctx);
                      setState(() {
                        _selectedProduct = p;
                        _calculateTotal();
                      });
                    },
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.05), borderRadius: BorderRadius.circular(10)),
                      child: const Icon(LucideIcons.package, color: AppColors.primary, size: 18),
                    ),
                    title: Text(p.name.toUpperCase(), style: GoogleFonts.outfit(fontWeight: FontWeight.w800, color: AppColors.textPrimary, fontSize: 13)),
                    subtitle: Text('STOCK: ${p.stockQuantity}', style: GoogleFonts.outfit(color: AppColors.textMuted, fontSize: 10, fontWeight: FontWeight.w700)),
                    trailing: const Icon(LucideIcons.chevronRight, color: AppColors.textMuted, size: 16),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(
          'CHECKOUT TERMINAL',
          style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 2, color: AppColors.textPrimary),
        ),
        centerTitle: true,
      ),
      body: BlocBuilder<InventoryCubit, InventoryState>(
        builder: (context, invState) {
          if (invState is! InventoryLoaded) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }

          final products = invState.products;

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Selection Matrix
                Row(
                  children: [
                    const Icon(LucideIcons.cpu, color: AppColors.primary, size: 14),
                    const SizedBox(width: 8),
                    Text(
                      'PRODUCT SELECTION MATRIX',
                      style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w900, color: AppColors.textSecondary, letterSpacing: 2),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.glassBorder),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButtonFormField<ProductEntity>(
                            dropdownColor: AppColors.surface,
                            isExpanded: true,
                            hint: Text('SELECT ASSET', style: GoogleFonts.outfit(color: AppColors.textMuted, fontWeight: FontWeight.w800, fontSize: 11, letterSpacing: 1)),
                            style: GoogleFonts.outfit(color: AppColors.textPrimary, fontWeight: FontWeight.w700),
                            value: _selectedProduct,
                            decoration: const InputDecoration(border: InputBorder.none),
                            items: products.map((p) => DropdownMenuItem(
                              value: p,
                              child: Text(
                                '${p.name.toUpperCase()} (STK: ${p.stockQuantity})',
                                style: GoogleFonts.outfit(fontSize: 13),
                              ),
                            )).toList(),
                            onChanged: (val) {
                              setState(() => _selectedProduct = val);
                              _calculateTotal();
                              HapticFeedback.selectionClick();
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
                          gradient: AppColors.goldGradient,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))
                          ],
                        ),
                        child: const Icon(LucideIcons.scanLine, color: Colors.black, size: 22),
                      ),
                    ),
                  ],
                ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.05),

                const SizedBox(height: 32),
                
                if (_selectedProduct != null) ...[
                  CustomTextField(
                    label: 'QUANTITY TO COMMIT',
                    controller: _quantityController,
                    keyboardType: TextInputType.number,
                    onChanged: (_) => _calculateTotal(),
                    hintText: 'SPECIFY AMOUNT',
                    prefixIcon: LucideIcons.shoppingBag,
                  ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1),
                  const SizedBox(height: 32),
                  
                  // Financial Ledger Summary
                  Row(
                    children: [
                      const Icon(LucideIcons.receipt, color: AppColors.primary, size: 14),
                      const SizedBox(width: 8),
                      Text(
                        'TRANSACTION LEDGER',
                        style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w900, color: AppColors.textSecondary, letterSpacing: 2),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  GlassCard(
                    padding: const EdgeInsets.all(28),
                    backgroundOpacity: 0.05,
                    child: Column(
                      children: [
                        _buildLedgerRow('UNIT VALUATION', '₹${NumberFormat('#,##0.00').format(_selectedProduct!.sellPrice)}'),
                        const SizedBox(height: 12),
                        _buildLedgerRow('UNITS COMMITTED', '×${_quantityController.text}'),
                        const Padding(padding: EdgeInsets.symmetric(vertical: 20), child: Divider(color: AppColors.glassBorder)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'TOTAL DUE',
                              style: GoogleFonts.outfit(fontWeight: FontWeight.w900, color: AppColors.textMuted, fontSize: 11, letterSpacing: 1.5),
                            ),
                            Text(
                              '₹${NumberFormat('#,##0.00').format(_total)}',
                              style: GoogleFonts.outfit(fontSize: 30, fontWeight: FontWeight.w900, color: AppColors.primary, letterSpacing: -1),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ).animate().fadeIn(duration: 400.ms, delay: 100.ms).scale(begin: const Offset(0.95, 0.95)),
                  
                  const SizedBox(height: 48),
                  
                  PrimaryButton(
                    onPressed: (_selectedProduct!.stockQuantity <= 0) ? null : () {
                      final qty = int.tryParse(_quantityController.text) ?? 0;
                      if (qty <= 0) {
                        AppErrorHandler.showError(context, 'SPECIFY VALID QUANTITY');
                        return;
                      }
                      if (qty > _selectedProduct!.stockQuantity) {
                        AppErrorHandler.showError(context, 'INSUFFICIENT STOCK IN VAULT');
                        return;
                      }
                      
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
                            : 'unknown',
                      );
                      
                      context.read<SalesCubit>().addSale(sale);
                      AppErrorHandler.showSuccess(context, 'TRANSACTION COMMITTED');
                      Navigator.pop(context);
                      HapticFeedback.heavyImpact();
                    },
                    text: (_selectedProduct!.stockQuantity <= 0 ? 'OUT OF STOCK' : 'AUTHORIZE TRANSACTION'),
                  ).animate().fadeIn(duration: 400.ms, delay: 200.ms),
                  const SizedBox(height: 64),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildLedgerRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.outfit(color: AppColors.textMuted, fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 1)),
        Text(value, style: GoogleFonts.outfit(color: AppColors.textPrimary, fontWeight: FontWeight.w900, fontSize: 15)),
      ],
    );
  }
}
