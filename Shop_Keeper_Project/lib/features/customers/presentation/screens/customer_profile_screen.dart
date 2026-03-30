import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:shop_keeper_project/core/theme/app_theme.dart';
import 'package:shop_keeper_project/core/widgets/glass_card.dart';
import 'package:shop_keeper_project/core/widgets/empty_state_widget.dart';
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
          left: 20, right: 20, top: 24,
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
              isCredit ? 'GIVE CREDIT (UDHAR)' : 'RECORD PAYMENT',
              style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.w900,
                color: isCredit ? AppTheme.dangerRose : AppTheme.successEmerald,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              autofocus: true,
              style: const TextStyle(
                color: AppTheme.textWhite, fontSize: 28,
                fontWeight: FontWeight.w900,
              ),
              decoration: InputDecoration(
                labelText: 'Amount (₹)',
                prefixIcon: Icon(
                  Icons.currency_rupee_rounded,
                  color: isCredit ? AppTheme.dangerRose : AppTheme.successEmerald,
                ),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: descController,
              style: const TextStyle(color: AppTheme.textWhite),
              decoration: const InputDecoration(
                labelText: 'Description (optional)',
                prefixIcon: Icon(Icons.description_outlined, color: AppTheme.textMuted),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  final amount = double.tryParse(amountController.text);
                  if (amount == null || amount <= 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Enter a valid amount')),
                    );
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
                  // Reload transactions
                  Future.delayed(const Duration(milliseconds: 300), () {
                    if (mounted) {
                      context.read<CustomerCubit>().loadTransactions(widget.customerId);
                    }
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isCredit ? AppTheme.dangerRose : AppTheme.successEmerald,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text(
                  isCredit ? 'GIVE CREDIT' : 'RECORD PAYMENT',
                  style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w800,
                    letterSpacing: 1.5, color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _sendWhatsAppReminder(CustomerEntity customer) async {
    final amount = NumberFormat('#,##0').format(customer.totalCredit);
    final msg = Uri.encodeComponent(
      'Bhai, aapka ₹$amount baki hai. Kripya jaldi se payment kar dijiye. 🙏\n— ${customer.name}',
    );
    final phone = customer.phone.replaceAll(RegExp(r'[^0-9]'), '');
    final phoneWithCode = phone.startsWith('91') ? phone : '91$phone';
    final url = 'https://wa.me/$phoneWithCode?text=$msg';

    try {
      const platform = MethodChannel('app.channel.shared.data');
      // Try Android intent approach first, fallback to clipboard
      try {
        await platform.invokeMethod('openUrl', {'url': url});
      } catch (_) {
        // Fallback: copy link to clipboard
        await Clipboard.setData(ClipboardData(text: url));
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('WhatsApp link copied! Paste in browser to send.')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('CUSTOMER PROFILE'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: BlocBuilder<CustomerCubit, CustomerState>(
        builder: (context, state) {
          // Find customer from loaded state or handle loading
          CustomerEntity? customer;
          List<CreditTransactionEntity> transactions = [];

          if (state is CustomerLoaded) {
            customer = state.customers.where((c) => c.id == widget.customerId).firstOrNull;
          } else if (state is TransactionsLoaded) {
            transactions = state.transactions;
            // We need to get customer data - fetch from cubit's previous state
          }

          return _buildProfileContent(customer, transactions, state);
        },
      ),
    );
  }

  Widget _buildProfileContent(CustomerEntity? customer, List<CreditTransactionEntity> transactions, CustomerState state) {
    if (state is TransactionsLoading) {
      return const Center(child: CircularProgressIndicator(color: AppTheme.primaryIndigo));
    }

    if (state is TransactionsLoaded) {
      transactions = state.transactions;
    }

    // For now, build UI with what we have from transactions
    return CustomScrollView(
      slivers: [
        // Customer Header Card
        if (customer != null) ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: GlassCard(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // Avatar
                      Container(
                        width: 72, height: 72,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              AppTheme.primaryIndigo.withOpacity(0.4),
                              AppTheme.accentTeal.withOpacity(0.3),
                            ],
                          ),
                          border: Border.all(color: AppTheme.primaryIndigo.withOpacity(0.4), width: 2),
                        ),
                        child: Center(
                          child: Text(
                            customer.name[0].toUpperCase(),
                            style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w900, color: AppTheme.textWhite),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        customer.name,
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppTheme.textWhite),
                      ),
                      const SizedBox(height: 4),
                      Text(customer.phone, style: const TextStyle(fontSize: 14, color: AppTheme.textMuted)),
                      if (customer.notes != null) ...[
                        const SizedBox(height: 4),
                        Text(customer.notes!, style: const TextStyle(fontSize: 12, color: AppTheme.textGrey, fontStyle: FontStyle.italic)),
                      ],
                      const SizedBox(height: 16),

                      // Balance Display
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                        decoration: BoxDecoration(
                          color: customer.hasOutstandingCredit
                              ? AppTheme.dangerRose.withOpacity(0.12)
                              : AppTheme.successEmerald.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: customer.hasOutstandingCredit
                                ? AppTheme.dangerRose.withOpacity(0.3)
                                : AppTheme.successEmerald.withOpacity(0.3),
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'OUTSTANDING BALANCE',
                              style: TextStyle(
                                fontSize: 10, fontWeight: FontWeight.w700,
                                color: customer.hasOutstandingCredit ? AppTheme.dangerRose : AppTheme.successEmerald,
                                letterSpacing: 2,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              customer.hasOutstandingCredit
                                  ? '₹${NumberFormat('#,##0').format(customer.totalCredit)}'
                                  : '✓ ALL SETTLED',
                              style: TextStyle(
                                fontSize: 32, fontWeight: FontWeight.w900,
                                color: customer.hasOutstandingCredit ? AppTheme.dangerRose : AppTheme.successEmerald,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // WhatsApp Reminder (only if outstanding)
                      if (customer.hasOutstandingCredit) ...[
                        const SizedBox(height: 14),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton.icon(
                            onPressed: () => _sendWhatsAppReminder(customer),
                            icon: const Icon(Icons.message_rounded, color: Colors.white, size: 20),
                            label: const Text(
                              'SEND WHATSAPP REMINDER',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, letterSpacing: 1, color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF25D366),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.05),
            ),
          ),
        ],

        // Action Buttons
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: () => _showAmountDialog(isCredit: true),
                      icon: const Icon(Icons.add_circle_outline_rounded, color: Colors.white),
                      label: const Text(
                        'GAVE CREDIT',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, letterSpacing: 1, color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.dangerRose,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: () => _showAmountDialog(isCredit: false),
                      icon: const Icon(Icons.check_circle_outline_rounded, color: Colors.white),
                      label: const Text(
                        'GOT PAYMENT',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, letterSpacing: 1, color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.successEmerald,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 400.ms, delay: 200.ms),
        ),

        // Ledger Header
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: Text(
              'TRANSACTION LEDGER',
              style: TextStyle(
                fontSize: 12, fontWeight: FontWeight.w800,
                color: AppTheme.textMuted, letterSpacing: 2,
              ),
            ),
          ),
        ),

        // Transaction List
        if (transactions.isEmpty)
          const SliverFillRemaining(
            hasScrollBody: false,
            child: EmptyStateWidget(
              icon: Icons.receipt_long_outlined,
              title: 'No Transactions',
              message: 'Credit and payment history will appear here',
            ),
          )
        else
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final tx = transactions[index];
                return _buildTransactionItem(tx, index);
              },
              childCount: transactions.length,
            ),
          ),

        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }

  Widget _buildTransactionItem(CreditTransactionEntity tx, int index) {
    final isCredit = tx.isCredit;
    final color = isCredit ? AppTheme.dangerRose : AppTheme.successEmerald;
    final icon = isCredit ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded;
    final prefix = isCredit ? '+' : '-';
    final dateStr = DateFormat('dd MMM yy, hh:mm a').format(tx.date);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: GlassCard(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withOpacity(0.15),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isCredit ? 'Credit Given' : 'Payment Received',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.textWhite),
                    ),
                    if (tx.description != null && tx.description!.isNotEmpty)
                      Text(
                        tx.description!,
                        style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                        maxLines: 1, overflow: TextOverflow.ellipsis,
                      ),
                    Text(dateStr, style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$prefix₹${NumberFormat('#,##0').format(tx.amount)}',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: color),
                  ),
                  Text(
                    'Bal: ₹${NumberFormat('#,##0').format(tx.balanceAfter)}',
                    style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 250.ms, delay: (40 * index).ms);
  }
}
