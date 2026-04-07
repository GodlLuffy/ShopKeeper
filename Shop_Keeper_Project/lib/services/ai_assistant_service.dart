import 'package:shop_keeper_project/database/tables/sale_table.dart';
import 'package:shop_keeper_project/database/tables/expense_table.dart';
import 'package:shop_keeper_project/database/tables/product_table.dart';
import 'package:shop_keeper_project/database/tables/customer_table.dart';
import 'package:hive/hive.dart';

class AIAssistantService {
  final Box<SaleTable> saleBox;
  final Box<ExpenseTable> expenseBox;
  final Box<ProductTable> productBox;
  final Box<CustomerTable>? customerBox;

  AIAssistantService({
    required this.saleBox,
    required this.expenseBox,
    required this.productBox,
    this.customerBox,
  });

  Future<String> processQuery(String query) async {
    final lowerQuery = query.toLowerCase();

    if (_matches(lowerQuery, ['hi', 'hello', 'hey', 'namaste'])) {
      return "🙏 Namaste Shopkeeper! I'm your AI assistant.\n\nI can help you with:\n• Stock alerts and inventory insights\n• Profit and sales reports\n• Customer udhar status\n• Expense tracking\n\nWhat would you like to know?";
    }

    if (_matches(lowerQuery, ['help', 'commands', 'what can you do'])) {
      return "🧠 **Available Commands:**\n\n"
          "📦 **Inventory:**\n"
          "• 'low stock' - Items needing reorder\n"
          "• 'zero stock' - Out of stock items\n"
          "• 'stock alert' - All stock warnings\n\n"
          "💰 **Finance:**\n"
          "• 'today's profit' - Daily P&L\n"
          "• 'total sales' - Sales summary\n"
          "• 'expenses today' - Daily expenses\n"
          "• 'weekly report' - This week's stats\n\n"
          "👥 **Customers:**\n"
          "• 'udhar customers' - Pending credits\n"
          "• 'top customers' - Best customers\n\n"
          "📊 **Products:**\n"
          "• 'top products' - Best sellers\n"
          "• 'zero stock products' - Out of stock";
    }

    if (_matchesAny(lowerQuery, ['low stock', 'stock alert', 'restock', 'reorder'])) {
      return _getLowStockReport();
    }

    if (_matchesAny(lowerQuery, ['zero stock', 'out of stock', 'stock out'])) {
      return _getZeroStockReport();
    }

    if (_matchesAny(lowerQuery, ['profit', 'earned', 'gain'])) {
      return _getProfitReport(lowerQuery);
    }

    if (_matchesAny(lowerQuery, ['sales', 'revenue', 'business'])) {
      return _getSalesReport(lowerQuery);
    }

    if (_matchesAny(lowerQuery, ['expense', 'spending', 'cost'])) {
      return _getExpenseReport(lowerQuery);
    }

    if (_matchesAny(lowerQuery, ['udhar', 'credit', 'pending', 'dues'])) {
      return _getUdharReport();
    }

    if (_matchesAny(lowerQuery, ['top product', 'best seller', 'popular'])) {
      return _getTopProductsReport();
    }

    if (_matchesAny(lowerQuery, ['weekly', 'this week', 'week report'])) {
      return _getWeeklyReport();
    }

    if (_matchesAny(lowerQuery, ['top customer', 'best customer'])) {
      return _getTopCustomersReport();
    }

    return "🤔 I'm not sure I understand that query.\n\nTry asking:\n• 'today's profit'\n• 'low stock items'\n• 'udhar customers'\n• Type 'help' for all commands";
  }

  bool _matches(String query, List<String> patterns) {
    return patterns.any((p) => query.contains(p));
  }

  bool _matchesAny(String query, List<String> patterns) {
    return patterns.any((p) => query.contains(p));
  }

  String _getLowStockReport() {
    final lowStockItems = productBox.values
        .where((p) => p.stockQuantity <= p.minStockAlert && p.stockQuantity > 0)
        .toList();

    if (lowStockItems.isEmpty) {
      return "✅ All items are well-stocked!\n\nNo low stock alerts at the moment.";
    }

    final buffer = StringBuffer();
    buffer.writeln("⚠️ **LOW STOCK ALERT**\n");
    buffer.writeln("${lowStockItems.length} item(s) need attention:\n");

    for (final item in lowStockItems) {
      final diff = item.minStockAlert - item.stockQuantity;
      buffer.writeln("📦 ${item.name}");
      buffer.writeln("   Current: ${item.stockQuantity} | Alert at: ${item.minStockAlert}");
      buffer.writeln("   Need: +$diff units\n");
    }

    return buffer.toString();
  }

