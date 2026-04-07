import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shop_keeper_project/core/theme/app_colors.dart';
import 'package:shop_keeper_project/core/theme/app_theme.dart';
import 'package:shop_keeper_project/core/widgets/glass_card.dart';
import 'package:shop_keeper_project/features/customers/presentation/bloc/customer_cubit.dart';
import 'package:shop_keeper_project/features/customers/domain/entities/customer_entity.dart';
import 'package:shop_keeper_project/core/localization/app_strings.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../bloc/billing_bloc.dart';
import '../bloc/billing_event.dart';
import '../model/billing_summary.dart';

class TotalSummaryBox extends StatelessWidget {
  final double totalAmount;
  final BillingSummary? summary;

  const TotalSummaryBox({super.key, required this.totalAmount, this.summary});

  void _showDiscountDialog(BuildContext context) {
    final percentController = TextEditingController();
    final flatController = TextEditingController();

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
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 32,
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
              child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.textMuted, borderRadius: BorderRadius.circular(4))),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                const Icon(LucideIcons.tag, color: AppColors.success, size: 24),
                const SizedBox(width: 16),
                Text(
                  AppStrings.get('apply_discount').toUpperCase(),
                  style: GoogleFonts.outfit(
                    fontSize: 14, fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary, letterSpacing: 2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            _buildDiscountField(
              controller: percentController,
              label: 'DISCOUNT PERCENTAGE',
              hint: '0',
              prefix: '%',
              icon: LucideIcons.percent,
            ),
            const SizedBox(height: 20),
            _buildDiscountField(
              controller: flatController,
              label: 'FLAT DISCOUNT AMOUNT',
              hint: '0.00',
              prefix: '₹',
              icon: LucideIcons.banknote,
            ),
            const SizedBox(height: 32),
            Container(
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: AppColors.goldGradient,
                boxShadow: [
                  BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 5))
                ],
              ),
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
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text(
                  AppStrings.get('apply_discount').toUpperCase(),
                  style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 1.5, color: Colors.black),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDiscountField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required String prefix,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.textMuted, letterSpacing: 1.5),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.glassBorder),
          ),
          child: TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: GoogleFonts.outfit(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w800),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: AppColors.success, size: 20),
              suffixText: prefix,
              suffixStyle: GoogleFonts.outfit(color: AppColors.textMuted, fontWeight: FontWeight.w800),
              hintText: hint,
              hintStyle: GoogleFonts.outfit(color: AppColors.textMuted.withOpacity(0.3)),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            ),
          ),
        ),
      ],
    );
  }

  void _showCheckoutDialog(BuildContext context) {
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
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 32,
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
                  child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.textMuted, borderRadius: BorderRadius.circular(4))),
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    const Icon(LucideIcons.shoppingBag, color: AppColors.primary, size: 24),
                    const SizedBox(width: 16),
                    Text(
                      AppStrings.get('confirm_action').toUpperCase(),
                      style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.textPrimary, letterSpacing: 2),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                Text(
                  AppStrings.get('search_customers').toUpperCase(),
                  style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.textMuted, letterSpacing: 1.5),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.glassBorder),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String?>(
                      isExpanded: true,
                      value: selectedCustomerId,
                      dropdownColor: AppColors.surface,
                      icon: const Icon(LucideIcons.chevronDown, color: AppColors.textMuted, size: 20),
                      style: GoogleFonts.outfit(color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w600),
                      hint: Text('Walk-in Customer', style: GoogleFonts.outfit(color: AppColors.textMuted, fontWeight: FontWeight.w600)),
                      items: [
                        DropdownMenuItem(value: null, child: Text('Walk-in Customer (General)', style: GoogleFonts.outfit(color: AppColors.textMuted))),
                        ...customers.map((c) => DropdownMenuItem(
                          value: c.id,
                          child: Row(
                            children: [
                              const Icon(LucideIcons.user, size: 16, color: AppColors.primary),
                              const SizedBox(width: 12),
                              Text(c.name, style: GoogleFonts.outfit(color: AppColors.textPrimary)),
                            ],
                          ),
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
                const SizedBox(height: 24),

                if (selectedCustomerId != null) ...[
                  GlassCard(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    backgroundOpacity: 0.05,
                    child: SwitchListTile(
                      title: Text(AppStrings.get('udhar').toUpperCase(), style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w900, color: AppColors.textPrimary, letterSpacing: 1)),
                      subtitle: Text(AppStrings.get('manage_udhar_hint'), style: GoogleFonts.outfit(fontSize: 11, color: AppColors.textMuted)),
                      value: isCreditSale,
                      activeColor: AppColors.error,
                      onChanged: (v) => setSheetState(() => isCreditSale = v),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                if (summary != null) ...[
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isCreditSale ? AppColors.error.withOpacity(0.05) : AppColors.primary.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: isCreditSale ? AppColors.error.withOpacity(0.2) : AppColors.primary.withOpacity(0.2)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isCreditSale ? AppStrings.get('udhar').toUpperCase() : AppStrings.get('total').toUpperCase(),
                              style: GoogleFonts.outfit(
                                fontSize: 11, fontWeight: FontWeight.w900,
                                color: isCreditSale ? AppColors.error : AppColors.primary,
                                letterSpacing: 1.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              isCreditSale ? 'DEBT ACCOUNTING' : 'READY FOR PAYMENT',
                              style: GoogleFonts.outfit(fontSize: 10, color: AppColors.textMuted, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        Text(
                          '₹${summary!.totalPayable.toStringAsFixed(2)}',
                          style: GoogleFonts.outfit(
                            fontSize: 32, fontWeight: FontWeight.w900,
                            color: isCreditSale ? AppColors.error : AppColors.primary,
                            letterSpacing: -1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                ],

                SizedBox(
                  width: double.infinity,
                  height: 64,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: isCreditSale
                          ? const LinearGradient(colors: [AppColors.error, Color(0xFFFF5252)])
                          : AppColors.goldGradient,
                      boxShadow: [
                        BoxShadow(
                          color: (isCreditSale ? AppColors.error : AppColors.primary).withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        )
                      ],
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
                            isCreditSale ? LucideIcons.bookOpen : LucideIcons.checkCircle2,
                            color: isCreditSale ? Colors.white : Colors.black, size: 22,
                          ),
                          const SizedBox(width: 16),
                          Text(
                            isCreditSale ? AppStrings.get('udhar').toUpperCase() : AppStrings.get('confirm_action').toUpperCase(),
                            style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w900, color: isCreditSale ? Colors.white : Colors.black, letterSpacing: 1.5),
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

    final s = summary;
    final subtotal = s?.subtotal ?? totalAmount;
    final discountAmt = s?.discountAmount ?? 0;
    final gstAmt = s?.gstAmount ?? 0;
    final gstRateStr = s != null ? (s.tax.gstRate * 100).toStringAsFixed(0) : '18';
    final payable = s?.totalPayable ?? totalAmount;

    return Container(
      padding: const EdgeInsets.all(28.0),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(40.0)),
        border: Border(top: BorderSide(color: AppColors.glassBorder)),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 30,
            offset: Offset(0, -10),
          )
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildRow(AppStrings.get('total').toUpperCase(), '₹${subtotal.toStringAsFixed(2)}', AppColors.textPrimary),
            const SizedBox(height: 12),
            if (discountAmt > 0) ...[
              InkWell(
                onTap: () => _showDiscountDialog(context),
                child: _buildRow(
                  '${AppStrings.get('discount').toUpperCase()}${s != null && s.discount.percentage > 0 ? ' (${s.discount.percentage.toStringAsFixed(0)}%)' : ''}',
                  '-₹${discountAmt.toStringAsFixed(2)}',
                  AppColors.success,
                ),
              ),
              const SizedBox(height: 12),
            ],
            _buildRow('GST TAX ($gstRateStr%)'.toUpperCase(), '+₹${gstAmt.toStringAsFixed(2)}', AppColors.textMuted),

            if (discountAmt <= 0) ...[
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () => _showDiscountDialog(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.success.withOpacity(0.15)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(LucideIcons.tag, color: AppColors.success, size: 14),
                      const SizedBox(width: 10),
                      Text(AppStrings.get('apply_discount').toUpperCase(), style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w900, color: AppColors.success, letterSpacing: 1.5)),
                    ],
                  ),
                ),
              ),
            ],

            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24.0),
              child: Divider(color: AppColors.glassBorder, height: 1),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TOTAL PAYABLE',
                      style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w900, color: AppColors.textMuted, letterSpacing: 2),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'NET AMOUNT',
                      style: GoogleFonts.outfit(fontSize: 9, color: AppColors.textMuted.withOpacity(0.5), fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
                Text(
                  '₹${payable.toStringAsFixed(2)}',
                  style: GoogleFonts.outfit(fontSize: 36, fontWeight: FontWeight.w900, color: AppColors.primary, letterSpacing: -1.5),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Container(
              height: 64,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: AppColors.goldGradient,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  )
                ],
              ),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                onPressed: () => _showCheckoutDialog(context),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      AppStrings.get('confirm_action').toUpperCase(),
                      style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.black, letterSpacing: 2),
                    ),
                    const SizedBox(width: 16),
                    const Icon(LucideIcons.arrowRight, color: Colors.black, size: 20),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.outfit(color: AppColors.textMuted, fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 1)),
        Text(value, style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 14, color: color)),
      ],
    );
  }
}

