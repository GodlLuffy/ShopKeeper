import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shop_keeper_project/core/theme/app_colors.dart';
import 'package:shop_keeper_project/core/theme/app_theme.dart';
import 'package:shop_keeper_project/core/widgets/glass_card.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../bloc/billing_bloc.dart';
import '../bloc/billing_event.dart';
import '../model/cart_item.dart';

class CartListView extends StatelessWidget {
  final List<CartItem> items;

  const CartListView({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: items.length,
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
      itemBuilder: (context, index) {
        final item = items[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: GlassCard(
            padding: const EdgeInsets.all(20),
            backgroundOpacity: 0.03,
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.primary.withOpacity(0.1)),
                  ),
                  child: const Icon(LucideIcons.package, color: AppColors.primary, size: 24),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.product.name.toUpperCase(),
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.w800, 
                          fontSize: 13, 
                          color: AppColors.textPrimary, 
                          letterSpacing: 0.5
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Text(
                            "₹${item.product.sellPrice.toStringAsFixed(2)}",
                            style: GoogleFonts.outfit(
                              color: AppColors.textMuted, 
                              fontSize: 12,
                              fontWeight: FontWeight.w600
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text("×", style: GoogleFonts.outfit(color: AppColors.textMuted.withOpacity(0.5), fontSize: 12)),
                          ),
                          Text(
                            "${item.quantity}",
                            style: GoogleFonts.outfit(
                              color: AppColors.textPrimary, 
                              fontSize: 12, 
                              fontWeight: FontWeight.w900
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "₹${item.total.toStringAsFixed(2)}",
                        style: GoogleFonts.outfit(
                          color: AppColors.primary, 
                          fontWeight: FontWeight.w900, 
                          fontSize: 17,
                          letterSpacing: -0.5
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.glassBorder),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildQuantityButton(
                        icon: LucideIcons.minus,
                        onPressed: () {
                          context.read<BillingBloc>().add(UpdateCartQuantity(item.product, item.quantity - 1));
                        },
                      ),
                      Container(
                        constraints: const BoxConstraints(minWidth: 32),
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Text(
                          '${item.quantity}',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.outfit(
                            fontSize: 14, 
                            fontWeight: FontWeight.w900, 
                            color: AppColors.textPrimary
                          ),
                        ),
                      ),
                      _buildQuantityButton(
                        icon: LucideIcons.plus,
                        isPrimary: true,
                        onPressed: () {
                          if (item.quantity < item.product.stockQuantity) {
                            context.read<BillingBloc>().add(UpdateCartQuantity(item.product, item.quantity + 1));
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('MAXIMUM STOCK REACHED (${item.product.stockQuantity})', 
                                  style: GoogleFonts.outfit(fontWeight: FontWeight.w900, color: Colors.black, fontSize: 11, letterSpacing: 1)),
                                backgroundColor: AppColors.primary,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuantityButton({required IconData icon, required VoidCallback onPressed, bool isPrimary = false}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isPrimary ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 16, color: isPrimary ? AppColors.primary : AppColors.textMuted),
        ),
      ),
    );
  }
}

