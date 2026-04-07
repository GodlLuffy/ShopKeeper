import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:shop_keeper_project/core/theme/app_colors.dart';
import 'package:shop_keeper_project/core/widgets/glass_card.dart';
import 'package:shop_keeper_project/core/widgets/empty_state_widget.dart';
import 'package:shop_keeper_project/core/widgets/premium_loader.dart';
import 'package:shop_keeper_project/core/widgets/custom_text_field.dart';
import 'package:shop_keeper_project/core/widgets/primary_button.dart';
import 'package:shop_keeper_project/core/utils/app_error_handler.dart';
import 'package:shop_keeper_project/features/customers/presentation/bloc/customer_cubit.dart';
import 'package:shop_keeper_project/features/customers/domain/entities/customer_entity.dart';
import 'package:shop_keeper_project/features/customers/domain/entities/credit_transaction_entity.dart';

class CustomerProfileScreen extends StatefulWidget {
  final String customerId;
  const CustomerProfileScreen({super.key, required this.customerId});

  @override
  State<CustomerProfileScreen> createState() => _CustomerProfileScreenState();
}

class _CustomerProfileScreenState extends State<CustomerProfileScreen> {
  @override
  void initState() {
    super.initState();
    context.read<CustomerCubit>().loadTransactions(widget.customerId);
  }

  void _showAmountDialog({required bool isCredit}) {
    final amountController = TextEditingController();
    final descController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
          left: 24, right: 24, top: 12,
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
                Icon(
                  isCredit ? LucideIcons.arrowUpCircle : LucideIcons.arrowDownCircle,
                  color: isCredit ? AppColors.error : AppColors.success,
                  size: 24,
                ),
                const SizedBox(width: 16),
                Text(
                  isCredit ? 'DEBIT AUTHORIZATION' : 'PAYMENT RECEIPT',
                  style: GoogleFonts.outfit(
                    fontSize: 14, fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary, letterSpacing: 2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            
            // Amount Input
            Text(
              'TRANSACTION AMOUNT (₹)',
              style: GoogleFonts.outfit(
                fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.textMuted, letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.glassBorder),
              ),
              child: TextField(
                controller: amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                autofocus: true,
                style: GoogleFonts.outfit(
                  color: isCredit ? AppColors.error : AppColors.success,
                  fontSize: 32, fontWeight: FontWeight.w900,
                ),
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  hintText: '0.00',
                  hintStyle: GoogleFonts.outfit(color: AppColors.textMuted.withOpacity(0.3)),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 20),
                ),
              ),
            ),

            const SizedBox(height: 24),
            
            // Description Input
            CustomTextField(
              controller: descController,
              label: 'REFERENCE / NOTES',
              hintText: 'ENTER TRANSACTION DETAILS...',
              prefixIcon: LucideIcons.fileText,
            ),

