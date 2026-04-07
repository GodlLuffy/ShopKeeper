import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shop_keeper_project/features/expenses/presentation/bloc/expenses_cubit.dart';
import 'package:shop_keeper_project/features/expenses/data/models/expense_model.dart';
import 'package:shop_keeper_project/core/theme/app_colors.dart';
import 'package:shop_keeper_project/core/widgets/custom_text_field.dart';
import 'package:shop_keeper_project/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:lucide_icons/lucide_icons.dart';

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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'ADD EXPENSE',
          style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 2, color: AppColors.textPrimary),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: AppColors.textPrimary),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            CustomTextField(
              label: 'Expense Name',
              controller: _nameController,
              hintText: 'Electricity Bill',
              prefixIcon: LucideIcons.fileText,
            ),
            const SizedBox(height: 24),
            CustomTextField(
              label: 'Amount',
              controller: _amountController,
              hintText: '₹0.00',
              keyboardType: TextInputType.number,
              prefixIcon: LucideIcons.indianRupee,
            ),
            const SizedBox(height: 24),
            Text(
              'Category',
              style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textSecondary, letterSpacing: 0.5),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.08)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButtonFormField<String>(
                  dropdownColor: AppColors.surface,
                  isExpanded: true,
                  value: _category,
                  style: GoogleFonts.outfit(color: AppColors.textPrimary, fontWeight: FontWeight.w500),
                  decoration: const InputDecoration(border: InputBorder.none),
                  items: ['Rent', 'Utilities', 'Transport', 'Stock Purchase', 'Salary', 'Miscellaneous']
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (val) => setState(() => _category = val!),
                ),
              ),
            ),
            const SizedBox(height: 24),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                'Date',
                style: GoogleFonts.outfit(color: AppColors.textSecondary, fontWeight: FontWeight.w700),
              ),
              subtitle: Text(
                DateFormat('dd MMM yyyy').format(_selectedDate),
                style: GoogleFonts.outfit(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w600),
              ),
              trailing: Icon(LucideIcons.calendar, color: AppColors.primary),
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
            Container(
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(colors: [AppColors.primary.withOpacity(0.8), AppColors.primary]),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () {
                  final expense = ExpenseModel(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    title: _nameController.text,
                    amount: double.tryParse(_amountController.text) ?? 0.0,
                    category: _category,
                    date: _selectedDate,
                    userId: (context.read<AuthCubit>().state is Authenticated) 
                        ? (context.read<AuthCubit>().state as Authenticated).user.uid 
                        : (context.read<AuthCubit>().state is PinRequired)
                            ? (context.read<AuthCubit>().state as PinRequired).user.uid
                            : 'unknown',
                  );
                  context.read<ExpensesCubit>().addExpense(expense);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text(
                  'SAVE EXPENSE',
                  style: GoogleFonts.outfit(fontWeight: FontWeight.w900, letterSpacing: 1.5, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
