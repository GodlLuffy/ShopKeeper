part of 'expenses_cubit.dart';

abstract class ExpensesState extends Equatable {
  const ExpensesState();

  @override
  List<Object?> get props => [];
}

class ExpensesInitial extends ExpensesState {}

class ExpensesLoading extends ExpensesState {}

class ExpensesLoaded extends ExpensesState {
  final List<ExpenseEntity> expenses;
  const ExpensesLoaded(this.expenses);

  @override
  List<Object?> get props => [expenses];
}

class ExpensesError extends ExpensesState {
  final String message;
  const ExpensesError(this.message);

  @override
  List<Object?> get props => [message];
}
