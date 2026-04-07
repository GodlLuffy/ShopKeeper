import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:shop_keeper_project/core/theme/app_colors.dart';
import 'package:shop_keeper_project/core/widgets/glass_card.dart';
import 'package:shop_keeper_project/core/widgets/empty_state_widget.dart';
import 'package:shop_keeper_project/core/widgets/confirm_dialog.dart';
import 'package:shop_keeper_project/core/widgets/custom_text_field.dart';
import 'package:shop_keeper_project/core/widgets/primary_button.dart';
import 'package:shop_keeper_project/features/customers/presentation/bloc/customer_cubit.dart';
import 'package:shop_keeper_project/features/customers/domain/entities/customer_entity.dart';
import 'package:shop_keeper_project/core/widgets/premium_loader.dart';
import 'package:shop_keeper_project/core/utils/app_error_handler.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

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

  String _getCustomerTag(CustomerEntity customer) {
    if (customer.totalCredit > 10000) return 'VIP';
    final daysSinceCreation = DateTime.now().difference(customer.createdAt).inDays;
    if (daysSinceCreation <= 30) return 'NEW';
    return 'REGULAR';
  }

  Color _getTagColor(String tag) {
    switch (tag) {
      case 'VIP':
        return AppColors.primary;
      case 'NEW':
        return AppColors.info;
      default:
        return AppColors.textMuted;
    }
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
          left: 24,
          right: 24,
          top: 12,
        ),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          border: Border(top: BorderSide(color: AppColors.glassBorder)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textMuted,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                const Icon(LucideIcons.userPlus, color: AppColors.primary, size: 24),
                const SizedBox(width: 16),
                Text(
                  'CLIENT REGISTRATION',
                  style: GoogleFonts.outfit(
                    fontSize: 14, fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary, letterSpacing: 2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            CustomTextField(
              controller: nameController,
              label: 'LEGAL NAME',
              hintText: 'ENTER FULL NAME...',
              prefixIcon: LucideIcons.user,
            ),
            const SizedBox(height: 20),
            CustomTextField(
              controller: phoneController,
              label: 'CONTACT NUMBER',
              hintText: '+91 XXXXX XXXXX',
              prefixIcon: LucideIcons.phone,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 20),
            CustomTextField(
              controller: notesController,
              label: 'ADDITIONAL NOTES',
              hintText: 'OPTIONAL CLIENT PROFILE DATA...',
              prefixIcon: LucideIcons.fileText,
            ),
            const SizedBox(height: 40),
            PrimaryButton(
              text: 'ARCHIVE RECORD',
              onPressed: () {
                if (nameController.text.trim().isEmpty || phoneController.text.trim().isEmpty) {
                  AppErrorHandler.showError(context, 'REQUIRED FIELDS ARE MISSING');
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
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(
          'CLIENT DIRECTORY',
          style: GoogleFonts.outfit(fontWeight: FontWeight.w900, letterSpacing: 2, fontSize: 15),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(LucideIcons.chevronLeft),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.userPlus, color: AppColors.primary),
            onPressed: _showAddCustomerDialog,
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: Column(
        children: [
          // Search Terminal
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
            child: Container(
              height: 54,
              decoration: BoxDecoration(
                color: AppColors.surface.withOpacity(0.8),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.glassBorder),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 15, offset: const Offset(0, 8))
                ],
              ),
              child: TextField(
                controller: _searchController,
                style: GoogleFonts.outfit(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w600),
                onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
                decoration: InputDecoration(
                  hintText: 'SEARCH BY NAME OR PHONE...',
                  hintStyle: GoogleFonts.outfit(color: AppColors.textMuted, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1),
                  prefixIcon: const Icon(LucideIcons.search, color: AppColors.primary, size: 18),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(LucideIcons.x, color: AppColors.textMuted, size: 18),
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

          // Executive Summary
          BlocBuilder<CustomerCubit, CustomerState>(
            builder: (context, state) {
              if (state is CustomerLoaded && state.customers.isNotEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: GlassCard(
                    padding: const EdgeInsets.all(24),
                    backgroundOpacity: 0.05,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildSummaryItem(
                          'CLIENTS',
                          '${state.customers.length}',
                          AppColors.textMuted,
                        ),
                        Container(width: 1, height: 32, color: AppColors.glassBorder),
                        _buildSummaryItem(
                          'TOTAL DEBT',
                          '₹${NumberFormat('#,##0').format(state.totalOutstanding)}',
                          AppColors.primary,
                        ),
                        Container(width: 1, height: 32, color: AppColors.glassBorder),
                        _buildSummaryItem(
                          'ACTIVE',
                          '${state.customersWithCredit}',
                          AppColors.warning,
                        ),
                      ],
                    ),
                  ),
                ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.1);
              }
              return const SizedBox.shrink();
            },
          ),

          const SizedBox(height: 16),

          // Client Manifest
          Expanded(
            child: BlocBuilder<CustomerCubit, CustomerState>(
              builder: (context, state) {
                if (state is CustomerLoading) {
                  return const PremiumLoader();
                }
                if (state is CustomerError) {
                  return Center(
                    child: Text(
                      state.message.toUpperCase(), 
                      style: GoogleFonts.outfit(color: AppColors.error, fontWeight: FontWeight.w900, letterSpacing: 1)
                    ),
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
                      icon: LucideIcons.users,
                      title: _searchQuery.isEmpty ? 'NO CLIENTS REGISTERED' : 'NO MATCHING DATA',
                      message: _searchQuery.isEmpty
                          ? 'START BUILDING YOUR CUSTOMER NETWORK'
                          : 'TRY REFINING YOUR SEARCH PARAMETERS',
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 100),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final customer = filtered[index];
                      return Dismissible(
                        key: Key('customer-${customer.id}'),
                        direction: DismissDirection.endToStart,
                        confirmDismiss: (direction) async {
                          return await ConfirmDialog.danger(
                            context,
                            title: 'REMOVE CLIENT RECORD?',
                            message: 'PROCEEDING WILL PERMANENTLY ERASE DATA FOR:\n\n${customer.name.toUpperCase()}',
                          );
                        },
                        background: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: AppColors.error.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.error.withOpacity(0.1)),
                          ),
                          padding: const EdgeInsets.only(right: 24),
                          alignment: Alignment.centerRight,
                          child: const Icon(LucideIcons.trash2, color: AppColors.error, size: 24),
                        ),
                        onDismissed: (direction) {
                          context.read<CustomerCubit>().deleteCustomer(customer.id);
                          AppErrorHandler.showInfo(context, 'RECORD REMOVED');
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
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: AppColors.goldGradient,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 8),
              )
            ],
          ),
          child: const Icon(LucideIcons.userPlus, color: Colors.black, size: 24),
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w900, color: color),
        ),
        const SizedBox(height: 6),
        Text(
          label.toUpperCase(),
          style: GoogleFonts.outfit(fontSize: 9, fontWeight: FontWeight.w800, color: AppColors.textMuted, letterSpacing: 1),
        ),
      ],
    );
  }

  Widget _buildCustomerCard(CustomerEntity customer, int index) {
    final hasCredit = customer.hasOutstandingCredit;
    final creditColor = hasCredit ? AppColors.error : AppColors.success;
    final creditText = hasCredit
        ? '₹${NumberFormat('#,##0').format(customer.totalCredit)}'
        : 'SETTLED';
    
    final tag = _getCustomerTag(customer);
    final tagColor = _getTagColor(tag);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        backgroundOpacity: 0.03,
        padding: EdgeInsets.zero,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () => context.push('/customers/${customer.id}'),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Premium Avatar
                Container(
                  width: 54, height: 54,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.glassBorder),
                  ),
                  child: Center(
                    child: Text(
                      customer.name[0].toUpperCase(),
                      style: GoogleFonts.outfit(
                        fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // Name & Metadata
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              customer.name.toUpperCase(),
                              style: GoogleFonts.outfit(
                                fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textPrimary,
                              ),
                              maxLines: 1, overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          _buildTag(tag, tagColor),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(LucideIcons.phone, size: 10, color: AppColors.textMuted),
                          const SizedBox(width: 6),
                          Text(
                            customer.phone,
                            style: GoogleFonts.outfit(fontSize: 11, color: AppColors.textMuted, fontWeight: FontWeight.w600),
                          ),
                        ],
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
                      style: GoogleFonts.outfit(
                        fontSize: 15, fontWeight: FontWeight.w900, color: creditColor,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'BALANCE',
                      style: GoogleFonts.outfit(
                        fontSize: 8, fontWeight: FontWeight.w900,
                        color: AppColors.textMuted, letterSpacing: 1,
                      ),
                    ),
                  ],
                ),

                const SizedBox(width: 12),
                const Icon(LucideIcons.chevronRight, color: AppColors.textMuted, size: 16),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 300.ms, delay: (50 * index).ms).slideX(begin: 0.05);
  }

  Widget _buildTag(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Text(
        label,
        style: GoogleFonts.outfit(
          fontSize: 7, fontWeight: FontWeight.w900, color: color, letterSpacing: 1,
        ),
      ),
    );
  }
}
