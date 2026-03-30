import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shop_keeper_project/features/inventory/presentation/bloc/inventory_cubit.dart';
import 'package:shop_keeper_project/core/theme/app_theme.dart';
import 'package:shop_keeper_project/core/widgets/glass_card.dart';
import 'package:shop_keeper_project/core/constants/app_constants.dart';

/// Smart low-stock notification that auto-checks inventory
class LowStockAlert extends StatelessWidget {
  const LowStockAlert({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<InventoryCubit, InventoryState>(
      builder: (context, state) {
        if (state is! InventoryLoaded) return const SizedBox.shrink();

        final lowStock = state.products.where((p) =>
            p.stockQuantity > 0 && p.stockQuantity <= AppConstants.lowStockThreshold).toList();
        final outOfStock = state.products.where((p) => p.stockQuantity <= 0).toList();

        if (lowStock.isEmpty && outOfStock.isEmpty) return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: GlassCard(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.warningAmber.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.notification_important_rounded, color: AppTheme.warningAmber, size: 18),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text('STOCK ALERTS', style: TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w900, color: AppTheme.warningAmber, letterSpacing: 1.5,
                        )),
                      ),
                      TextButton(
                        onPressed: () => context.push('/inventory'),
                        child: const Text('VIEW ALL', style: TextStyle(color: AppTheme.accentTeal, fontWeight: FontWeight.w700, fontSize: 11)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (outOfStock.isNotEmpty)
                    _buildAlertRow(
                      '${outOfStock.length} products OUT OF STOCK',
                      AppTheme.dangerRose,
                      Icons.close_rounded,
                    ),
                  if (lowStock.isNotEmpty) ...[
                    if (outOfStock.isNotEmpty) const SizedBox(height: 8),
                    _buildAlertRow(
                      '${lowStock.length} products running low (≤${AppConstants.lowStockThreshold})',
                      AppTheme.warningAmber,
                      Icons.trending_down_rounded,
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAlertRow(String text, Color color, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 8),
        Expanded(
          child: Text(text, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }
}
