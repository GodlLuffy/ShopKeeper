import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shop_keeper_project/features/expenses/domain/entities/expense_entity.dart';
import 'package:shop_keeper_project/features/expenses/domain/usecases/get_expenses_by_date.dart';
import 'package:shop_keeper_project/features/expenses/domain/usecases/add_expense.dart';
import 'package:shop_keeper_project/features/expenses/domain/usecases/get_today_expenses_summary.dart';
import 'package:shop_keeper_project/features/expenses/domain/usecases/delete_expense.dart';

part 'expenses_state.dart';

class ExpensesCubit extends Cubit<ExpensesState> {
  final GetExpensesByDate getExpensesByDate;
  final AddExpense addExpenseUseCase;
  final GetTodayExpensesSummary getSummary;
  final DeleteExpense deleteExpenseUseCase;

  ExpensesCubit({
    required this.getExpensesByDate,
    required this.addExpenseUseCase,
    required this.getSummary,
    required this.deleteExpenseUseCase,
  }) : super(ExpensesInitial());

  Future<void> loadTodayExpenses() async {
    emit(ExpensesLoading());
    final result = await getExpensesByDate(DateTime.now());
    result.fold(
      (failure) => emit(ExpensesError(failure.message)),
      (expenses) => emit(ExpensesLoaded(expenses)),
    );
  }

  Future<void> addExpense(ExpenseEntity expense) async {
    emit(ExpensesLoading());
    final result = await addExpenseUseCase(expense);
    result.fold(
      (failure) => emit(ExpensesError(failure.message)),
      (_) => loadTodayExpenses(),
    );
  }

  Future<void> deleteExpense(String id) async {
    final result = await deleteExpenseUseCase(id);
    result.fold(
      (failure) => emit(ExpensesError(failure.message)),
      (_) => loadTodayExpenses(),
    );
  }
}
