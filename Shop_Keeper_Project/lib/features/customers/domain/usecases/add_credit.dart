import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/credit_transaction_entity.dart';
import '../repositories/customer_repository.dart';

class AddCreditTransaction implements UseCase<CreditTransactionEntity, AddCreditParams> {
  final CustomerRepository repository;

  AddCreditTransaction(this.repository);

  @override
  Future<Either<Failure, CreditTransactionEntity>> call(AddCreditParams params) async {
    if (params.amount <= 0) {
      return const Left(ValidationFailure('Amount must be greater than zero'));
    }
    return await repository.addCredit(
      params.customerId,
      params.amount,
      description: params.description,
      billId: params.billId,
    );
  }
}

class AddCreditParams extends Equatable {
  final String customerId;
  final double amount;
  final String? description;
  final String? billId;

  const AddCreditParams({
    required this.customerId,
    required this.amount,
    this.description,
    this.billId,
  });

  @override
  List<Object?> get props => [customerId, amount, description, billId];
}
