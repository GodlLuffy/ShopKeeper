import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shop_keeper_project/features/expenses/domain/entities/expense_entity.dart';
import 'package:shop_keeper_project/features/expenses/domain/repositories/expenses_repository.dart';

part 'expenses_state.dart';

class ExpensesCubit extends Cubit<ExpensesState> {
  final ExpensesRepository repository;

  ExpensesCubit({required this.repository}) : super(ExpensesInitial());

  Future<void> loadTodayExpenses() async {
    emit(ExpensesLoading());
    final result = await repository.getExpensesByDate(DateTime.now());
    result.fold(
      (failure) => emit(ExpensesError(failure.message)),
      (expenses) => emit(ExpensesLoaded(expenses)),
    );
  }

  Future<void> addExpense(ExpenseEntity expense) async {
    emit(ExpensesLoading());
    final result = await repository.addExpense(expense);
    result.fold(
      (failure) => emit(ExpensesError(failure.message)),
      (_) => loadTodayExpenses(),
    );
  }
}
