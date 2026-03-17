import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shop_keeper_project/features/expenses/data/models/expense_model.dart';

abstract class ExpensesRemoteDataSource {
  Future<List<ExpenseModel>> getExpensesByDate(String userId, DateTime date);
  Future<void> saveExpense(ExpenseModel expense);
}

class ExpensesRemoteDataSourceImpl implements ExpensesRemoteDataSource {
  final FirebaseFirestore? firestore;

  ExpensesRemoteDataSourceImpl({this.firestore});

  @override
  Future<List<ExpenseModel>> getExpensesByDate(String userId, DateTime date) async {
    if (firestore == null) return [];
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

    final snapshot = await firestore!
        .collection('expenses')
        .where('userId', isEqualTo: userId)
        .where('date', isGreaterThanOrEqualTo: startOfDay)
        .where('date', isLessThanOrEqualTo: endOfDay)
        .get();
        
    return snapshot.docs.map((doc) => ExpenseModel.fromMap(doc.data(), doc.id)).toList();
  }

  @override
  Future<void> saveExpense(ExpenseModel expense) async {
    if (firestore == null) return;
    await firestore!.collection('expenses').doc(expense.id).set(expense.toMap());
  }
}
