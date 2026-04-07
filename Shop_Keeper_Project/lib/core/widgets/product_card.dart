import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shop_keeper_project/core/theme/app_colors.dart';
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
        border: Border.all(color: AppColors.primary.withOpacity(0.05)),
      ),
      child: GlassCard(
        onTap: onTap,
        padding: const EdgeInsets.all(12),
        backgroundOpacity: 0.08,
      child: Row(
        children: [
          // Premium Image/Icon Container
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary.withOpacity(0.15), Colors.transparent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.primary.withOpacity(0.1)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: product.imageUrl != null && product.imageUrl!.isNotEmpty
                  ? Image.file(
                      File(product.imageUrl!),
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Icon(Icons.inventory_2_rounded, color: AppColors.primary.withOpacity(0.5), size: 32),
                    )
                  : Icon(Icons.inventory_2_rounded, color: AppColors.primary.withOpacity(0.5), size: 32),
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
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isLowStock 
                            ? AppColors.error.withOpacity(0.1) 
                            : AppColors.secondary.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isLowStock ? AppColors.error.withOpacity(0.3) : AppColors.glassBorder,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (isLowStock) ...[
                            const Icon(Icons.warning_amber_rounded, size: 12, color: AppColors.error),
                            const SizedBox(width: 6),
                          ],
                          Text(
                            "STOCK: ${product.stockQuantity}",
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              color: isLowStock ? AppColors.error : AppColors.textSecondary,
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
                style: const TextStyle(
                  fontSize: 20, 
                  fontWeight: FontWeight.w900, 
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 10),
              if (onQuickSale != null && product.stockQuantity > 0)
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onQuickSale,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.success.withOpacity(0.2)),
                      ),
                      child: const Icon(Icons.add_shopping_cart_rounded, color: AppColors.success, size: 18),
                    ),
                  ),
                )
              else
                Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary.withOpacity(0.3), size: 24),
            ],
          ),
        ],
      ),
      ),
    );
  }
}