  String _getZeroStockReport() {
    final zeroStockItems = productBox.values
        .where((p) => p.stockQuantity == 0)
        .toList();

    if (zeroStockItems.isEmpty) {
      return "✅ No out-of-stock items!\n\nAll products have some quantity available.";
    }

    final buffer = StringBuffer();
    buffer.writeln("🚨 **OUT OF STOCK**\n");
    buffer.writeln("${zeroStockItems.length} product(s) completely sold out:\n");

    for (final item in zeroStockItems) {
      buffer.writeln("📦 ${item.name}");
      buffer.writeln("   Category: ${item.category}");
      buffer.writeln("   MRP: ₹${item.sellPrice}\n");
    }

    return buffer.toString();
  }

  String _getProfitReport(String query) {
    final now = DateTime.now();
    DateTime startDate;
    DateTime endDate = now;

    if (_matches(query, ['today', "today's"])) {
      startDate = DateTime(now.year, now.month, now.day);
    } else if (_matches(query, ['yesterday'])) {
      startDate = DateTime(now.year, now.month, now.day - 1);
      endDate = startDate;
    } else if (_matches(query, ['week', 'this week'])) {
      startDate = now.subtract(Duration(days: now.weekday - 1));
      startDate = DateTime(startDate.year, startDate.month, startDate.day);
    } else if (_matches(query, ['month', 'this month'])) {
      startDate = DateTime(now.year, now.month, 1);
    } else {
      startDate = DateTime(now.year, now.month, now.day);
    }

    final sales = _getSalesInRange(startDate, endDate);
    final expenses = _getExpensesInRange(startDate, endDate);

    final totalSales = sales.fold(0.0, (sum, s) => sum + s.totalAmount);
    final totalProfit = sales.fold(0.0, (sum, s) => sum + s.totalProfit);
    final totalExpenses = expenses.fold(0.0, (sum, e) => sum + e.amount);
    final netProfit = totalProfit - totalExpenses;

    final period = _matches(query, ['today', "today's"]) ? 'Today'
        : _matches(query, ['yesterday']) ? 'Yesterday'
        : _matches(query, ['week', 'this week']) ? 'This Week'
        : _matches(query, ['month', 'this month']) ? 'This Month'
        : 'Today';

    return "💰 **$period Profit Report**\n\n"
        "📈 Total Sales: ₹${totalSales.toStringAsFixed(2)}\n"
        "📊 Gross Profit: ₹${totalProfit.toStringAsFixed(2)}\n"
        "📉 Expenses: ₹${totalExpenses.toStringAsFixed(2)}\n"
        "━━━━━━━━━━━━━━━━━━\n"
        "💵 **Net Profit: ₹${netProfit.toStringAsFixed(2)}**\n\n"
        "🧾 Transactions: ${sales.length}";
  }

  String _getSalesReport(String query) {
    final now = DateTime.now();
    DateTime startDate;
    DateTime endDate = now;

    if (_matches(query, ['today', "today's"])) {
      startDate = DateTime(now.year, now.month, now.day);
    } else if (_matches(query, ['yesterday'])) {
      startDate = DateTime(now.year, now.month, now.day - 1);
      endDate = startDate;
    } else if (_matches(query, ['week', 'this week'])) {
      startDate = now.subtract(Duration(days: now.weekday - 1));
      startDate = DateTime(startDate.year, startDate.month, startDate.day);
    } else if (_matches(query, ['month', 'this month'])) {
      startDate = DateTime(now.year, now.month, 1);
    } else {
      startDate = DateTime(now.year, now.month, now.day);
    }

    final sales = _getSalesInRange(startDate, endDate);
    final totalSales = sales.fold(0.0, (sum, s) => sum + s.totalAmount);
    final totalProfit = sales.fold(0.0, (sum, s) => sum + s.totalProfit);

    final period = _matches(query, ['today', "today's"]) ? 'Today'
        : _matches(query, ['yesterday']) ? 'Yesterday'
        : _matches(query, ['week', 'this week']) ? 'This Week'
        : _matches(query, ['month', 'this month']) ? 'This Month'
        : 'Today';

    return "📊 **$period Sales Report**\n\n"
        "💵 Total Revenue: ₹${totalSales.toStringAsFixed(2)}\n"
        "📈 Total Profit: ₹${totalProfit.toStringAsFixed(2)}\n"
        "🧾 Total Bills: ${sales.length}\n"
        "📋 Avg Bill Value: ₹${sales.isNotEmpty ? (totalSales / sales.length).toStringAsFixed(2) : '0.00'}";
  }

