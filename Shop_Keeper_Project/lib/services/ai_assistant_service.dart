import 'package:shop_keeper_project/database/tables/sale_table.dart';
import 'package:shop_keeper_project/database/tables/expense_table.dart';
import 'package:shop_keeper_project/database/tables/product_table.dart';
import 'package:hive/hive.dart';

class AIAssistantService {
  final Box<SaleTable> saleBox;
  final Box<ExpenseTable> expenseBox;
  final Box<ProductTable> productBox;

  AIAssistantService({
    required this.saleBox,
    required this.expenseBox,
    required this.productBox,
  });

  Future<String> processQuery(String query) async {
    final lowerQuery = query.toLowerCase();

    // 1. Stock Queries
    if (lowerQuery.contains('stock') || lowerQuery.contains('low')) {
      final lowStockItems = productBox.values.where((p) => p.stockQuantity <= p.minStockAlert).toList();
      if (lowStockItems.isEmpty) {
        return "All items are well-stocked! No low stock alerts.";
      }
      final items = lowStockItems.map((p) => "${p.name} (${p.stockQuantity})").join(", ");
      return "Low stock alert: $items need to be reordered.";
    }

    // 2. Profit/Sales Queries
    if (lowerQuery.contains('profit') || lowerQuery.contains('sales') || lowerQuery.contains('earned')) {
      final now = DateTime.now();
      final todaySales = saleBox.values.where((s) => _isSameDay(s.date, now)).toList();
      final todayExpenses = expenseBox.values.where((e) => _isSameDay(e.date, now)).toList();

      double totalSales = todaySales.fold(0.0, (sum, item) => sum + item.totalAmount);
      double totalExpenses = todayExpenses.fold(0.0, (sum, item) => sum + item.amount);
      double netProfit = todaySales.fold(0.0, (sum, item) => sum + item.totalProfit) - totalExpenses;

      if (lowerQuery.contains('today')) {
        return "Today, you made ₹${totalSales.toStringAsFixed(2)} in sales. After expenses of ₹${totalExpenses.toStringAsFixed(2)}, your net profit is ₹${netProfit.toStringAsFixed(2)}.";
      }
      
      return "You have total sales of ₹${totalSales.toStringAsFixed(2)} logged today.";
    }

    // 3. Greeting / Help
    if (lowerQuery.contains('hi') || lowerQuery.contains('hello')) {
      return "Hello Shopkeeper! I can help you with stock alerts, daily profit reports, and expense tracking. What would you like to know?";
    }

    return "I'm sorry, I'm still learning. Try asking about 'today's profit', 'low stock', or 'total sales'.";
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year && date1.month == date2.month && date1.day == date2.day;
  }
}
