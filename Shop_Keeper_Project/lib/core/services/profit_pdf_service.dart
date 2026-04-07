import 'dart:io';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:shop_keeper_project/features/sales/domain/entities/sale_entity.dart';

class ProfitPdfService {
  static Future<void> generateProfitReport({
    required List<SaleEntity> sales,
    required DateTime date,
    bool isDaily = true,
  }) async {
    final pdf = pw.Document();

    final totalRevenue = sales.fold<double>(0, (sum, s) => sum + s.totalAmount);
    final totalProfit = sales.fold<double>(0, (sum, s) => sum + s.totalProfit);
    final totalCost = totalRevenue - totalProfit;
    final margin = totalRevenue > 0 ? (totalProfit / totalRevenue * 100) : 0.0;

    // Load Font for better appearance
    final font = await PdfGoogleFonts.outfitMedium();
    final boldFont = await PdfGoogleFonts.outfitBold();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            // Header
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'SHOPKEEPER PRO',
                      style: pw.TextStyle(
                        font: boldFont,
                        fontSize: 24,
                        color: PdfColors.amber700,
                      ),
                    ),
                    pw.Text(
                      'EXECUTIVE AUDIT REPORT',
                      style: pw.TextStyle(
                        font: font,
                        fontSize: 10,
                        color: PdfColors.grey700,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text(
                      isDaily ? 'DAILY PROFIT AUDIT' : 'MONTHLY PROFIT AUDIT',
                      style: pw.TextStyle(font: boldFont, fontSize: 12),
                    ),
                    pw.Text(
                      DateFormat(isDaily ? 'dd MMMM, yyyy' : 'MMMM, yyyy').format(date),
                      style: pw.TextStyle(font: font, fontSize: 10),
                    ),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 32),
            pw.Divider(thickness: 1, color: PdfColors.grey300),
            pw.SizedBox(height: 32),

            // Financial Summary
            pw.Row(
              children: [
                _buildSummaryItem('TOTAL REVENUE', '₹${totalRevenue.toStringAsFixed(2)}', PdfColors.blueGrey900, boldFont, font),
                pw.SizedBox(width: 24),
                _buildSummaryItem('TOTAL COST', '₹${totalCost.toStringAsFixed(2)}', PdfColors.red900, boldFont, font),
                pw.SizedBox(width: 24),
                _buildSummaryItem('NET PROFIT', '₹${totalProfit.toStringAsFixed(2)}', PdfColors.green900, boldFont, font),
                pw.SizedBox(width: 24),
                _buildSummaryItem('MARGIN', '${margin.toStringAsFixed(1)}%', PdfColors.teal900, boldFont, font),
              ],
            ),
            pw.SizedBox(height: 48),

            // Transactions Table
            pw.Text(
              'TRANSACTION LEDGER',
              style: pw.TextStyle(font: boldFont, fontSize: 12, letterSpacing: 1),
            ),
            pw.SizedBox(height: 16),
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey200, width: 0.5),
              columnWidths: {
                0: const pw.FlexColumnWidth(3),
                1: const pw.FlexColumnWidth(1),
                2: const pw.FlexColumnWidth(1.5),
                3: const pw.FlexColumnWidth(1.5),
                4: const pw.FlexColumnWidth(1.5),
              },
              children: [
                // Table Header
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey100),
                  children: [
                    _buildTableCell('PRODUCT / SERVICE', boldFont, isHeader: true),
                    _buildTableCell('QTY', boldFont, isHeader: true, align: pw.TextAlign.center),
                    _buildTableCell('SALE PRICE', boldFont, isHeader: true, align: pw.TextAlign.right),
                    _buildTableCell('TOTAL', boldFont, isHeader: true, align: pw.TextAlign.right),
                    _buildTableCell('PROFIT', boldFont, isHeader: true, align: pw.TextAlign.right),
                  ],
                ),
                // Table Data
                ...sales.map((sale) {
                  return pw.TableRow(
                    children: [
                      _buildTableCell(sale.productName.toUpperCase(), font),
                      _buildTableCell(sale.quantitySold.toString(), font, align: pw.TextAlign.center),
                      _buildTableCell('₹${sale.salePrice.toStringAsFixed(2)}', font, align: pw.TextAlign.right),
                      _buildTableCell('₹${sale.totalAmount.toStringAsFixed(2)}', font, align: pw.TextAlign.right),
                      _buildTableCell('₹${sale.totalProfit.toStringAsFixed(2)}', font, align: pw.TextAlign.right),
                    ],
                  );
                }),
              ],
            ),
            pw.SizedBox(height: 64),

            // Footer
            pw.Divider(thickness: 0.5, color: PdfColors.grey200),
            pw.SizedBox(height: 16),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'GENERATED VIA SHOPKEEPER PRO OS',
                  style: pw.TextStyle(font: font, fontSize: 8, color: PdfColors.grey500),
                ),
                pw.Text(
                  'DEVELOPED BY ANUP',
                  style: pw.TextStyle(font: boldFont, fontSize: 8, color: PdfColors.grey700),
                ),
              ],
            ),
          ];
        },
      ),
    );

    // Save or Print
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Profit_Report_${DateFormat('yyyyMMdd').format(date)}.pdf',
    );
  }

  static pw.Widget _buildSummaryItem(String label, String value, PdfColor color, pw.Font boldFont, pw.Font font) {
    return pw.Expanded(
      child: pw.Container(
        padding: const pw.EdgeInsets.all(12),
        decoration: pw.BoxDecoration(
          color: PdfColors.grey50,
          border: pw.Border.all(color: PdfColors.grey200),
          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              label,
              style: pw.TextStyle(font: font, fontSize: 7, color: PdfColors.grey600, letterSpacing: 1),
            ),
            pw.SizedBox(height: 6),
            pw.Text(
              value,
              style: pw.TextStyle(font: boldFont, fontSize: 13, color: color),
            ),
          ],
        ),
      ),
    );
  }

  static pw.Widget _buildTableCell(String text, pw.Font font, {bool isHeader = false, pw.TextAlign align = pw.TextAlign.left}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        textAlign: align,
        style: pw.TextStyle(
          font: font,
          fontSize: isHeader ? 9 : 8,
          color: isHeader ? PdfColors.black : PdfColors.grey900,
        ),
      ),
    );
  }
}
