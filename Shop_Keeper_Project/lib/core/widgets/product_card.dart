import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shop_keeper_project/core/theme/app_theme.dart';
import 'package:shop_keeper_project/core/widgets/glass_card.dart';
import 'package:shop_keeper_project/features/inventory/domain/entities/product_entity.dart';

class ProductCard extends StatelessWidget {
  final ProductEntity product;
  final VoidCallback onTap;
  final VoidCallback? onQuickSale;

  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
    this.onQuickSale,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isLowStock = product.stockQuantity <= product.minStockAlert;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppTheme.premiumShadow,
        border: Border.all(color: AppTheme.primaryIndigo.withOpacity(0.05)),
      ),
      child: GlassCard(
        onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // Premium Image/Icon Container
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.primaryIndigo.withOpacity(0.1), Colors.transparent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.primaryIndigo.withOpacity(0.1)),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: product.imageUrl != null && product.imageUrl!.isNotEmpty
                    ? Image.file(
                        File(product.imageUrl!),
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(Icons.inventory_2_rounded, color: AppTheme.primaryIndigo, size: 28),
                      )
                    : const Icon(Icons.inventory_2_rounded, color: AppTheme.primaryIndigo, size: 28),
              ),
            ),
            const SizedBox(width: 16),
            
            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name.toUpperCase(),
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: theme.colorScheme.onSurface, letterSpacing: 0.5),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isLowStock 
                              ? AppTheme.dangerRose.withOpacity(0.1) 
                              : (isDark ? Colors.black38 : Colors.grey.withOpacity(0.1)),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isLowStock ? AppTheme.dangerRose.withOpacity(0.3) : (isDark ? Colors.white10 : Colors.black12),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isLowStock) ...[
                              const Icon(Icons.warning_amber_rounded, size: 12, color: AppTheme.dangerRose),
                              const SizedBox(width: 6),
                            ],
                            Text(
                              "STOCK: ${product.stockQuantity}",
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                color: isLowStock ? AppTheme.dangerRose : theme.colorScheme.onSurfaceVariant,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Price & Premium Action
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '₹${product.sellPrice.toInt()}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppTheme.accentTeal),
                ),
                const SizedBox(height: 12),
                if (onQuickSale != null && product.stockQuantity > 0)
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: onQuickSale,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.successEmerald.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.successEmerald.withOpacity(0.2)),
                        ),
                      ), // Close Container 130
                    ), // Close InkWell 127
                  ) // Close Material 125
                else
                  Icon(Icons.chevron_right_rounded, color: theme.colorScheme.onSurfaceVariant.withOpacity(0.3), size: 24),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
}
