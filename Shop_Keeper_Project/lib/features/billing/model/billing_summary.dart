import 'package:shop_keeper_project/features/billing/model/cart_item.dart';

/// Tax configuration for billing
class TaxConfig {
  final double gstRate; // e.g. 0.18 for 18%
  final bool enableGst;

  const TaxConfig({
    this.gstRate = 0.18,
    this.enableGst = true,
  });
}

/// Discount can be percentage-based or flat amount
class DiscountConfig {
  final double percentage; // 0–100
  final double flatAmount;

  const DiscountConfig({
    this.percentage = 0.0,
    this.flatAmount = 0.0,
  });

  bool get hasDiscount => percentage > 0 || flatAmount > 0;
}

/// Complete billing summary with tax & discount breakdown
class BillingSummary {
  final List<CartItem> items;
  final double subtotal;
  final DiscountConfig discount;
  final TaxConfig tax;

  const BillingSummary({
    required this.items,
    required this.subtotal,
    this.discount = const DiscountConfig(),
    this.tax = const TaxConfig(),
  });

  /// Discount amount (percentage applied first, then flat)
  double get discountAmount {
    double d = 0;
    if (discount.percentage > 0) {
      d += subtotal * (discount.percentage / 100);
    }
    d += discount.flatAmount;
    // Discount cannot exceed subtotal
    return d > subtotal ? subtotal : d;
  }

  /// Amount after discount
  double get afterDiscount => subtotal - discountAmount;

  /// GST amount (on discounted price)
  double get gstAmount => tax.enableGst ? afterDiscount * tax.gstRate : 0;

  /// Final payable amount
  double get totalPayable => afterDiscount + gstAmount;

  /// Total profit (sell - buy) before tax
  double get totalProfit => items.fold(0.0, (sum, item) =>
      sum + (item.product.sellPrice - item.product.buyPrice) * item.quantity);
}
