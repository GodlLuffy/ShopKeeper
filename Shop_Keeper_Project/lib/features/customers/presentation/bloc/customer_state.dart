part of 'customer_cubit.dart';

abstract class CustomerState extends Equatable {
  const CustomerState();

  @override
  List<Object?> get props => [];
}

class CustomerInitial extends CustomerState {}

class CustomerLoading extends CustomerState {}

class CustomerLoaded extends CustomerState {
  final List<CustomerEntity> customers;
  const CustomerLoaded(this.customers);

  double get totalOutstanding => customers.fold(0.0, (sum, c) => sum + c.totalCredit);
  int get customersWithCredit => customers.where((c) => c.hasOutstandingCredit).length;

  @override
  List<Object?> get props => [customers];
}

class CustomerError extends CustomerState {
  final String message;
  const CustomerError(this.message);

  @override
  List<Object?> get props => [message];
}

class TransactionsLoading extends CustomerState {}

class TransactionsLoaded extends CustomerState {
  final String customerId;
  final List<CreditTransactionEntity> transactions;
  const TransactionsLoaded(this.customerId, this.transactions);

  @override
  List<Object?> get props => [customerId, transactions];
}
