import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/customer_entity.dart';
import '../repositories/customer_repository.dart';

class AddCustomer implements UseCase<CustomerEntity, AddCustomerParams> {
  final CustomerRepository repository;

  AddCustomer(this.repository);

  @override
  Future<Either<Failure, CustomerEntity>> call(AddCustomerParams params) async {
    if (params.customer.name.trim().isEmpty) {
      return const Left(ValidationFailure('Customer name cannot be empty'));
    }
    if (params.customer.phone.trim().isEmpty) {
      return const Left(ValidationFailure('Phone number is required'));
    }
    return await repository.addCustomer(params.customer);
  }
}

class AddCustomerParams extends Equatable {
  final CustomerEntity customer;

  const AddCustomerParams({required this.customer});

  @override
  List<Object?> get props => [customer];
}
