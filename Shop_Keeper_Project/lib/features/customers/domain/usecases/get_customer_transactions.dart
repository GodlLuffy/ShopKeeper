import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/credit_transaction_entity.dart';
import '../repositories/customer_repository.dart';

class GetCustomerTransactions implements UseCase<List<CreditTransactionEntity>, String> {
  final CustomerRepository repository;

  GetCustomerTransactions(this.repository);

  @override
  Future<Either<Failure, List<CreditTransactionEntity>>> call(String customerId) async {
    return await repository.getTransactions(customerId);
  }
}
