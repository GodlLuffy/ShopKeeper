import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:shop_keeper_project/features/inventory/presentation/bloc/inventory_cubit.dart';
import 'package:shop_keeper_project/core/theme/app_colors.dart';
import 'package:shop_keeper_project/core/widgets/glass_card.dart';
import 'package:shop_keeper_project/core/widgets/premium_loader.dart';

class LowStockScreen extends StatelessWidget {
  const LowStockScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(
          'CRITICAL ALERTS', 
          style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 2, color: AppColors.textPrimary)
        ),
        centerTitle: true,
      ),
      body: BlocBuilder<InventoryCubit, InventoryState>(
        builder: (context, state) {
          if (state is InventoryLoading) {
            return const PremiumLoader(message: 'SCANNING PARAMETERS...');
          }
          if (state is InventoryLoaded) {
            final lowStockItems = state.products.where((p) => p.stockQuantity <= p.minStockAlert).toList();
            
            if (lowStockItems.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.05),
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.success.withOpacity(0.2)),
                      ),
                      child: const Icon(LucideIcons.shieldCheck, color: AppColors.success, size: 48),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'STATUS: OPTIMAL',
                      style: GoogleFonts.outfit(color: AppColors.textPrimary, fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 3),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'ALL ASSET LEVELS WITHIN NOMINAL RANGE',
                      style: GoogleFonts.outfit(color: AppColors.textMuted, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 600.ms).scale(begin: const Offset(0.9, 0.9));
            }

            return ListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(24),
              itemCount: lowStockItems.length,
              itemBuilder: (context, index) {
                final product = lowStockItems[index];
                final isCritical = product.stockQuantity == 0;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: GlassCard(
                    padding: const EdgeInsets.all(20),
                    backgroundOpacity: 0.05,
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: (isCritical ? AppColors.error : AppColors.warning).withOpacity(0.05),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: (isCritical ? AppColors.error : AppColors.warning).withOpacity(0.2)),
                          ),
                          child: Icon(
                            isCritical ? LucideIcons.alertOctagon : LucideIcons.alertTriangle, 
                            color: isCritical ? AppColors.error : AppColors.warning, 
                            size: 20
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product.name.toUpperCase(),
                                style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 13, color: AppColors.textPrimary, letterSpacing: 0.5),
                                maxLines: 1, overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${product.stockQuantity} UNITS REMAINING',
                                style: GoogleFonts.outfit(
                                  color: isCritical ? AppColors.error : AppColors.warning, 
                                  fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1
                                ),
                              ),
                              Text(
                                'ALERT TRIGGER: ${product.minStockAlert} UNITS',
                                style: GoogleFonts.outfit(color: AppColors.textMuted, fontSize: 9, fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        GestureDetector(
                          onTap: () => context.push('/inventory/edit/${product.id}'),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              gradient: AppColors.goldGradient,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(color: AppColors.primary.withOpacity(0.2), blurRadius: 10)
                              ],
                            ),
                            child: Text(
                              'RESTOCK',
                              style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 10, color: Colors.black, letterSpacing: 1.5),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ).animate().fadeIn(duration: 300.ms, delay: (50 * index).ms).slideX(begin: 0.05);
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
