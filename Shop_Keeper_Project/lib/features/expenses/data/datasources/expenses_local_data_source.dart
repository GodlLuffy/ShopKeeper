import 'package:hive_flutter/hive_flutter.dart';
import 'package:shop_keeper_project/database/tables/expense_table.dart';

abstract class ExpensesLocalDataSource {
  Future<List<ExpenseTable>> getExpensesByDate(DateTime date);
  Future<void> saveExpense(ExpenseTable expense);
  Future<double> getTodayExpensesSummary();
  Future<void> deleteExpense(String id);
}

class ExpensesLocalDataSourceImpl implements ExpensesLocalDataSource {
  final Box<ExpenseTable> expenseBox;

  ExpensesLocalDataSourceImpl({required this.expenseBox});

  @override
  Future<List<ExpenseTable>> getExpensesByDate(DateTime date) async {
    return expenseBox.values.where((e) {
      return e.date.day == date.day && 
             e.date.month == date.month && 
             e.date.year == date.year;
    }).toList();
  }

  @override
  Future<void> saveExpense(ExpenseTable expense) async {
    await expenseBox.put(expense.id, expense);
  }

  @override
  Future<double> getTodayExpensesSummary() async {
    final today = DateTime.now();
    final expenses = await getExpensesByDate(today);
    return expenses.fold<double>(0.0, (total, e) => total + e.amount);
  }

  @override
  Future<void> deleteExpense(String id) async {
    await expenseBox.delete(id);
  }
}
