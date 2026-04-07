part of 'sales_cubit.dart';

abstract class SalesState extends Equatable {
  const SalesState();

  @override
  List<Object?> get props => [];
}

class SalesInitial extends SalesState {}

class SalesLoading extends SalesState {}

class SalesLoaded extends SalesState {
  final List<SaleEntity> sales;
  const SalesLoaded(this.sales);

  @override
  List<Object?> get props => [sales];
}

class SalesError extends SalesState {
  final String message;
  const SalesError(this.message);

  @override
  List<Object?> get props => [message];
}
