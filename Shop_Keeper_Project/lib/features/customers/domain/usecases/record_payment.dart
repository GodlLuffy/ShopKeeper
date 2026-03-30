import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/credit_transaction_entity.dart';
import '../repositories/customer_repository.dart';

class RecordPayment implements UseCase<CreditTransactionEntity, RecordPaymentParams> {
  final CustomerRepository repository;

  RecordPayment(this.repository);

  @override
  Future<Either<Failure, CreditTransactionEntity>> call(RecordPaymentParams params) async {
    if (params.amount <= 0) {
      return const Left(ValidationFailure('Payment amount must be greater than zero'));
    }
    return await repository.recordPayment(
      params.customerId,
      params.amount,
      description: params.description,
    );
  }
}

class RecordPaymentParams extends Equatable {
  final String customerId;
  final double amount;
  final String? description;

  const RecordPaymentParams({
    required this.customerId,
    required this.amount,
    this.description,
  });

  @override
  List<Object?> get props => [customerId, amount, description];
}
