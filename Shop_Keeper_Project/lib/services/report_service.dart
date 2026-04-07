import 'package:hive_flutter/hive_flutter.dart';
import 'package:shop_keeper_project/database/tables/inventory_log_table.dart';

class ReportService {
  final Box<InventoryLogTable> logBox;

  ReportService(this.logBox);

  Map<String, dynamic> generateMonthlyReport() {
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    
    int totalAdded = 0;
    int totalRemoved = 0;
    
    // Map of productName to net change
    Map<String, int> productMovements = {};

    for (var log in logBox.values) {
      if (log.timestamp.isAfter(firstDayOfMonth) || log.timestamp.isAtSameMomentAs(firstDayOfMonth)) {
        if (log.quantity > 0) {
          totalAdded += log.quantity;
        } else if (log.quantity < 0) {
          totalRemoved += log.quantity.abs();
        }
        
        productMovements[log.productName] = (productMovements[log.productName] ?? 0) + log.quantity;
      }
    }

    return {
      'movements': productMovements,
      'totalAdded': totalAdded,
      'totalRemoved': totalRemoved,
    };
  }
}
