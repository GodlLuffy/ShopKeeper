import 'package:dartz/dartz.dart';
import 'package:shop_keeper_project/core/error/failures.dart';
import 'package:shop_keeper_project/features/expenses/domain/repositories/expenses_repository.dart';

class DeleteExpense {
  final ExpensesRepository repository;

  DeleteExpense(this.repository);

  Future<Either<Failure, Unit>> call(String id) async {
    return await repository.deleteExpense(id);
  }
}