  String _getExpenseReport(String query) {
    final now = DateTime.now();
    DateTime startDate;
    DateTime endDate = now;

    if (_matches(query, ['today', "today's"])) {
      startDate = DateTime(now.year, now.month, now.day);
    } else if (_matches(query, ['yesterday'])) {
      startDate = DateTime(now.year, now.month, now.day - 1);
      endDate = startDate;
    } else if (_matches(query, ['week', 'this week'])) {
      startDate = now.subtract(Duration(days: now.weekday - 1));
      startDate = DateTime(startDate.year, startDate.month, startDate.day);
    } else if (_matches(query, ['month', 'this month'])) {
      startDate = DateTime(now.year, now.month, 1);
    } else {
      startDate = DateTime(now.year, now.month, now.day);
    }

    final expenses = _getExpensesInRange(startDate, endDate);
    final totalExpenses = expenses.fold(0.0, (sum, e) => sum + e.amount);

    final period = _matches(query, ['today', "today's"]) ? 'Today'
        : _matches(query, ['yesterday']) ? 'Yesterday'
        : _matches(query, ['week', 'this week']) ? 'This Week'
        : _matches(query, ['month', 'this month']) ? 'This Month'
        : 'Today';

    if (expenses.isEmpty) {
      return "📉 **$period Expenses**\n\nNo expenses recorded for this period.\n\n💚 Less spending = More savings!";
    }

    final buffer = StringBuffer();
    buffer.writeln("📉 **$period Expenses**\n");
    buffer.writeln("💸 Total Spent: ₹${totalExpenses.toStringAsFixed(2)}\n");
    buffer.writeln("Recent expenses:\n");

    final recentExpenses = expenses.take(5).toList();
    for (final expense in recentExpenses) {
      buffer.writeln("• ${expense.title}: ₹${expense.amount.toStringAsFixed(2)}");
    }

    return buffer.toString();
  }

  String _getUdharReport() {
    if (customerBox == null) {
      return "👥 **Customer Ledger**\n\nCustomer tracking is not available in demo mode.";
    }

    final customersWithUdhar = customerBox!.values
        .where((c) => c.totalCredit > 0)
        .toList();

    if (customersWithUdhar.isEmpty) {
      return "👥 **Udhar Report**\n\n✅ No pending udhar!\n\nAll customers have cleared their dues.";
    }

    final totalUdhar = customersWithUdhar.fold(0.0, (sum, c) => sum + c.totalCredit);

    final buffer = StringBuffer();
    buffer.writeln("👥 **Udhar Customers**\n");
    buffer.writeln("📊 Total Pending: ₹${totalUdhar.toStringAsFixed(2)}\n");
    buffer.writeln("${customersWithUdhar.length} customer(s) with pending dues:\n");

    final sortedCustomers = customersWithUdhar
      ..sort((a, b) => b.totalCredit.compareTo(a.totalCredit));

    for (final customer in sortedCustomers.take(5)) {
      buffer.writeln("👤 ${customer.name}");
      buffer.writeln("   Pending: ₹${customer.totalCredit.toStringAsFixed(2)}");
      buffer.writeln("   Phone: ${customer.phone}\n");
    }

    return buffer.toString();
  }

