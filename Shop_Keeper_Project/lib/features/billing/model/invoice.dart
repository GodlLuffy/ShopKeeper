import 'cart_item.dart';
import 'billing_summary.dart';

class Invoice {
  final String id;
  final List<CartItem> items;
  final String? customerName;
  final String? customerId; 
  final DateTime date;
  final double discountAmount;
  final double gstAmount;
  final double gstRate;
  final double subtotal;
  final double totalPayable;
  final bool isCreditSale; 

  Invoice({
    required this.id,
    required this.items,
    this.customerName,
    this.customerId,
    required this.date,
    this.discountAmount = 0,
    this.gstAmount = 0,
    this.gstRate = 0.18,
    required this.subtotal,
    required this.totalPayable,
    this.isCreditSale = false,
  });

  double get totalAmount => items.fold(0.0, (sum, item) => sum + item.total);

  /// Create invoice from BillingSummary
  factory Invoice.fromSummary({
    required String id,
    required BillingSummary summary,
    String? customerName,
    String? customerId,
    bool isCreditSale = false,
  }) {
    return Invoice(
      id: id,
      items: List.from(summary.items),
      customerName: customerName,
      customerId: customerId,
      date: DateTime.now(),
      discountAmount: summary.discountAmount,
      gstAmount: summary.gstAmount,
      gstRate: summary.tax.gstRate,
      subtotal: summary.subtotal,
      totalPayable: summary.totalPayable,
      isCreditSale: isCreditSale,
    );
  }
}
