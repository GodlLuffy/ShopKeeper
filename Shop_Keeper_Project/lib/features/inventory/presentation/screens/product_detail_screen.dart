import 'package:flutter/material.dart';
import 'package:shop_keeper_project/features/inventory/domain/entities/product_entity.dart';
import 'package:shop_keeper_project/core/theme/app_theme.dart';
import 'package:shop_keeper_project/core/widgets/glass_card.dart';

class ProductDetailScreen extends StatelessWidget {
  final ProductEntity product;
  const ProductDetailScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(product.name)),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            GlassCard(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    const Icon(Icons.inventory_2, size: 60, color: AppTheme.primaryColor),
                    const SizedBox(height: 16),
                    Text(product.name, style: Theme.of(context).textTheme.headlineMedium),
                    Text(product.category, style: const TextStyle(color: Colors.grey)),
                    const Divider(height: 40),
                    _buildDetailRow('Buy Price', '₹${product.buyPrice}'),
                    _buildDetailRow('Sell Price', '₹${product.sellPrice}', color: AppTheme.successColor),
                    _buildDetailRow('Profit per item', '₹${product.sellPrice - product.buyPrice}', color: AppTheme.primaryColor),
                    const Divider(height: 40),
                    _buildDetailRow('In Stock', '${product.stockQuantity}', bold: true),
                    _buildDetailRow('Alert Level', '${product.minStockAlert}', color: AppTheme.errorColor),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Navigate to logic for updating stock
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                    child: const Text('Update Stock'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? color, bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16)),
          Text(value, style: TextStyle(
            fontSize: 18, 
            fontWeight: bold ? FontWeight.bold : FontWeight.w600,
            color: color
          )),
        ],
      ),
    );
  }
}
