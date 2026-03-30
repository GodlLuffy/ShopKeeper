import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shop_keeper_project/core/theme/app_theme.dart';
import 'package:shop_keeper_project/core/widgets/glass_card.dart';
import '../bloc/billing_bloc.dart';
import '../bloc/billing_event.dart';
import '../model/cart_item.dart';

class CartListView extends StatelessWidget {
  final List<CartItem> items;

  const CartListView({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: AppTheme.primaryIndigo.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.shopping_cart_outlined, size: 80, color: AppTheme.primaryIndigo.withOpacity(0.2)),
            ),
            const SizedBox(height: 24),
            const Text(
              "YOUR CART IS EMPTY",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppTheme.textMuted, letterSpacing: 2),
            ),
            const SizedBox(height: 8),
            const Text(
              "Scan barcodes or search products\nto start a new transaction",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppTheme.textGrey, height: 1.5),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: items.length,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemBuilder: (context, index) {
        final item = items[index];
        return GlassCard(
          margin: const EdgeInsets.only(bottom: 12.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppTheme.primaryIndigo.withOpacity(0.1), Colors.transparent],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.primaryIndigo.withOpacity(0.1)),
                  ),
                  child: const Icon(Icons.inventory_2_rounded, color: AppTheme.primaryIndigo, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.product.name.toUpperCase(),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.textWhite, letterSpacing: 0.5),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Text(
                            "₹${item.product.sellPrice.toStringAsFixed(2)}",
                            style: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 6.0),
                            child: Text("×", style: TextStyle(color: AppTheme.textGrey, fontSize: 12)),
                          ),
                          Text(
                            "${item.quantity}",
                            style: const TextStyle(color: AppTheme.textWhite, fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "₹${item.total.toStringAsFixed(2)}",
                        style: const TextStyle(color: AppTheme.accentTeal, fontWeight: FontWeight.w900, fontSize: 16),
                      ),
                    ],
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: AppTheme.darkBackgroundMain.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.white.withOpacity(0.05)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildQuantityButton(
                        icon: Icons.remove_rounded,
                        color: AppTheme.textMuted,
                        onPressed: () {
                          context.read<BillingBloc>().add(UpdateCartQuantity(item.product, item.quantity - 1));
                        },
                      ),
                      SizedBox(
                        width: 24,
                        child: Text(
                          '${item.quantity}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textWhite),
                        ),
                      ),
                      _buildQuantityButton(
                        icon: Icons.add_rounded,
                        color: AppTheme.accentTeal,
                        onPressed: () {
                          if (item.quantity < item.product.stockQuantity) {
                            context.read<BillingBloc>().add(UpdateCartQuantity(item.product, item.quantity + 1));
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Max stock reached'), duration: Duration(seconds: 1)),
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

  Widget _buildQuantityButton({required IconData icon, required Color color, required VoidCallback onPressed}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(30),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(icon, size: 20, color: color),
        ),
      ),
    );
  }
}
