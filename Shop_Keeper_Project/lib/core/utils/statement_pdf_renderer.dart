import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:shop_keeper_project/features/sales/domain/entities/sale_entity.dart';

class StatementPdfRenderer {
  static Future<void> shareStatement({
    required List<SaleEntity> sales,
    required DateTime startDate,
    required DateTime endDate,
    required String shopName,
    required String periodName,
  }) async {
    final pdfBytes = await generateStatement(
      sales: sales,
      startDate: startDate,
      endDate: endDate,
      shopName: shopName,
      periodName: periodName,
    );

    final filename = 'Statement_${periodName.replaceAll(' ', '_')}_${DateFormat('yyyyMMdd').format(DateTime.now())}.pdf';
    await Printing.sharePdf(bytes: pdfBytes, filename: filename);
  }

  static Future<Uint8List> generateStatement({
    required List<SaleEntity> sales,
    required DateTime startDate,
    required DateTime endDate,
    required String shopName,
    required String periodName,
  }) async {
    final pdf = pw.Document();
    
    // Sort sales by date
    sales.sort((a, b) => b.date.compareTo(a.date));

    final totalRevenue = sales.fold<double>(0, (sum, s) => sum + s.totalAmount);
    final totalProfit = sales.fold<double>(0, (sum, s) => sum + s.totalProfit);
    final totalItems = sales.fold<int>(0, (sum, s) => sum + s.quantitySold);

    final font = await PdfGoogleFonts.interRegular();
    final fontBold = await PdfGoogleFonts.interBold();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (context) => pw.Column(
          children: [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(shopName.toUpperCase(), style: pw.TextStyle(font: fontBold, fontSize: 18, color: PdfColors.indigo900)),
                    pw.Text('RETAIL ANALYTICS STATEMENT', style: pw.TextStyle(font: font, fontSize: 10, color: PdfColors.grey700, letterSpacing: 1.5)),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text(periodName.toUpperCase(), style: pw.TextStyle(font: fontBold, fontSize: 12, color: PdfColors.teal700)),
                    pw.Text(
                      '${DateFormat('dd MMM yyyy').format(startDate)} - ${DateFormat('dd MMM yyyy').format(endDate)}',
                      style: pw.TextStyle(font: font, fontSize: 8, color: PdfColors.grey600),
                    ),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 10),
            pw.Divider(thickness: 1, color: PdfColors.grey300),
            pw.SizedBox(height: 20),
          ],
        ),
        footer: (context) => pw.Column(
          children: [
            pw.Divider(thickness: 0.5, color: PdfColors.grey300),
            pw.SizedBox(height: 10),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('ShopKeeper PRO • Secure Business Intelligence', style: pw.TextStyle(font: font, fontSize: 7, color: PdfColors.grey500)),
                pw.Text('Page ${context.pageNumber} of ${context.pagesCount}', style: pw.TextStyle(font: font, fontSize: 7, color: PdfColors.grey500)),
                pw.Text('Generated: ${DateFormat('dd MMM yyyy, HH:mm').format(DateTime.now())}', style: pw.TextStyle(font: font, fontSize: 7, color: PdfColors.grey500)),
              ],
            ),
          ],
        ),
        build: (context) => [
          // Summary Dashboard
          pw.Row(
            children: [
              _buildStatBox('TOTAL REVENUE', '₹${totalRevenue.toStringAsFixed(2)}', PdfColors.indigo800, fontBold, font),
              pw.SizedBox(width: 16),
              _buildStatBox('TOTAL PROFIT', '₹${totalProfit.toStringAsFixed(2)}', PdfColors.teal800, fontBold, font),
              pw.SizedBox(width: 16),
              _buildStatBox('UNITS SOLD', '$totalItems', PdfColors.grey800, fontBold, font),
            ],
          ),
          pw.SizedBox(height: 32),

          // Detailed Table Header
          pw.Text('TRANSACTION LOG', style: pw.TextStyle(font: fontBold, fontSize: 10, color: PdfColors.grey800, letterSpacing: 1)),
          pw.SizedBox(height: 12),

          // Table
          pw.TableHelper.fromTextArray(
            headerStyle: pw.TextStyle(font: fontBold, fontSize: 8, color: PdfColors.white),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.indigo900),
            cellStyle: pw.TextStyle(font: font, fontSize: 8),
            oddRowDecoration: const pw.BoxDecoration(color: PdfColors.grey100),
            cellAlignment: pw.Alignment.centerLeft,
            headerAlignment: pw.Alignment.centerLeft,
            headers: ['DATE', 'PRODUCT', 'QTY', 'PRICE', 'TOTAL', 'PROFIT'],
            data: sales.map((sale) => [
              DateFormat('dd/MM/yy').format(sale.date),
              sale.productName,
              sale.quantitySold.toString(),
              '₹${sale.salePrice.toStringAsFixed(2)}',
              '₹${sale.totalAmount.toStringAsFixed(2)}',
              '₹${sale.totalProfit.toStringAsFixed(2)}',
            ]).toList(),
          ),
          
          pw.Padding(
            padding: const pw.EdgeInsets.symmetric(vertical: 20),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.end,
              children: [
                pw.Container(
                  width: 200,
                  padding: const pw.EdgeInsets.all(12),
                  decoration: const pw.BoxDecoration(
                    color: PdfColors.grey50,
                    border: pw.Border(left: pw.BorderSide(color: PdfColors.indigo900, width: 2)),
                  ),
                  child: pw.Column(
                    children: [
                      _buildSummaryLine('GROSS REVENUE', '₹${totalRevenue.toStringAsFixed(2)}', fontBold, font),
                      pw.SizedBox(height: 4),
                      _buildSummaryLine('NET PROFIT', '₹${totalProfit.toStringAsFixed(2)}', fontBold, font, isHighlight: true),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildStatBox(String label, String value, PdfColor color, pw.Font fontBold, pw.Font font) {
    return pw.Expanded(
      child: pw.Container(
        padding: const pw.EdgeInsets.all(12),
        decoration: pw.BoxDecoration(
          color: color.luminance > 0.5 ? PdfColors.white : PdfColor(color.red, color.green, color.blue, 0.05),
          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
          border: pw.Border.all(color: PdfColor(color.red, color.green, color.blue, 0.2), width: 1),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(label, style: pw.TextStyle(font: font, fontSize: 7, color: color, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 4),
            pw.Text(value, style: pw.TextStyle(font: fontBold, fontSize: 14, color: color)),
          ],
        ),
      ),
    );
  }

  static pw.Widget _buildSummaryLine(String label, String value, pw.Font fontBold, pw.Font font, {bool isHighlight = false}) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(label, style: pw.TextStyle(font: isHighlight ? fontBold : font, fontSize: 8)),
        pw.Text(value, style: pw.TextStyle(font: fontBold, fontSize: isHighlight ? 10 : 8, color: isHighlight ? PdfColors.teal900 : PdfColors.black)),
      ],
    );
  }
}
