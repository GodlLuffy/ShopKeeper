import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shop_keeper_project/core/theme/app_colors.dart';
import 'package:shop_keeper_project/core/theme/app_theme.dart';
import 'package:shop_keeper_project/core/widgets/glass_card.dart';
import 'package:shop_keeper_project/core/widgets/premium_loader.dart';
import 'package:shop_keeper_project/features/inventory/presentation/bloc/inventory_cubit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
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
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        border: Border(top: BorderSide(color: AppColors.glassBorder)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.textMuted, borderRadius: BorderRadius.circular(4))),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(LucideIcons.search, color: AppColors.primary, size: 24),
                    const SizedBox(width: 16),
                    Text(
                      'SELECTION TERMINAL', 
                      style: GoogleFonts.outfit(
                        fontSize: 14, 
                        fontWeight: FontWeight.w900, 
                        color: AppColors.textPrimary,
                        letterSpacing: 2,
                      )
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(LucideIcons.x, color: AppColors.textMuted, size: 20), 
                  onPressed: () => Navigator.pop(context)
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.glassBorder),
              ),
              child: TextField(
                autofocus: true,
                style: GoogleFonts.outfit(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w600),
                decoration: InputDecoration(
                  hintText: 'SEARCH BY NAME OR BARCODE...',
                  hintStyle: GoogleFonts.outfit(color: AppColors.textMuted.withOpacity(0.3), fontWeight: FontWeight.w800, fontSize: 12, letterSpacing: 1),
                  prefixIcon: const Icon(LucideIcons.search, color: AppColors.primary, size: 18),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onChanged: (value) => setState(() => searchQuery = value.toLowerCase()),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: BlocBuilder<InventoryCubit, InventoryState>(
              builder: (context, state) {
                if (state is InventoryLoading) {
                  return const PremiumLoader();
                } else if (state is InventoryLoaded) {
                  final filtered = state.products
                      .where((p) => p.name.toLowerCase().contains(searchQuery) || (p.barcode != null && p.barcode!.contains(searchQuery)))
                      .toList();

                  if (filtered.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(LucideIcons.frown, size: 48, color: AppColors.textMuted.withOpacity(0.2)),
                          const SizedBox(height: 16),
                          Text(
                            "NO MATCHING PRODUCTS",
                            style: GoogleFonts.outfit(color: AppColors.textMuted, fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: 12),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    itemCount: filtered.length,
                    physics: const BouncingScrollPhysics(),
                    itemBuilder: (context, index) {
                      final product = filtered[index];
                      final isOutOfStock = product.stockQuantity <= 0;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: GlassCard(
                          key: ValueKey('selection-${product.id}'),
                          padding: const EdgeInsets.all(16),
                          backgroundOpacity: 0.03,
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(LucideIcons.package, color: AppColors.primary, size: 20),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                flex: 3,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product.name.toUpperCase(), 
                                      style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 13, color: AppColors.textPrimary),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Text(
                                          "STOCK: ", 
                                          style: GoogleFonts.outfit(color: AppColors.textMuted, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.5)
                                        ),
                                        Text(
                                          "${product.stockQuantity}", 
                                          style: GoogleFonts.outfit(color: product.stockQuantity <= product.minStockAlert ? AppColors.error : AppColors.success, fontSize: 10, fontWeight: FontWeight.w900)
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              SizedBox(
                                height: 36,
                                width: 80,
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    gradient: isOutOfStock ? null : AppColors.goldGradient,
                                    color: isOutOfStock ? Colors.grey.withOpacity(0.1) : null,
                                  ),
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      shadowColor: Colors.transparent,
                                      padding: const EdgeInsets.symmetric(horizontal: 16),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    ),
                                    onPressed: isOutOfStock
                                        ? null
                                        : () {
                                            context.read<BillingBloc>().add(AddToCart(product));
                                            Navigator.pop(context);
                                          },
                                    child: Text(
                                      'ADD', 
                                      style: GoogleFonts.outfit(
                                        color: isOutOfStock ? AppColors.textMuted : Colors.black, 
                                        fontWeight: FontWeight.w900, 
                                        fontSize: 11,
                                        letterSpacing: 1,
                                      )
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }
                return Center(
                  child: Text(
                    "FAILED TO CONNECT TO DISPENSARY", 
                    style: GoogleFonts.outfit(color: AppColors.error, fontWeight: FontWeight.w900, letterSpacing: 1),
                  )
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

