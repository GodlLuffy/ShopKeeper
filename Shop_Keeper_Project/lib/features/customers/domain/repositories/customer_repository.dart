import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/customer_entity.dart';
import '../entities/credit_transaction_entity.dart';

abstract class CustomerRepository {
  Future<Either<Failure, List<CustomerEntity>>> getCustomers();
  Future<Either<Failure, CustomerEntity>> getCustomerById(String id);
  Future<Either<Failure, CustomerEntity>> addCustomer(CustomerEntity customer);
  Future<Either<Failure, CustomerEntity>> updateCustomer(CustomerEntity customer);
  Future<Either<Failure, void>> deleteCustomer(String id);
  Future<Either<Failure, CreditTransactionEntity>> addCredit(String customerId, double amount, {String? description, String? billId});
  Future<Either<Failure, CreditTransactionEntity>> recordPayment(String customerId, double amount, {String? description});
  Future<Either<Failure, List<CreditTransactionEntity>>> getTransactions(String customerId);
}