  String _getTopProductsReport() {
    final salesData = <String, Map<String, dynamic>>{};

    for (final sale in saleBox.values) {
      final name = sale.productName;
      if (!salesData.containsKey(name)) {
        salesData[name] = {'quantity': 0, 'revenue': 0.0};
      }
      salesData[name]!['quantity'] = (salesData[name]!['quantity'] as int) + sale.quantitySold;
      salesData[name]!['revenue'] = (salesData[name]!['revenue'] as double) + sale.totalAmount;
    }

    if (salesData.isEmpty) {
      return "📦 **Top Products**\n\nNo sales data available yet.\n\nStart selling to see product analytics!";
    }

    final sortedProducts = salesData.entries.toList()
      ..sort((a, b) => (b.value['quantity'] as int).compareTo(a.value['quantity'] as int));

    final buffer = StringBuffer();
    buffer.writeln("🏆 **Top Selling Products**\n");

    for (var i = 0; i < sortedProducts.length && i < 5; i++) {
      final product = sortedProducts[i];
      buffer.writeln("${i + 1}. ${product.key}");
      buffer.writeln("   Sold: ${product.value['quantity']} units");
      buffer.writeln("   Revenue: ₹${(product.value['revenue'] as double).toStringAsFixed(2)}\n");
    }

    return buffer.toString();
  }

  String _getWeeklyReport() {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final startDate = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);

    final sales = _getSalesInRange(startDate, now);
    final expenses = _getExpensesInRange(startDate, now);

    final totalSales = sales.fold(0.0, (sum, s) => sum + s.totalAmount);
    final totalProfit = sales.fold(0.0, (sum, s) => sum + s.totalProfit);
    final totalExpenses = expenses.fold(0.0, (sum, e) => sum + e.amount);
    final netProfit = totalProfit - totalExpenses;

    final dailyData = <int, double>{};
    for (final sale in sales) {
      final day = sale.date.weekday;
      dailyData[day] = (dailyData[day] ?? 0) + sale.totalAmount;
    }

    final buffer = StringBuffer();
    buffer.writeln("📅 **This Week Summary**\n");
    buffer.writeln("💵 Revenue: ₹${totalSales.toStringAsFixed(2)}");
    buffer.writeln("📈 Profit: ₹${totalProfit.toStringAsFixed(2)}");
    buffer.writeln("📉 Expenses: ₹${totalExpenses.toStringAsFixed(2)}");
    buffer.writeln("━━━━━━━━━━━━━━━━━━");
    buffer.writeln("💰 Net Profit: ₹${netProfit.toStringAsFixed(2)}\n");
    buffer.writeln("🧾 Total Bills: ${sales.length}");
    buffer.writeln("\nDaily breakdown:\n");

    const days = ['', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    for (var i = 1; i <= 7; i++) {
      final dayName = days[i];
      final amount = dailyData[i] ?? 0;
      final bar = '█' * ((amount / (dailyData.values.isEmpty ? 1 : dailyData.values.reduce((a, b) => a > b ? a : b)) * 10).round());
      buffer.writeln("$dayName: $bar ₹${amount.toStringAsFixed(0)}");
    }

    return buffer.toString();
  }

  String _getTopCustomersReport() {
    if (customerBox == null) {
      return "👥 **Customer Report**\n\nCustomer tracking is not available in demo mode.";
    }

    final customers = customerBox!.values.toList()
      ..sort((a, b) => b.totalCredit.compareTo(a.totalCredit));

    if (customers.isEmpty || customers.first.totalCredit == 0) {
      return "👥 **Top Customers**\n\nNo customer credit data available yet.";
    }

    final buffer = StringBuffer();
    buffer.writeln("⭐ **Top Customers by Credit**\n");

    for (var i = 0; i < customers.length && i < 5; i++) {
      final customer = customers[i];
      if (customer.totalCredit == 0) continue;

      buffer.writeln("${i + 1}. ${customer.name}");
      buffer.writeln("   Total Credit: ₹${customer.totalCredit.toStringAsFixed(2)}");
      buffer.writeln("   Phone: ${customer.phone}");
      buffer.writeln("");
    }

    return buffer.toString();
  }

  List<SaleTable> _getSalesInRange(DateTime start, DateTime end) {
    return saleBox.values
        .where((s) => s.date.isAfter(start.subtract(const Duration(seconds: 1))) && 
                      s.date.isBefore(end.add(const Duration(days: 1))))
        .toList();
  }

  List<ExpenseTable> _getExpensesInRange(DateTime start, DateTime end) {
    return expenseBox.values
        .where((e) => e.date.isAfter(start.subtract(const Duration(seconds: 1))) && 
                      e.date.isBefore(end.add(const Duration(days: 1))))
        .toList();
  }
}
