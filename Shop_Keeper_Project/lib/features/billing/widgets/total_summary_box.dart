import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shop_keeper_project/core/theme/app_theme.dart';
import 'package:shop_keeper_project/core/widgets/glass_card.dart';
import 'package:shop_keeper_project/features/customers/presentation/bloc/customer_cubit.dart';
import 'package:shop_keeper_project/features/customers/domain/entities/customer_entity.dart';
import 'package:shop_keeper_project/core/localization/app_strings.dart';
import '../bloc/billing_bloc.dart';
import '../bloc/billing_event.dart';
import '../model/billing_summary.dart';

class TotalSummaryBox extends StatelessWidget {
  final double totalAmount;
  final BillingSummary? summary;

  const TotalSummaryBox({super.key, required this.totalAmount, this.summary});

  void _showDiscountDialog(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final percentController = TextEditingController();
    final flatController = TextEditingController();

    // Pre-fill current discount
    if (summary != null) {
      if (summary!.discount.percentage > 0) {
        percentController.text = summary!.discount.percentage.toStringAsFixed(0);
      }
      if (summary!.discount.flatAmount > 0) {
        flatController.text = summary!.discount.flatAmount.toStringAsFixed(0);
      }
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          left: 20, right: 20, top: 24,
        ),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          border: Border.all(color: (isDark ? Colors.white : Colors.black).withOpacity(0.08)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: (isDark ? Colors.white24 : Colors.black12),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              AppStrings.get('apply_discount').toUpperCase(),
              style: const TextStyle(
                fontSize: 18, fontWeight: FontWeight.w900,
                color: AppTheme.successEmerald, letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: percentController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 22, fontWeight: FontWeight.w800),
              decoration: InputDecoration(
                labelText: 'Discount %',
                labelStyle: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                prefixIcon: const Icon(Icons.percent_rounded, color: AppTheme.successEmerald),
                hintText: '0',
                hintStyle: TextStyle(color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5)),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: flatController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 22, fontWeight: FontWeight.w800),
              decoration: InputDecoration(
                labelText: 'Flat Discount (₹)',
                labelStyle: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                prefixIcon: const Icon(Icons.currency_rupee_rounded, color: AppTheme.successEmerald),
                hintText: '0',
                hintStyle: TextStyle(color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5)),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  final pct = double.tryParse(percentController.text) ?? 0;
                  final flat = double.tryParse(flatController.text) ?? 0;
                  context.read<BillingBloc>().add(
                    ApplyDiscount(DiscountConfig(percentage: pct, flatAmount: flat)),
                  );
                  Navigator.pop(ctx);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.successEmerald,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text(
                  AppStrings.get('apply_discount').toUpperCase(),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: 1.5, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCheckoutDialog(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    String? selectedCustomerId;
    String? selectedCustomerName;
    bool isCreditSale = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          final customerState = context.read<CustomerCubit>().state;
          List<CustomerEntity> customers = [];
          if (customerState is CustomerLoaded) {
            customers = customerState.customers;
          }

          return Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              left: 20, right: 20, top: 24,
            ),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              border: Border.all(color: (isDark ? Colors.white : Colors.black).withOpacity(0.08)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40, height: 4,
                    decoration: BoxDecoration(
                      color: (isDark ? Colors.white24 : Colors.black12),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  AppStrings.get('confirm_action').toUpperCase(),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppTheme.accentTeal, letterSpacing: 2),
                ),
                const SizedBox(height: 20),

                // Customer Selection
                if (customers.isNotEmpty) ...[
                  Text(AppStrings.get('search_customers'), style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: theme.colorScheme.onSurfaceVariant, letterSpacing: 1)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: (isDark ? Colors.black : Colors.grey).withOpacity(0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: (isDark ? Colors.white : Colors.black).withOpacity(0.05)),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String?>(
                        isExpanded: true,
                        value: selectedCustomerId,
                        dropdownColor: theme.colorScheme.surface,
                        style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 16),
                        hint: Text('Walk-in Customer', style: TextStyle(color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5))),
                        items: [
                          DropdownMenuItem(value: null, child: Text('Walk-in Customer', style: TextStyle(color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5)))),
                          ...customers.map((c) => DropdownMenuItem(
                            value: c.id,
                            child: Text(c.name, style: TextStyle(color: theme.colorScheme.onSurface)),
                          )),
                        ],
                        onChanged: (v) {
                          setSheetState(() {
                            selectedCustomerId = v;
                            selectedCustomerName = v != null
                                ? customers.firstWhere((c) => c.id == v).name
                                : null;
                            if (v == null) isCreditSale = false;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                ],

                // Credit Sale Toggle (only if customer selected)
                if (selectedCustomerId != null) ...[
                  GlassCard(
                    child: SwitchListTile(
                      title: Text(AppStrings.get('udhar').toUpperCase(), style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: theme.colorScheme.onSurface, letterSpacing: 1)),
                      subtitle: Text(AppStrings.get('manage_udhar_hint'), style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant)),
                      value: isCreditSale,
                      activeColor: AppTheme.dangerRose,
                      onChanged: (v) => setSheetState(() => isCreditSale = v),
                    ),
                  ),
                  const SizedBox(height: 14),
                ],

                // Summary
                if (summary != null) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: (isDark ? Colors.black : Colors.grey).withOpacity(0.03),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.accentTeal.withOpacity(0.2)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isCreditSale ? AppStrings.get('udhar').toUpperCase() : AppStrings.get('total'),
                          style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w800,
                            color: isCreditSale ? AppTheme.dangerRose : AppTheme.accentTeal,
                            letterSpacing: 1,
                          ),
                        ),
                        Text(
                          '₹${summary!.totalPayable.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 28, fontWeight: FontWeight.w900,
                            color: isCreditSale ? AppTheme.dangerRose : AppTheme.accentTeal,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                // Confirm Button
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                        colors: isCreditSale
                            ? [AppTheme.dangerRose, AppTheme.dangerRose.withOpacity(0.7)]
                            : [AppTheme.primaryIndigo, AppTheme.accentTeal],
                      ),
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        context.read<BillingBloc>().add(GenerateBill(
                          customerName: selectedCustomerName ?? 'Walk-in Customer',
                          customerId: selectedCustomerId,
                          isCreditSale: isCreditSale,
                        ));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            isCreditSale ? Icons.credit_card_rounded : Icons.check_circle_rounded,
                            color: Colors.white, size: 22,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            isCreditSale ? AppStrings.get('udhar').toUpperCase() : AppStrings.get('confirm_action').toUpperCase(),
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (totalAmount <= 0) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final s = summary;
    final subtotal = s?.subtotal ?? totalAmount;
    final discountAmt = s?.discountAmount ?? 0;
    final gstAmt = s?.gstAmount ?? 0;
    final gstRateStr = s != null ? (s.tax.gstRate * 100).toStringAsFixed(0) : '18';
    final payable = s?.totalPayable ?? totalAmount;

    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32.0)),
        border: Border.all(color: (isDark ? Colors.white : Colors.black).withOpacity(0.05), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          )
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildRow(context, AppStrings.get('total'), '₹${subtotal.toStringAsFixed(2)}', theme.colorScheme.onSurfaceVariant),
            const SizedBox(height: 10),
            if (discountAmt > 0) ...[
              InkWell(
                onTap: () => _showDiscountDialog(context),
                child: _buildRow(
                  context,
                  '${AppStrings.get('discount')}${s != null && s.discount.percentage > 0 ? ' (${s.discount.percentage.toStringAsFixed(0)}%)' : ''}',
                  '-₹${discountAmt.toStringAsFixed(2)}',
                  AppTheme.successEmerald,
                ),
              ),
              const SizedBox(height: 10),
            ],
            _buildRow(context, 'GST ($gstRateStr%)', '+₹${gstAmt.toStringAsFixed(2)}', theme.colorScheme.onSurfaceVariant),

            // Discount Button (if no discount applied yet)
            if (discountAmt <= 0) ...[
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () => _showDiscountDialog(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppTheme.successEmerald.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.successEmerald.withOpacity(0.2)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.local_offer_rounded, color: AppTheme.successEmerald, size: 16),
                      const SizedBox(width: 8),
                      Text(AppStrings.get('apply_discount').toUpperCase(), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppTheme.successEmerald, letterSpacing: 1)),
                    ],
                  ),
                ),
              ),
            ],

            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: Divider(color: Colors.black12, height: 1),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppStrings.get('total').toUpperCase(),
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: theme.colorScheme.onSurfaceVariant, letterSpacing: 1.5),
                ),
                Text(
                  '₹${payable.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: AppTheme.accentTeal, letterSpacing: -1),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: const LinearGradient(
                  colors: [AppTheme.primaryIndigo, AppTheme.accentTeal],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryIndigo.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  )
                ],
              ),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                onPressed: () => _showCheckoutDialog(context),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      AppStrings.get('confirm_action').toUpperCase(),
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1),
                    ),
                    const SizedBox(width: 12),
                    const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 22),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(BuildContext context, String label, String value, Color color) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 14, fontWeight: FontWeight.w500)),
        Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: color)),
      ],
    );
  }
}
