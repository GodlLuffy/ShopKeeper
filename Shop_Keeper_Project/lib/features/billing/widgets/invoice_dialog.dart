import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../model/invoice.dart';
import 'package:shop_keeper_project/core/theme/app_theme.dart';
import 'package:shop_keeper_project/core/localization/app_strings.dart';
import 'package:shop_keeper_project/core/utils/invoice_pdf_renderer.dart';

class InvoiceDialog extends StatelessWidget {
  final Invoice invoice;

  const InvoiceDialog({super.key, required this.invoice});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy, hh:mm a');
    
    final double subtotal = invoice.subtotal;
    final double discount = invoice.discountAmount;
    final double gst = invoice.gstAmount;
    final double finalAmount = invoice.totalPayable;
    final int gstRate = (invoice.gstRate * 100).toInt();

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 750),
        decoration: BoxDecoration(
          color: AppTheme.darkBackgroundLayer,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 40,
              offset: const Offset(0, 20),
            )
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Premium Header
            Container(
              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    invoice.isCreditSale
                        ? AppTheme.dangerRose.withOpacity(0.1)
                        : AppTheme.successEmerald.withOpacity(0.1),
                    Colors.transparent
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: (invoice.isCreditSale ? AppTheme.dangerRose : AppTheme.successEmerald).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      invoice.isCreditSale ? Icons.credit_card_rounded : Icons.verified_rounded,
                      color: invoice.isCreditSale ? AppTheme.dangerRose : AppTheme.successEmerald,
                      size: 56,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    invoice.isCreditSale ? AppStrings.get('credit_transaction') : AppStrings.get('transaction_verified'),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: invoice.isCreditSale ? AppTheme.dangerRose : AppTheme.successEmerald,
                      letterSpacing: 2,
                    ),
                  ),
                  if (invoice.isCreditSale) ...[
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.dangerRose.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${AppStrings.get('udhar')} — ${AppStrings.get('manage_udhar_hint')}',
                        style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: AppTheme.dangerRose, letterSpacing: 1.5),
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Text(
                    dateFormat.format(invoice.date),
                    style: const TextStyle(color: AppTheme.textMuted, fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (invoice.customerName != null && invoice.customerName!.isNotEmpty) ...[
                      Text(AppStrings.get('bill_to'), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppTheme.textMuted, letterSpacing: 1.5)),
                      const SizedBox(height: 8),
                      Text(
                        invoice.customerName!.toUpperCase(),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppTheme.textWhite, letterSpacing: -0.5),
                      ),
                      const Divider(color: Colors.white10, height: 32),
                    ],

                    Text(AppStrings.get('inventory_items'), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppTheme.textMuted, letterSpacing: 1.5)),
                    const SizedBox(height: 16),
                    
                    ...invoice.items.map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.product.name,
                                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppTheme.textWhite),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${item.quantity} units × ₹${item.product.sellPrice.toStringAsFixed(2)}',
                                  style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '₹${item.total.toStringAsFixed(2)}',
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textWhite),
                          ),
                        ],
                      ),
                    )),
                    
                    const SizedBox(height: 8),
                    const Divider(color: Colors.white10, height: 32, thickness: 1),
                    
                    _buildSummaryRow(AppStrings.get('base_amount'), '₹${subtotal.toStringAsFixed(2)}', AppTheme.textGrey),
                    if (discount > 0) ...[
                      const SizedBox(height: 12),
                      _buildSummaryRow(AppStrings.get('discount'), '-₹${discount.toStringAsFixed(2)}', AppTheme.successEmerald),
                    ],
                    if (gst > 0) ...[
                      const SizedBox(height: 12),
                      _buildSummaryRow('GST ($gstRate%)', '+₹${gst.toStringAsFixed(2)}', AppTheme.textGrey),
                    ],
                    
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppTheme.darkBackgroundMain.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: (invoice.isCreditSale ? AppTheme.dangerRose : AppTheme.primaryIndigo).withOpacity(0.2)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            invoice.isCreditSale ? AppStrings.get('total_on_credit') : AppStrings.get('total_settled'),
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.textGrey, letterSpacing: 1),
                          ),
                          Text(
                            '₹${finalAmount.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 26, fontWeight: FontWeight.w900,
                              color: invoice.isCreditSale ? AppTheme.dangerRose : AppTheme.accentTeal,
                              letterSpacing: -1,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            
            // Premium Actions
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                children: [
                  Expanded(
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => InvoicePdfRenderer.shareInvoice(invoice),
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppTheme.textMuted.withOpacity(0.3)),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.share_rounded, color: AppTheme.textWhite, size: 20),
                              const SizedBox(width: 8),
                              Text(AppStrings.get('share'), style: const TextStyle(color: AppTheme.textWhite, fontWeight: FontWeight.bold, fontSize: 13)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: const LinearGradient(
                          colors: [AppTheme.primaryIndigo, AppTheme.accentTeal],
                        ),
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          InvoicePdfRenderer.printInvoice(invoice);
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.print_rounded, color: Colors.white, size: 20),
                            const SizedBox(width: 8),
                            Text(AppStrings.get('confirm_print'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, Color valueColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppTheme.textMuted, fontSize: 14)),
        Text(value, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: valueColor)),
      ],
    );
  }
}