            const SizedBox(height: 40),
            PrimaryButton(
              text: isCredit ? 'AUTHORIZE CREDIT' : 'CONFIRM PAYMENT',
              
              onPressed: () {
                final amount = double.tryParse(amountController.text);
                if (amount == null || amount <= 0) {
                  AppErrorHandler.showError(context, 'VALID AMOUNT REQUIRED');
                  return;
                }
                if (isCredit) {
                  context.read<CustomerCubit>().addCredit(
                    widget.customerId, amount,
                    description: descController.text.trim().isEmpty ? null : descController.text.trim(),
                  );
                } else {
                  context.read<CustomerCubit>().recordPayment(
                    widget.customerId, amount,
                    description: descController.text.trim().isEmpty ? null : descController.text.trim(),
                  );
                }
                Navigator.pop(ctx);
                Future.delayed(const Duration(milliseconds: 300), () {
                  if (mounted) {
                    context.read<CustomerCubit>().loadTransactions(widget.customerId);
                  }
                });
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _sendWhatsAppReminder(CustomerEntity customer) async {
    final amount = NumberFormat('#,##0').format(customer.totalCredit);
    final msg = Uri.encodeComponent(
      'DEAR ${customer.name.toUpperCase()},\n\nTHIS IS A COURTESY REMINDER REGARDING YOUR OUTSTANDING BALANCE OF ₹$amount. PLEASE ARRANGE FOR SETTLEMENT AT YOUR EARLIEST CONVENIENCE.\n\nTHANK YOU.',
    );
    final phone = customer.phone.replaceAll(RegExp(r'[^0-9]'), '');
    final phoneWithCode = phone.startsWith('91') ? phone : '91$phone';
    final url = 'https://wa.me/$phoneWithCode?text=$msg';

    try {
      const platform = MethodChannel('app.channel.shared.data');
      try {
        await platform.invokeMethod('openUrl', {'url': url});
      } catch (_) {
        await Clipboard.setData(ClipboardData(text: url));
        if (mounted) {
          AppErrorHandler.showInfo(context, 'REMINDER LINK COPIED TO CLIPBOARD');
        }
      }
    } catch (e) {
      if (mounted) {
        AppErrorHandler.showError(context, 'COMMUNICATION ERROR: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(
          'CLIENT PROFILE',
          style: GoogleFonts.outfit(fontWeight: FontWeight.w900, letterSpacing: 2, fontSize: 15),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(LucideIcons.chevronLeft),
          onPressed: () => context.pop(),
        ),
      ),
      body: BlocBuilder<CustomerCubit, CustomerState>(
        builder: (context, state) {
          CustomerEntity? customer;
          List<CreditTransactionEntity> transactions = [];

          if (state is CustomerLoaded) {
            customer = state.customers.where((c) => c.id == widget.customerId).firstOrNull;
          } else if (state is TransactionsLoaded) {
            transactions = state.transactions;
            // In a real app, we'd ensure customer data is available here
          }

          return _buildProfileContent(customer, transactions, state);
        },
      ),
    );
  }

  Widget _buildProfileContent(CustomerEntity? customer, List<CreditTransactionEntity> transactions, CustomerState state) {
    if (state is TransactionsLoading) {
      return const PremiumLoader();
    }

    if (state is TransactionsLoaded) {
      transactions = state.transactions;
    }

    return CustomScrollView(
      slivers: [
        // Customer Header Card
        if (customer != null) ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: GlassCard(
                padding: const EdgeInsets.all(32),
                backgroundOpacity: 0.05,
                child: Column(
                  children: [
                    // Premium Avatar
                    Container(
                      width: 80, height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: AppColors.glassBorder, width: 2),
                      ),
                      child: Center(
                        child: Text(
                          customer.name[0].toUpperCase(),
                          style: GoogleFonts.outfit(
                            fontSize: 34, fontWeight: FontWeight.w900, color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      customer.name.toUpperCase(),
                      style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.textPrimary, letterSpacing: 1),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(LucideIcons.phone, size: 14, color: AppColors.textMuted),
                        const SizedBox(width: 8),
                        Text(
                          customer.phone,
                          style: GoogleFonts.outfit(fontSize: 14, color: AppColors.textMuted, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    if (customer.notes != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        customer.notes!.toUpperCase(),
                        style: GoogleFonts.outfit(fontSize: 11, color: AppColors.textMuted.withOpacity(0.6), fontWeight: FontWeight.w700, letterSpacing: 0.5),
                        textAlign: TextAlign.center,
                      ),
                    ],
                    const SizedBox(height: 32),

                    // Balance Display
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: AppColors.glassBorder),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'CURRENT OUTSTANDING',
                            style: GoogleFonts.outfit(
                              fontSize: 10, fontWeight: FontWeight.w800,
                              color: AppColors.textMuted, letterSpacing: 2,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            hasOutstandingCredit(customer.totalCredit)
                                ? '₹${NumberFormat('#,##0').format(customer.totalCredit)}'
                                : 'SETTLED',
                            style: GoogleFonts.outfit(
                              fontSize: 36, fontWeight: FontWeight.w900,
                              color: hasOutstandingCredit(customer.totalCredit) ? AppColors.error : AppColors.success,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // WhatsApp Reminder
                    if (hasOutstandingCredit(customer.totalCredit)) ...[
                      const SizedBox(height: 20),
                      TextButton.icon(
                        onPressed: () => _sendWhatsAppReminder(customer),
                        icon: const Icon(LucideIcons.messageSquare, color: AppColors.success, size: 18),
                        label: Text(
                          'SEND PAYMENT REMINDER',
                          style: GoogleFonts.outfit(
                            fontSize: 12, fontWeight: FontWeight.w900,
                            color: AppColors.success, letterSpacing: 1,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          backgroundColor: AppColors.success.withOpacity(0.05),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: AppColors.success.withOpacity(0.2)),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.05),
            ),
          ),
        ],

        // Action Buttons
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    label: 'GIVE CREDIT',
                    icon: LucideIcons.arrowUpCircle,
                    color: AppColors.error,
                    onTap: () => _showAmountDialog(isCredit: true),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildActionButton(
                    label: 'GOT PAYMENT',
                    icon: LucideIcons.arrowDownCircle,
                    color: AppColors.success,
                    onTap: () => _showAmountDialog(isCredit: false),
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 400.ms, delay: 200.ms),
        ),

        // Ledger Header
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 40, 24, 16),
            child: Row(
              children: [
                const Icon(LucideIcons.fileText, color: AppColors.primary, size: 16),
                const SizedBox(width: 12),
                Text(
                  'TRANSACTION LEDGER',
                  style: GoogleFonts.outfit(
                    fontSize: 12, fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary, letterSpacing: 2,
                  ),
                ),
                const Spacer(),
                Text(
                    'HISTORY',
                    style: GoogleFonts.outfit(fontSize: 10, color: AppColors.textMuted, fontWeight: FontWeight.w800, letterSpacing: 1),
                ),
              ],
            ),
          ),
        ),

        // Transaction List
        if (transactions.isEmpty)
          const SliverFillRemaining(
            hasScrollBody: false,
            child: EmptyStateWidget(
              icon: LucideIcons.history,
              title: 'NO RECORDED DATA',
              message: 'TRANSACTION HISTORY WILL BE ARCHIVED HERE',
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final tx = transactions[index];
                  return _buildTransactionItem(tx, index);
                },
                childCount: transactions.length,
              ),
            ),
          ),

        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }

  bool hasOutstandingCredit(double credit) => credit > 0;

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 12),
              Text(
                label,
                style: GoogleFonts.outfit(
                  fontSize: 12, fontWeight: FontWeight.w900, color: color, letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionItem(CreditTransactionEntity tx, int index) {
    final isCredit = tx.isCredit;
    final color = isCredit ? AppColors.error : AppColors.success;
    final icon = isCredit ? LucideIcons.arrowUpRight : LucideIcons.arrowDownLeft;
    final prefix = isCredit ? '+' : '-';
    final dateStr = DateFormat('dd MMM yy • HH:mm').format(tx.date).toUpperCase();

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        backgroundOpacity: 0.03,
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: color.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: color.withOpacity(0.1)),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isCredit ? 'CREDIT AUTHORIZED' : 'PAYMENT RECORDED',
                    style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    tx.description?.toUpperCase() ?? 'DIRECT SETTLEMENT',
                    style: GoogleFonts.outfit(fontSize: 11, color: AppColors.textMuted, fontWeight: FontWeight.w600),
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                      dateStr, 
                      style: GoogleFonts.outfit(fontSize: 9, color: AppColors.textMuted.withOpacity(0.5), fontWeight: FontWeight.w900, letterSpacing: 0.5)
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '$prefix₹${NumberFormat('#,##0').format(tx.amount)}',
                  style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w900, color: color),
                ),
                const SizedBox(height: 4),
                Text(
                  'BAL: ₹${NumberFormat('#,##0').format(tx.balanceAfter)}',
                  style: GoogleFonts.outfit(fontSize: 10, color: AppColors.textMuted, fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 250.ms, delay: (40 * index).ms).slideX(begin: 0.02);
  }
}
