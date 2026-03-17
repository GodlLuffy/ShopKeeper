import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shop_keeper_project/features/expenses/presentation/bloc/expenses_cubit.dart';
import 'package:shop_keeper_project/features/expenses/data/models/expense_model.dart';
import 'package:uuid/uuid.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  String _category = 'Miscellaneous';
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Expense')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Expense Name', hintText: 'Electricity Bill')),
            const SizedBox(height: 16),
            TextField(controller: _amountController, decoration: const InputDecoration(labelText: 'Amount', prefixText: '₹'), keyboardType: TextInputType.number),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _category,
              items: ['Rent', 'Utilities', 'Transport', 'Stock Purchase', 'Salary', 'Miscellaneous']
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (val) => setState(() => _category = val!),
              decoration: const InputDecoration(labelText: 'Category'),
            ),
            const SizedBox(height: 24),
            ListTile(
              title: const Text('Date'),
              subtitle: Text(DateFormat('dd MMM yyyy').format(_selectedDate)),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                );
                if (date != null) setState(() => _selectedDate = date);
              },
            ),
            const SizedBox(height: 48),
            ElevatedButton(
              onPressed: () {
                final expense = ExpenseModel(
                  id: const Uuid().v4(),
                  title: _nameController.text,
                  amount: double.tryParse(_amountController.text) ?? 0.0,
                  category: _category,
                  date: _selectedDate,
                  userId: 'dummy_user',
                );
                context.read<ExpensesCubit>().addExpense(expense);
                Navigator.pop(context);
              },
              child: const Text('Save Expense'),
            ),
          ],
        ),
      ),
    );
  }
}
