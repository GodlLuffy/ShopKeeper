import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shop_keeper_project/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:shop_keeper_project/features/expenses/presentation/bloc/expenses_cubit.dart';
import 'package:shop_keeper_project/features/expenses/data/models/expense_model.dart';
import 'package:shop_keeper_project/core/theme/app_theme.dart';
import 'package:shop_keeper_project/core/widgets/empty_state_widget.dart';
import 'package:shop_keeper_project/core/widgets/glass_card.dart';
import 'package:shop_keeper_project/core/widgets/custom_text_field.dart';
import 'package:shop_keeper_project/core/widgets/confirm_dialog.dart';
import 'package:shop_keeper_project/core/widgets/premium_loader.dart';
import 'package:shop_keeper_project/core/utils/app_error_handler.dart';
import 'package:shop_keeper_project/core/localization/app_strings.dart';
import 'package:uuid/uuid.dart';

class ExpenseListScreen extends StatefulWidget {
  const ExpenseListScreen({super.key});

  @override
  State<ExpenseListScreen> createState() => _ExpenseListScreenState();
}

class _ExpenseListScreenState extends State<ExpenseListScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    context.read<ExpensesCubit>().loadTodayExpenses();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackgroundMain,
      appBar: AppBar(
        title: Text(AppStrings.get('expenses').toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 2)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: AppTheme.textWhite),
              onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
              decoration: InputDecoration(
                hintText: AppStrings.get('search_expenses'),
                hintStyle: const TextStyle(color: AppTheme.textMuted),
                prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.textMuted),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, color: AppTheme.textMuted),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
              ),
            ),
          ),

          Expanded(
            child: BlocBuilder<ExpensesCubit, ExpensesState>(
              builder: (context, state) {
                if (state is ExpensesLoading) {
                  return const PremiumLoader();
                } else if (state is ExpensesLoaded) {
                  final filtered = state.expenses.where((e) {
                    if (_searchQuery.isEmpty) return true;
                    return e.title.toLowerCase().contains(_searchQuery) ||
                        e.category.toLowerCase().contains(_searchQuery);
                  }).toList();

                  if (state.expenses.isEmpty) {
                    return EmptyStateWidget(
                      icon: Icons.account_balance_wallet_rounded,
                      title: AppStrings.get('no_outflow_logged'),
                      message: AppStrings.get('no_outflow_message'),
                    );
                  }

                  if (filtered.isEmpty) {
                    return Center(
                      child: Text(AppStrings.get('no_matching_records'), style: const TextStyle(color: AppTheme.textMuted)),
                    );
                  }

                  return Container(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: Alignment.bottomRight,
                        radius: 1.5,
                        colors: [
                          AppTheme.dangerRose.withOpacity(0.03),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 24, 16, 100),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final expense = filtered[index];
                        return Dismissible(
                          key: Key('expense-${expense.id}'),
                          direction: DismissDirection.endToStart,
                          confirmDismiss: (direction) async {
                            return await ConfirmDialog.danger(
                              context,
                              title: AppStrings.get('confirm_delete'),
                              message: 'Remove this expense log?\n\nItem: ${expense.title}\nAmount: ₹${expense.amount}',
                            );
                          },
                          background: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: AppTheme.dangerRose.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: AppTheme.dangerRose.withOpacity(0.3)),
                            ),
                            padding: const EdgeInsets.only(right: 24),
                            alignment: Alignment.centerRight,
                            child: const Icon(Icons.delete_sweep_rounded, color: AppTheme.dangerRose, size: 28),
                          ),
                          onDismissed: (direction) {
                            context.read<ExpensesCubit>().deleteExpense(expense.id);
                            AppErrorHandler.showInfo(context, '${expense.title} ${AppStrings.get('expense_removed')}');
                          },
                          child: GlassCard(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                              leading: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: AppTheme.dangerRose.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.arrow_outward_rounded, color: AppTheme.dangerRose, size: 20),
                              ),
                              title: Text(
                                expense.title.toUpperCase(), 
                                style: const TextStyle(fontWeight: FontWeight.w900, color: AppTheme.textWhite, fontSize: 14, letterSpacing: 0.5),
                              ),
                              subtitle: Text(
                                expense.category, 
                                style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
                              ),
                              trailing: Text(
                                '₹${expense.amount.toStringAsFixed(0)}', 
                                style: const TextStyle(color: AppTheme.dangerRose, fontSize: 18, fontWeight: FontWeight.w900),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                } else if (state is ExpensesError) {
                  return Center(child: Text('${AppStrings.get('error')}: ${state.message}', style: const TextStyle(color: AppTheme.dangerRose)));
                }
                return const SizedBox();
              },
            ),
          ),
        ],
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            colors: [AppTheme.primaryIndigo, AppTheme.accentTeal],
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryIndigo.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: () => _showAddExpenseDialog(context),
          backgroundColor: Colors.transparent,
          elevation: 0,
          label: Text(AppStrings.get('record_expense'), style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.2)),
          icon: const Icon(Icons.remove_circle_outline_rounded),
        ),
      ),
    );
  }

  void _showAddExpenseDialog(BuildContext context) {
    final titleController = TextEditingController();
    final amountController = TextEditingController();
    String category = AppStrings.get('rent_bills');

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        decoration: const BoxDecoration(
          color: AppTheme.darkBackgroundLayer,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(AppStrings.get('record_expense'), style: const TextStyle(fontWeight: FontWeight.w900, color: AppTheme.textWhite, letterSpacing: 2)),
              const SizedBox(height: 32),
              CustomTextField(
                label: AppStrings.get('expense_title'),
                controller: titleController,
                hintText: AppStrings.get('expense_hint'),
                prefixIcon: Icons.description_outlined,
              ),
              const SizedBox(height: 24),
              Text(AppStrings.get('category'), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.textGrey, letterSpacing: 0.5)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: AppTheme.darkBackgroundMain.withOpacity(0.35),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.08)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButtonFormField<String>(
                    dropdownColor: AppTheme.darkBackgroundLayer,
                    isExpanded: true,
                    value: category,
                    style: const TextStyle(color: AppTheme.textWhite, fontWeight: FontWeight.w500),
                    decoration: const InputDecoration(border: InputBorder.none),
                    items: [
                      AppStrings.get('rent_bills'),
                      AppStrings.get('stock_purchase'),
                      AppStrings.get('staff_salary'),
                      AppStrings.get('others'),
                    ]
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (val) => category = val!,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              CustomTextField(
                label: AppStrings.get('amount'),
                controller: amountController,
                hintText: '₹0.00',
                keyboardType: TextInputType.number,
                prefixIcon: Icons.payments_outlined,
              ),
              const SizedBox(height: 48),
              Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: const LinearGradient(colors: [AppTheme.primaryIndigo, AppTheme.accentTeal]),
                ),
                child: ElevatedButton(
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
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text(AppStrings.get('save_record'), style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
