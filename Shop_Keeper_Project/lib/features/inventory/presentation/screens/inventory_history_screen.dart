import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shop_keeper_project/features/inventory/presentation/bloc/inventory_cubit.dart';
import 'package:shop_keeper_project/core/theme/app_colors.dart';
import 'package:shop_keeper_project/core/widgets/glass_card.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

class InventoryHistoryScreen extends StatelessWidget {
  const InventoryHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(
          'ASSET AUDIT TRAIL', 
          style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 2, color: AppColors.textPrimary)
        ),
        centerTitle: true,
      ),
      body: BlocBuilder<InventoryCubit, InventoryState>(
        builder: (context, state) {
          // Note: Full historical logging logic is pending, using premium specimen tiles for now
          return ListView.builder(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(24),
            itemCount: 8,
            itemBuilder: (context, index) {
              final isAcquisition = index % 3 == 0;
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: GlassCard(
                  padding: const EdgeInsets.all(16),
                  backgroundOpacity: 0.05,
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: (isAcquisition ? AppColors.success : AppColors.error).withOpacity(0.05),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: (isAcquisition ? AppColors.success : AppColors.error).withOpacity(0.2)),
                        ),
                        child: Icon(
                          isAcquisition ? LucideIcons.arrowUpRight : LucideIcons.arrowDownRight,
                          color: isAcquisition ? AppColors.success : AppColors.error,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isAcquisition ? 'STOCK ACQUISITION' : 'INVENTORY DISBURSEMENT',
                              style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1.5, color: AppColors.textMuted),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              isAcquisition ? 'PREMIUM CONFECTIONS' : 'LUXURY BEVERAGES',
                              style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 13, color: AppColors.textPrimary),
                              maxLines: 1, overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              DateFormat('dd MMM yyyy • hh:mm a').format(DateTime.now().subtract(Duration(hours: index * 6))),
                              style: GoogleFonts.outfit(fontSize: 9, color: AppColors.textMuted, fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        isAcquisition ? '+50' : '-12',
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.w900, fontSize: 16, 
                          color: isAcquisition ? AppColors.success : AppColors.error,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ).animate().fadeIn(duration: 300.ms, delay: (50 * index).ms).slideX(begin: 0.05);
            },
          );
        },
      ),
    );
  }
}
