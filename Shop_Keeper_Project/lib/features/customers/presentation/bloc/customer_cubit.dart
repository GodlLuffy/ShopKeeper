import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/customer_entity.dart';
import '../../domain/entities/credit_transaction_entity.dart';
import '../../domain/usecases/get_customers.dart';
import '../../domain/usecases/add_customer.dart';
import '../../domain/usecases/delete_customer.dart';
import '../../domain/usecases/add_credit.dart';
import '../../domain/usecases/record_payment.dart';
import '../../domain/usecases/get_transactions.dart';

part 'customer_state.dart';

class CustomerCubit extends Cubit<CustomerState> {
  final GetCustomers getCustomersUseCase;
  final AddCustomer addCustomerUseCase;
  final DeleteCustomer deleteCustomerUseCase;
  final AddCreditTransaction addCreditUseCase;
  final RecordPayment recordPaymentUseCase;
  final GetTransactions getTransactionsUseCase;

  CustomerCubit({
    required this.getCustomersUseCase,
    required this.addCustomerUseCase,
    required this.deleteCustomerUseCase,
    required this.addCreditUseCase,
    required this.recordPaymentUseCase,
    required this.getTransactionsUseCase,
  }) : super(CustomerInitial());

  Future<void> loadCustomers() async {
    emit(CustomerLoading());
    final result = await getCustomersUseCase(NoParams());
    result.fold(
      (failure) => emit(CustomerError(failure.message)),
      (customers) => emit(CustomerLoaded(customers)),
    );
  }

  Future<void> addCustomer(CustomerEntity customer) async {
    final result = await addCustomerUseCase(AddCustomerParams(customer: customer));
    result.fold(
      (failure) => emit(CustomerError(failure.message)),
      (_) => loadCustomers(),
    );
  }

  Future<void> deleteCustomer(String id) async {
    final result = await deleteCustomerUseCase(id);
    result.fold(
      (failure) => emit(CustomerError(failure.message)),
      (_) => loadCustomers(),
    );
  }

  Future<void> addCredit(String customerId, double amount, {String? description, String? billId}) async {
    final result = await addCreditUseCase(AddCreditParams(
      customerId: customerId,
      amount: amount,
      description: description,
      billId: billId,
    ));
    result.fold(
      (failure) => emit(CustomerError(failure.message)),
      (transaction) {
        // Reload customer list to reflect updated balance
        loadCustomers();
      },
    );
  }

  Future<void> recordPayment(String customerId, double amount, {String? description}) async {
    final result = await recordPaymentUseCase(RecordPaymentParams(
      customerId: customerId,
      amount: amount,
      description: description,
    ));
    result.fold(
      (failure) => emit(CustomerError(failure.message)),
      (transaction) {
        loadCustomers();
      },
    );
  }

  Future<void> loadTransactions(String customerId) async {
    emit(TransactionsLoading());
    final result = await getTransactionsUseCase(customerId);
    result.fold(
      (failure) => emit(CustomerError(failure.message)),
      (transactions) => emit(TransactionsLoaded(customerId, transactions)),
    );
  }
}
