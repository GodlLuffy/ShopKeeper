import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/customer_entity.dart';
import '../repositories/customer_repository.dart';

class UpdateCustomer implements UseCase<CustomerEntity, CustomerEntity> {
  final CustomerRepository repository;

  UpdateCustomer(this.repository);

  @override
  Future<Either<Failure, CustomerEntity>> call(CustomerEntity customer) async {
    return await repository.updateCustomer(customer);
  }
}
