import 'package:hive_flutter/hive_flutter.dart';
import 'package:shop_keeper_project/database/tables/sale_table.dart';

abstract class SalesLocalDataSource {
  Future<List<SaleTable>> getSalesByDate(DateTime date);
  Future<void> saveSale(SaleTable sale);
  Future<double> getTodaySalesSummary();
}

class SalesLocalDataSourceImpl implements SalesLocalDataSource {
  final Box<SaleTable> saleBox;

  SalesLocalDataSourceImpl({required this.saleBox});

  @override
  Future<List<SaleTable>> getSalesByDate(DateTime date) async {
    return saleBox.values.where((s) {
      return s.date.day == date.day && 
             s.date.month == date.month && 
             s.date.year == date.year;
    }).toList();
  }

  @override
  Future<void> saveSale(SaleTable sale) async {
    await saleBox.put(sale.id, sale);
  }

  @override
  Future<double> getTodaySalesSummary() async {
    final today = DateTime.now();
    final todaySalesList = await getSalesByDate(today);
    return todaySalesList.fold<double>(0.0, (total, s) => total + s.totalAmount);
  }
}
