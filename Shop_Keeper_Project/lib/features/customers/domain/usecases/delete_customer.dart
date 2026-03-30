import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/customer_repository.dart';

class DeleteCustomer implements UseCase<void, String> {
  final CustomerRepository repository;

  DeleteCustomer(this.repository);

  @override
  Future<Either<Failure, void>> call(String id) async {
    return await repository.deleteCustomer(id);
  }
}
