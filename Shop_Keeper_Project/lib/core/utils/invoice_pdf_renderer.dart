import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:shop_keeper_project/features/billing/model/invoice.dart';
import 'package:shop_keeper_project/core/localization/app_strings.dart';

class InvoicePdfRenderer {
  /// Generates a PDF version of the invoice in Receipt (Roll) format.
  static Future<Uint8List> generateReceipt(Invoice invoice) async {
    final pdf = pw.Document();
    final dateFormat = DateFormat('dd MMM yyyy, hh:mm a');

    // Load fonts (English is standard, Hindi requires external ttf)
    final font = await PdfGoogleFonts.interSemiBold();
    final fontBold = await PdfGoogleFonts.interBold();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.roll57, // Standard 58mm thermal paper
        margin: const pw.EdgeInsets.all(5 * PdfPageFormat.mm),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Center(
                child: pw.Column(
                  children: [
                    pw.Text(AppStrings.get('app_name').toUpperCase(), style: pw.TextStyle(font: fontBold, fontSize: 12)),
                    pw.SizedBox(height: 2),
                    pw.Text('DIGITAL RETAIL TERMINAL', style: pw.TextStyle(font: font, fontSize: 8, color: PdfColors.grey700)),
                    pw.SizedBox(height: 8),
                  ],
                ),
              ),

              pw.Divider(thickness: 0.5, color: PdfColors.grey300),
              pw.SizedBox(height: 4),

              // Transaction Info
              _buildRow(AppStrings.get('date').toUpperCase(), dateFormat.format(invoice.date), font, fontSize: 7),
              if (invoice.customerName != null && invoice.customerName!.isNotEmpty) 
                _buildRow(AppStrings.get('customer_name').toUpperCase(), invoice.customerName!.toUpperCase(), fontBold, fontSize: 7),
              if (invoice.isCreditSale) 
                pw.Center(child: pw.Text('** ${AppStrings.get('udhar').toUpperCase()} **', style: pw.TextStyle(font: fontBold, fontSize: 7, color: PdfColors.red))),
              
              pw.SizedBox(height: 8),
              pw.Divider(thickness: 0.5, borderStyle: pw.BorderStyle.dashed),
              pw.SizedBox(height: 8),

              // Items Header
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(AppStrings.get('item').toUpperCase(), style: pw.TextStyle(font: fontBold, fontSize: 7)),
                  pw.Text(AppStrings.get('total').toUpperCase(), style: pw.TextStyle(font: fontBold, fontSize: 7)),
                ],
              ),
              pw.SizedBox(height: 6),

              // Items
              ...invoice.items.map((item) => pw.Padding(
                padding: const pw.EdgeInsets.only(bottom: 6),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(item.product.name, style: pw.TextStyle(font: font, fontSize: 8)),
                          pw.Text('${item.quantity} x ₹${item.product.sellPrice.toStringAsFixed(2)}', style: pw.TextStyle(font: font, fontSize: 6, color: PdfColors.grey700)),
                        ],
                      ),
                    ),
                    pw.Text('₹${item.total.toStringAsFixed(2)}', style: pw.TextStyle(font: font, fontSize: 8)),
                  ],
                ),
              )),

              pw.SizedBox(height: 8),
              pw.Divider(thickness: 0.5, borderStyle: pw.BorderStyle.dashed),
              pw.SizedBox(height: 8),

              // Totals
              _buildRow(AppStrings.get('total').toUpperCase(), '₹${invoice.subtotal.toStringAsFixed(2)}', font, fontSize: 8),
              if (invoice.discountAmount > 0)
                _buildRow(AppStrings.get('discount').toUpperCase(), '-₹${invoice.discountAmount.toStringAsFixed(2)}', font, fontSize: 8),
              _buildRow('GST (${(invoice.gstRate * 100).toInt()}%)', '+₹${invoice.gstAmount.toStringAsFixed(2)}', font, fontSize: 8),
              
              pw.SizedBox(height: 8),
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                color: PdfColors.grey100,
                child: _buildRow(
                  invoice.isCreditSale ? AppStrings.get('total_on_credit').toUpperCase() : AppStrings.get('total_settled').toUpperCase(),
                  '₹${invoice.totalPayable.toStringAsFixed(2)}',
                  fontBold,
                  fontSize: 10,
                ),
              ),

              pw.SizedBox(height: 20),
              pw.Center(
                child: pw.Column(
                  children: [
                    pw.Text('THANK YOU FOR YOUR VISIT', style: pw.TextStyle(font: font, fontSize: 7)),
                    pw.SizedBox(height: 4),
                    pw.Text('Securely generated via ShopKeeper OS', style: pw.TextStyle(font: font, fontSize: 5, color: PdfColors.grey500)),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildRow(String label, String value, pw.Font font, {double fontSize = 8}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: pw.TextStyle(font: font, fontSize: fontSize)),
          pw.Text(value, style: pw.TextStyle(font: font, fontSize: fontSize)),
        ],
      ),
    );
  }

  /// Directly triggers the system print dialog.
  static Future<void> printInvoice(Invoice invoice) async {
    final pdfBytes = await generateReceipt(invoice);
    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdfBytes);
  }

  /// Triggers the system share dialog for the PDF.
  static Future<void> shareInvoice(Invoice invoice) async {
    final pdfBytes = await generateReceipt(invoice);
    await Printing.sharePdf(bytes: pdfBytes, filename: 'Invoice_${invoice.id.substring(0, 8)}.pdf');
  }
}
