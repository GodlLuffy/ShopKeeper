import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shop_keeper_project/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:shop_keeper_project/features/expenses/presentation/bloc/expenses_cubit.dart';
import 'package:shop_keeper_project/features/expenses/data/models/expense_model.dart';
import 'package:shop_keeper_project/core/theme/app_theme.dart';
import 'package:shop_keeper_project/core/widgets/empty_state_widget.dart';
import 'package:uuid/uuid.dart';

class ExpenseListScreen extends StatefulWidget {
  const ExpenseListScreen({super.key});

  @override
  State<ExpenseListScreen> createState() => _ExpenseListScreenState();
}

class _ExpenseListScreenState extends State<ExpenseListScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ExpensesCubit>().loadTodayExpenses();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daily Expenses')),
      body: BlocBuilder<ExpensesCubit, ExpensesState>(
        builder: (context, state) {
          if (state is ExpensesLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ExpensesLoaded) {
            final expenses = state.expenses;
            if (expenses.isEmpty) {
              return const EmptyStateWidget(
                icon: Icons.account_balance_wallet_outlined,
                title: 'No Expenses Yet',
                message: 'No expenses have been recorded for today.',
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: expenses.length,
              itemBuilder: (context, index) {
                final expense = expenses[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    title: Text(expense.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(expense.category),
                    trailing: Text('₹${expense.amount}', style: const TextStyle(
                      color: AppTheme.errorColor, fontSize: 18, fontWeight: FontWeight.bold
                    )),
                  ),
                );
              },
            );
          } else if (state is ExpensesError) {
            return Center(child: Text('Error: ${state.message}'));
          }
          return const SizedBox();
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddExpenseDialog(context),
        label: const Text('Add Expense'),
        icon: const Icon(Icons.remove_circle),
      ),
    );
  }

  void _showAddExpenseDialog(BuildContext context) {
    final titleController = TextEditingController();
    final amountController = TextEditingController();
    String category = 'Rent/Bills';

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('New Expense'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Title')),
            DropdownButtonFormField<String>(
              value: category,
              items: ['Rent/Bills', 'Stock Purchase', 'Staff Salary', 'Others']
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (val) => category = val!,
              decoration: const InputDecoration(labelText: 'Category'),
            ),
            TextField(controller: amountController, decoration: const InputDecoration(labelText: 'Amount'), keyboardType: TextInputType.number),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final expense = ExpenseModel(
                id: const Uuid().v4(),
                title: titleController.text,
                amount: double.tryParse(amountController.text) ?? 0.0,
                category: category,
                date: DateTime.now(),
                userId: (context.read<AuthCubit>().state is Authenticated) 
                    ? (context.read<AuthCubit>().state as Authenticated).user.uid 
                    : (context.read<AuthCubit>().state is PinRequired)
                        ? (context.read<AuthCubit>().state as PinRequired).user.uid
                        : 'unknown',
              );
              context.read<ExpensesCubit>().addExpense(expense);
              Navigator.pop(dialogContext);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
