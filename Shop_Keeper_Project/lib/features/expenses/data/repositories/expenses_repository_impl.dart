import 'package:dartz/dartz.dart';
import 'package:shop_keeper_project/core/error/failures.dart';
import 'package:shop_keeper_project/features/expenses/data/datasources/expenses_local_data_source.dart';
import 'package:shop_keeper_project/features/expenses/data/datasources/expenses_remote_data_source.dart';
import 'package:shop_keeper_project/features/expenses/data/models/expense_model.dart';
import 'package:shop_keeper_project/features/expenses/data/models/expense_mapper.dart';
import 'package:shop_keeper_project/features/expenses/domain/entities/expense_entity.dart';
import 'package:shop_keeper_project/features/expenses/domain/repositories/expenses_repository.dart';
import 'package:uuid/uuid.dart';

class ExpensesRepositoryImpl implements ExpensesRepository {
  final ExpensesLocalDataSource localDataSource;
  final ExpensesRemoteDataSource remoteDataSource;

  ExpensesRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
  });

  @override
  Future<Either<Failure, List<ExpenseEntity>>> getExpensesByDate(DateTime date) async {
    try {
      final localExpenses = await localDataSource.getExpensesByDate(date);
      return Right(localExpenses.map((t) => ExpenseMapper.toEntity(ExpenseModel.fromTable(t))).toList());
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ExpenseEntity>> addExpense(ExpenseEntity expense) async {
    try {
      final expenseId = expense.id.isEmpty ? const Uuid().v4() : expense.id;
      final expenseWithId = ExpenseEntity(
        id: expenseId,
        title: expense.title,
        amount: expense.amount,
        category: expense.category,
        date: expense.date,
        userId: expense.userId,
      );

      final model = ExpenseMapper.toModel(expenseWithId);
      await localDataSource.saveExpense(model.toTable(isSynced: false));
      
      _syncExpenseToRemote(model);
      
      return Right(expenseWithId);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, double>> getTodayExpensesSummary() async {
    try {
      final total = await localDataSource.getTodayExpensesSummary();
      return Right(total);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  void _syncExpenseToRemote(ExpenseModel model) async {
    try {
      await remoteDataSource.saveExpense(model);
    } catch (_) {
      // Periodic sync handled by SyncService
    }
  }
}
