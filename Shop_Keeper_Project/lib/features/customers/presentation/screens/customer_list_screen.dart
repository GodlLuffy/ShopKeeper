import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:shop_keeper_project/core/theme/app_theme.dart';
import 'package:shop_keeper_project/core/widgets/glass_card.dart';
import 'package:shop_keeper_project/core/widgets/empty_state_widget.dart';
import 'package:shop_keeper_project/core/widgets/confirm_dialog.dart';
import 'package:shop_keeper_project/core/localization/app_strings.dart';
import 'package:shop_keeper_project/features/customers/presentation/bloc/customer_cubit.dart';
import 'package:shop_keeper_project/features/customers/domain/entities/customer_entity.dart';
import 'package:shop_keeper_project/core/widgets/premium_loader.dart';
import 'package:shop_keeper_project/core/utils/app_error_handler.dart';
import 'package:intl/intl.dart';

class CustomerListScreen extends StatefulWidget {
  const CustomerListScreen({super.key});

  @override
  State<CustomerListScreen> createState() => _CustomerListScreenState();
}

class _CustomerListScreenState extends State<CustomerListScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    context.read<CustomerCubit>().loadCustomers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showAddCustomerDialog() {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final notesController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
          left: 20,
          right: 20,
          top: 24,
        ),
        decoration: BoxDecoration(
          color: AppTheme.darkBackgroundLayer,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              AppStrings.get('new_customer'),
              style: const TextStyle(
                fontSize: 18, fontWeight: FontWeight.w900,
                color: AppTheme.textWhite, letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: nameController,
              style: const TextStyle(color: AppTheme.textWhite),
              decoration: InputDecoration(
                labelText: AppStrings.get('customer_name'),
                prefixIcon: const Icon(Icons.person_outline_rounded, color: AppTheme.primaryIndigo),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              style: const TextStyle(color: AppTheme.textWhite),
              decoration: InputDecoration(
                labelText: AppStrings.get('phone_number'),
                prefixIcon: const Icon(Icons.phone_outlined, color: AppTheme.accentTeal),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: notesController,
              style: const TextStyle(color: AppTheme.textWhite),
              decoration: InputDecoration(
                labelText: AppStrings.get('notes_optional'),
                prefixIcon: const Icon(Icons.note_outlined, color: AppTheme.textMuted),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  if (nameController.text.trim().isEmpty || phoneController.text.trim().isEmpty) {
                    AppErrorHandler.showError(context, AppStrings.get('customer_required'));
                    return;
                  }
                  final customer = CustomerEntity(
                    id: const Uuid().v4(),
                    shopId: 'default_shop',
                    name: nameController.text.trim(),
                    phone: phoneController.text.trim(),
                    totalCredit: 0.0,
                    lastTransactionDate: DateTime.now(),
                    createdAt: DateTime.now(),
                    notes: notesController.text.trim().isEmpty ? null : notesController.text.trim(),
                  );
                  context.read<CustomerCubit>().addCustomer(customer);
                  Navigator.pop(ctx);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryIndigo,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text(
                  AppStrings.get('save'),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: 1.5, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(AppStrings.get('customers')),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_alt_1_rounded, color: AppTheme.primaryIndigo),
            onPressed: _showAddCustomerDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
                boxShadow: AppTheme.premiumShadow,
              ),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(color: AppTheme.textWhite, fontSize: 14),
                onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
                decoration: InputDecoration(
                  hintText: AppStrings.get('search_customers'),
                  hintStyle: const TextStyle(color: AppTheme.textMuted),
                  prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.textMuted),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 15),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, color: AppTheme.textMuted, size: 20),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                ),
              ),
            ),
          ),

          // Summary Card
          BlocBuilder<CustomerCubit, CustomerState>(
            builder: (context, state) {
              if (state is CustomerLoaded && state.customers.isNotEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: AppTheme.premiumShadow,
                      border: Border.all(color: Colors.white.withOpacity(0.05)),
                    ),
                    child: GlassCard(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildSummaryItem(
                              AppStrings.get('total'),
                              '${state.customers.length}',
                              AppTheme.primaryIndigo,
                            ),
                            Container(width: 1, height: 40, color: Colors.white.withOpacity(0.1)),
                            _buildSummaryItem(
                              AppStrings.get('udhar'),
                              '₹${NumberFormat('#,##0').format(state.totalOutstanding)}',
                              state.totalOutstanding > 0 ? AppTheme.dangerRose : AppTheme.successEmerald,
                            ),
                            Container(width: 1, height: 40, color: Colors.white.withOpacity(0.1)),
                            _buildSummaryItem(
                              AppStrings.get('active'),
                              '${state.customersWithCredit}',
                              AppTheme.warningAmber,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.1);
              }
              return const SizedBox.shrink();
            },
          ),

          // Customer List
          Expanded(
            child: BlocBuilder<CustomerCubit, CustomerState>(
              builder: (context, state) {
                if (state is CustomerLoading) {
                  return const PremiumLoader();
                }
                if (state is CustomerError) {
                  return Center(
                    child: Text(state.message, style: const TextStyle(color: AppTheme.dangerRose)),
                  );
                }
                if (state is CustomerLoaded) {
                  final filtered = state.customers.where((c) {
                    if (_searchQuery.isEmpty) return true;
                    return c.name.toLowerCase().contains(_searchQuery) ||
                        c.phone.contains(_searchQuery);
                  }).toList();

                  if (filtered.isEmpty) {
                    return EmptyStateWidget(
                      icon: Icons.people_outline_rounded,
                      title: _searchQuery.isEmpty ? AppStrings.get('no_customers_yet') : AppStrings.get('no_results'),
                      message: _searchQuery.isEmpty
                          ? AppStrings.get('add_first_customer_message')
                          : AppStrings.get('try_different_search'),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final customer = filtered[index];
                      return Dismissible(
                        key: Key('customer-${customer.id}'),
                        direction: DismissDirection.endToStart,
                        confirmDismiss: (direction) async {
                          return await ConfirmDialog.danger(
                            context,
                            title: AppStrings.get('confirm_delete'),
                            message: '${AppStrings.get('delete_warning')}\n\nCustomer: ${customer.name}',
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
                          context.read<CustomerCubit>().deleteCustomer(customer.id);
                          AppErrorHandler.showInfo(context, '${customer.name} ${AppStrings.get('expense_removed')}');
                        },
                        child: _buildCustomerCard(customer, index),
                      );
                    },
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddCustomerDialog,
        backgroundColor: AppTheme.primaryIndigo,
        child: const Icon(Icons.person_add_alt_1_rounded, color: Colors.white),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: color),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppTheme.textMuted, letterSpacing: 1),
        ),
      ],
    );
  }

  Widget _buildCustomerCard(CustomerEntity customer, int index) {
    final hasCredit = customer.hasOutstandingCredit;
    final creditColor = hasCredit ? AppTheme.dangerRose : AppTheme.successEmerald;
    final creditText = hasCredit
        ? '- ₹${NumberFormat('#,##0').format(customer.totalCredit)}'
        : '✓ ${AppStrings.get('settled')}';

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: AppTheme.premiumShadow,
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: GlassCard(
          child: InkWell(
            borderRadius: BorderRadius.circular(24),
          onTap: () => context.push('/customers/${customer.id}'),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Avatar
                Container(
                  width: 50, height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.primaryIndigo.withOpacity(0.3),
                        AppTheme.accentTeal.withOpacity(0.2),
                      ],
                    ),
                    border: Border.all(color: AppTheme.primaryIndigo.withOpacity(0.3)),
                  ),
                  child: Center(
                    child: Text(
                      customer.name[0].toUpperCase(),
                      style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.w900, color: AppTheme.textWhite,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),

                // Name & Phone
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        customer.name,
                        style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textWhite,
                        ),
                        maxLines: 1, overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        customer.phone,
                        style: const TextStyle(fontSize: 13, color: AppTheme.textMuted),
                      ),
                    ],
                  ),
                ),

                // Credit Balance
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      creditText,
                      style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w900, color: creditColor,
                      ),
                    ),
                    if (hasCredit) ...[
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppTheme.dangerRose.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                          child: Text(
                            AppStrings.get('udhar'),
                            style: const TextStyle(
                              fontSize: 9, fontWeight: FontWeight.w800,
                              color: AppTheme.dangerRose, letterSpacing: 1.5,
                            ),
                          ),
                      ),
                    ],
                  ],
                ),

                const SizedBox(width: 8),
                const Icon(Icons.chevron_right_rounded, color: AppTheme.textMuted, size: 20),
              ],
            ),
        ),
      ),
    ))).animate().fadeIn(duration: 300.ms, delay: (50 * index).ms).slideX(begin: 0.05);
  }
}
