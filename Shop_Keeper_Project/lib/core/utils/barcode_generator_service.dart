import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:barcode_widget/barcode_widget.dart';

enum BarcodeType {
  ean13,
  qr,
}

class BarcodeGeneratorService {
  
  String generateEan13CheckDigit(String code) {
    if (code.length != 12) {
      return code;
    }
    
    int sum = 0;
    for (int i = 0; i < 12; i++) {
      final digit = int.tryParse(code[i]) ?? 0;
      sum += (i % 2 == 0) ? digit : digit * 3;
    }
    
    final checkDigit = (10 - (sum % 10)) % 10;
    return '$code$checkDigit';
  }
  
  String? validateAndFixBarcode(String? barcode) {
    if (barcode == null || barcode.isEmpty) {
      return null;
    }
    
    final cleaned = barcode.replaceAll(RegExp(r'[^0-9]'), '');
    
    if (cleaned.isEmpty) {
      return null;
    }
    
    if (cleaned.length == 12) {
      return generateEan13CheckDigit(cleaned);
    }
    
    if (cleaned.length == 13) {
      return cleaned;
    }
    
    return cleaned.length >= 4 ? cleaned : null;
  }
  
  Barcode getBarcodeType(BarcodeType type) {
    switch (type) {
      case BarcodeType.ean13:
        return Barcode.ean13();
      case BarcodeType.qr:
        return Barcode.qrCode();
    }
  }
  
  Uint8List? generateBarcodeImage({
    required String data,
    required BarcodeType type,
    double width = 300,
    double height = 100,
  }) {
    return null;
  }
  
  Widget buildBarcodeWidget({
    required String data,
    required BarcodeType type,
    double width = 300,
    double height = 100,
    bool showText = true,
    Color? color,
    Color? backgroundColor,
  }) {
    final barcode = getBarcodeType(type);
    
    return BarcodeWidget(
      barcode: barcode,
      data: data,
      width: width,
      height: height,
      drawText: showText,
      color: color ?? Colors.white,
      backgroundColor: backgroundColor ?? Colors.transparent,
      errorBuilder: (context, error) => Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          'Invalid barcode data',
          style: TextStyle(color: Colors.red.shade300, fontSize: 12),
        ),
      ),
    );
  }
  
  bool isValidEan13(String code) {
    if (code.length != 13) return false;
    
    if (!RegExp(r'^[0-9]{13}$').hasMatch(code)) return false;
    
    int sum = 0;
    for (int i = 0; i < 12; i++) {
      final digit = int.parse(code[i]);
      sum += (i % 2 == 0) ? digit : digit * 3;
    }
    
    final checkDigit = (10 - (sum % 10)) % 10;
    return checkDigit == int.parse(code[12]);
  }
  
  List<BarcodeType> get supportedTypes => BarcodeType.values;
  
  String getTypeName(BarcodeType type) {
    switch (type) {
      case BarcodeType.ean13:
        return 'EAN-13';
      case BarcodeType.qr:
        return 'QR Code';
    }
  }
}
