import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shop_keeper_project/core/theme/app_colors.dart';
import 'package:shop_keeper_project/core/theme/app_theme.dart';
import 'package:shop_keeper_project/core/widgets/glass_card.dart';
import 'package:shop_keeper_project/core/localization/app_strings.dart';
import 'package:shop_keeper_project/core/utils/invoice_pdf_renderer.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../model/invoice.dart';

class InvoiceDialog extends StatelessWidget {
  final Invoice invoice;

  const InvoiceDialog({super.key, required this.invoice});

  Future<void> _shareViaWhatsApp(BuildContext context) async {
    final buffer = StringBuffer();
    buffer.writeln('🧾 *SHOPKEEPER PRO INVOICE*');
    buffer.writeln('━━━━━━━━━━━━━━━━━━━━');
    if (invoice.customerName != null && invoice.customerName!.isNotEmpty) {
      buffer.writeln('CLIENT: ${invoice.customerName!.toUpperCase()}');
    }
    buffer.writeln('DATE: ${DateFormat('dd MMM yyyy, hh:mm a').format(invoice.date).toUpperCase()}');
    buffer.writeln('━━━━━━━━━━━━━━━━━━━━');
    buffer.writeln('');
    
    for (final item in invoice.items) {
      buffer.writeln('• ${item.product.name.toUpperCase()}');
      buffer.writeln('  ${item.quantity} × ₹${item.product.sellPrice.toStringAsFixed(2)} = ₹${item.total.toStringAsFixed(2)}');
    }
    
    buffer.writeln('');
    buffer.writeln('━━━━━━━━━━━━━━━━━━━━');
    buffer.writeln('SUBTOTAL: ₹${invoice.subtotal.toStringAsFixed(2)}');
    if (invoice.discountAmount > 0) {
      buffer.writeln('DISCOUNT: -₹${invoice.discountAmount.toStringAsFixed(2)}');
    }
    if (invoice.gstAmount > 0) {
      buffer.writeln('GST (${(invoice.gstRate * 100).toInt()}%): +₹${invoice.gstAmount.toStringAsFixed(2)}');
    }
    buffer.writeln('');
    buffer.writeln('*NET TOTAL: ₹${invoice.totalPayable.toStringAsFixed(2)}*');
    
    if (invoice.isCreditSale) {
      buffer.writeln('');
      buffer.writeln('⚠️ *STATUS: CREDIT TRANSACTION*');
    } else {
      buffer.writeln('');
      buffer.writeln('✅ *STATUS: SETTLED*');
    }
    
    buffer.writeln('');
    buffer.writeln('Generated via ShopKeeper PRO OS 📱');

    final message = Uri.encodeComponent(buffer.toString());
    final whatsappUrl = Uri.parse('https://wa.me/?text=$message');

    if (await canLaunchUrl(whatsappUrl)) {
      await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: AppColors.error,
            content: Text('WHATSAPP NOT DETECTED', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy, hh:mm a');
    final double finalAmount = invoice.totalPayable;
    final int gstRate = (invoice.gstRate * 100).toInt();

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 420, maxHeight: 850),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: AppColors.glassBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.8),
              blurRadius: 60,
              offset: const Offset(0, 30),
            )
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status Header
            Container(
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    (invoice.isCreditSale ? AppColors.error : AppColors.success).withOpacity(0.08),
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
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: (invoice.isCreditSale ? AppColors.error : AppColors.success).withOpacity(0.05),
                      shape: BoxShape.circle,
                      border: Border.all(color: (invoice.isCreditSale ? AppColors.error : AppColors.success).withOpacity(0.1)),
                    ),
                    child: Icon(
                      invoice.isCreditSale ? LucideIcons.alertTriangle : LucideIcons.checkCircle2,
                      color: invoice.isCreditSale ? AppColors.error : AppColors.success,
                      size: 64,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    invoice.isCreditSale ? 'CREDIT TRANSACTION UNLOCKED' : 'TRANSACTION SECURELY SETTLED',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: invoice.isCreditSale ? AppColors.error : AppColors.success,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    dateFormat.format(invoice.date).toUpperCase(),
                    style: GoogleFonts.outfit(color: AppColors.textMuted, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1),
                  ),
                ],
              ),
            ),
            
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (invoice.customerName != null && invoice.customerName!.isNotEmpty) ...[
                      Text('CLIENT IDENTIFIED', style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w900, color: AppColors.textMuted, letterSpacing: 2)),
                      const SizedBox(height: 12),
                      Text(
                        invoice.customerName!.toUpperCase(),
                        style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 20, color: AppColors.textPrimary, letterSpacing: -0.5),
                      ),
                      const Divider(color: AppColors.glassBorder, height: 40),
                    ],

                    Text('MANIFEST ITEMS', style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w900, color: AppColors.textMuted, letterSpacing: 2)),
                    const SizedBox(height: 24),
                    
                    ...invoice.items.map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 20.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              '${item.quantity}', 
                              style: GoogleFonts.outfit(color: AppColors.primary, fontWeight: FontWeight.w900, fontSize: 12)
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.product.name.toUpperCase(),
                                  style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'UNIT PRICE: ₹${item.product.sellPrice.toStringAsFixed(2)}',
                                  style: GoogleFonts.outfit(fontSize: 10, color: AppColors.textMuted, fontWeight: FontWeight.w700),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '₹${item.total.toStringAsFixed(2)}',
                            style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
                          ),
                        ],
                      ),
                    )),
                    
                    const SizedBox(height: 8),
                    const Divider(color: AppColors.glassBorder, height: 40),
                    
                    _buildSummaryRow('GROSS AMOUNT', '₹${invoice.subtotal.toStringAsFixed(2)}', AppColors.textMuted),
                    if (invoice.discountAmount > 0) ...[
                      const SizedBox(height: 12),
                      _buildSummaryRow('APPLIED DISCOUNT', '-₹${invoice.discountAmount.toStringAsFixed(2)}', AppColors.success),
                    ],
                    if (invoice.gstAmount > 0) ...[
                      const SizedBox(height: 12),
                      _buildSummaryRow('GST ($gstRate%)', '+₹${invoice.gstAmount.toStringAsFixed(2)}', AppColors.textMuted),
                    ],
                    
                    const SizedBox(height: 32),
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: (invoice.isCreditSale ? AppColors.error : AppColors.primary).withOpacity(0.1)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            invoice.isCreditSale ? 'CREDIT DUE' : 'NET TOTAL',
                            style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w900, color: AppColors.textMuted, letterSpacing: 1),
                          ),
                          Text(
                            '₹${finalAmount.toStringAsFixed(2)}',
                            style: GoogleFonts.outfit(
                              fontSize: 28, fontWeight: FontWeight.w900,
                              color: invoice.isCreditSale ? AppColors.error : AppColors.primary,
                              letterSpacing: -1,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
            
            // Actions Terminal
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildActionButton(
                          onTap: () => _shareViaWhatsApp(context),
                          icon: LucideIcons.messageSquare,
                          label: 'WHATSAPP',
                          color: const Color(0xFF25D366),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildActionButton(
                          onTap: () => InvoicePdfRenderer.shareInvoice(invoice),
                          icon: LucideIcons.share2,
                          label: 'SHARE PDF',
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: AppColors.goldGradient,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          )
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          InvoicePdfRenderer.printInvoice(invoice);
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(LucideIcons.printer, color: Colors.black, size: 20),
                            const SizedBox(width: 12),
                            Text(
                              'CONFIRM & PRINT RECEIPT', 
                              style: GoogleFonts.outfit(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1)
                            ),
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

  Widget _buildActionButton({required VoidCallback onTap, required IconData icon, required String label, required Color color}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: color.withOpacity(0.05),
            border: Border.all(color: color.withOpacity(0.1)),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 10),
              Text(
                label, 
                style: GoogleFonts.outfit(color: color, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1)
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, Color valueColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label, 
          style: GoogleFonts.outfit(color: AppColors.textMuted, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.5)
        ),
        Text(
          value, 
          style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 13, color: valueColor)
        ),
      ],
    );
  }
}

