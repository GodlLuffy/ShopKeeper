import 'package:dartz/dartz.dart';
import 'package:shop_keeper_project/core/error/failures.dart';
import 'package:shop_keeper_project/features/expenses/domain/entities/expense_entity.dart';

abstract class ExpensesRepository {
  Future<Either<Failure, List<ExpenseEntity>>> getExpensesByDate(DateTime date);
  Future<Either<Failure, ExpenseEntity>> addExpense(ExpenseEntity expense);
  Future<Either<Failure, double>> getTodayExpensesSummary();
  Future<Either<Failure, Unit>> deleteExpense(String id);
}
