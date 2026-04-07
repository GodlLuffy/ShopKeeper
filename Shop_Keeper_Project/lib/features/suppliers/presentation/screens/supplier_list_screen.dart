import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import 'package:shop_keeper_project/core/theme/app_colors.dart';
import 'package:shop_keeper_project/core/widgets/glass_card.dart';
import 'package:shop_keeper_project/core/widgets/premium_loader.dart';
import 'package:shop_keeper_project/core/widgets/custom_text_field.dart';
import 'package:shop_keeper_project/core/widgets/primary_button.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shop_keeper_project/core/utils/app_error_handler.dart';
import 'package:shop_keeper_project/features/suppliers/domain/entities/supplier.dart';
import 'package:shop_keeper_project/features/suppliers/presentation/bloc/supplier_cubit.dart';

class SupplierListScreen extends StatefulWidget {
  const SupplierListScreen({super.key});

  @override
  State<SupplierListScreen> createState() => _SupplierListScreenState();
}

class _SupplierListScreenState extends State<SupplierListScreen> {
  @override
  void initState() {
    super.initState();
    context.read<SupplierCubit>().loadSuppliers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(
          'SUPPLIER LEDGER',
          style: GoogleFonts.outfit(fontWeight: FontWeight.w900, letterSpacing: 2, fontSize: 15),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(LucideIcons.chevronLeft),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocBuilder<SupplierCubit, SupplierState>(
        builder: (context, state) {
          if (state is SupplierLoading) {
            return const PremiumLoader(message: 'ACCESSING PROCUREMENT RECORDS...');
          } else if (state is SupplierLoaded) {
            final totalDebt = state.suppliers.fold(0.0, (sum, s) => sum + s.balance);
            
            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                    child: _buildStatsHeader(totalDebt),
                  ),
                ),
                if (state.suppliers.isEmpty)
                  SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(LucideIcons.truck, size: 64, color: AppColors.textMuted.withOpacity(0.1)),
                          const SizedBox(height: 24),
                          Text(
                            'NO REGISTERED VENDORS',
                            style: GoogleFonts.outfit(color: AppColors.textMuted, fontWeight: FontWeight.w900, letterSpacing: 1),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'BEGIN DOCUMENTING YOUR SUPPLY CHAIN',
                            style: GoogleFonts.outfit(color: AppColors.textMuted.withOpacity(0.5), fontSize: 11, fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => _buildSupplierCard(state.suppliers[index], index),
                        childCount: state.suppliers.length,
                      ),
                    ),
                  ),
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            );
          }
          return const SizedBox();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddSupplierDialog(context),
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          width: 56, height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: AppColors.goldGradient,
            boxShadow: [
              BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))
            ],
          ),
          child: const Icon(LucideIcons.truck, color: Colors.black, size: 24),
        ),
      ),
    );
  }

  Widget _buildStatsHeader(double totalDebt) {
    return GlassCard(
      padding: const EdgeInsets.all(32),
      backgroundOpacity: 0.05,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TOTAL ACCOUNTS PAYABLE',
                    style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w900, color: AppColors.textMuted, letterSpacing: 1.5),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '₹${NumberFormat('#,##0').format(totalDebt)}',
                    style: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.error.withOpacity(0.1)),
                ),
                child: const Icon(LucideIcons.arrowUpRight, color: AppColors.error, size: 24),
              ),
            ],
          ),
          const SizedBox(height: 32),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: totalDebt > 0 ? 1.0 : 0.0,
              backgroundColor: Colors.white.withOpacity(0.05),
              color: AppColors.primary,
              minHeight: 4,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'PROCUREMENT UTILIZATION',
                style: GoogleFonts.outfit(fontSize: 9, fontWeight: FontWeight.w800, color: AppColors.textMuted, letterSpacing: 1),
              ),
              Text(
                totalDebt > 0 ? 'ACTIVE' : 'CLEAR',
                style: GoogleFonts.outfit(fontSize: 9, fontWeight: FontWeight.w900, color: totalDebt > 0 ? AppColors.warning : AppColors.success),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSupplierCard(Supplier supplier, int index) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        backgroundOpacity: 0.05,
        child: Row(
          children: [
            // Letter Avatar with Gradient
            Container(
              height: 52, width: 52,
              decoration: BoxDecoration(
                gradient: AppColors.goldGradient,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: AppColors.primary.withOpacity(0.2), blurRadius: 8)
                ],
              ),
              child: Center(
                child: Text(
                  supplier.name[0].toUpperCase(),
                  style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.black),
                ),
              ),
            ),
            const SizedBox(width: 16),
            
            // Info Column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    supplier.name.toUpperCase(),
                    style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(LucideIcons.phone, size: 10, color: AppColors.textMuted),
                      const SizedBox(width: 6),
                      Text(
                        supplier.phone,
                        style: GoogleFonts.outfit(fontSize: 11, color: AppColors.textMuted, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  if (supplier.address != null && supplier.address!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(LucideIcons.mapPin, size: 10, color: AppColors.textMuted),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            supplier.address!.toUpperCase(),
                            maxLines: 1, overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.outfit(fontSize: 10, color: AppColors.textMuted.withOpacity(0.7), fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            
            // Actions & Balance
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(LucideIcons.phone, size: 18, color: AppColors.primary),
                      onPressed: () => launchUrl(Uri.parse('tel:${supplier.phone}')),
                    ),
                    Text(
                      '₹${NumberFormat('#,##0').format(supplier.balance)}',
                      style: GoogleFonts.outfit(
                        fontSize: 16, fontWeight: FontWeight.w900,
                        color: supplier.balance > 0 ? AppColors.error : AppColors.success,
                      ),
                    ),
                  ],
                ),
                Text(
                  'ACCOUNTS PAYABLE',
                  style: GoogleFonts.outfit(fontSize: 8, fontWeight: FontWeight.w900, color: AppColors.textMuted, letterSpacing: 1),
                ),
              ],
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 300.ms, delay: (50 * index).ms).slideX(begin: 0.05);
  }

  void _showAddSupplierDialog(BuildContext context) {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final contactController = TextEditingController();
    final addressController = TextEditingController();

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
        child: SingleChildScrollView(
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
                  const Icon(LucideIcons.truck, color: AppColors.primary, size: 24),
                  const SizedBox(width: 16),
                  Text(
                    'VENDOR REGISTRATION',
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
                label: 'BUSINESS NAME',
                hintText: 'ENTER LEGAL BUSINESS NAME...',
                prefixIcon: LucideIcons.building,
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
                controller: contactController,
                label: 'REPRESENTATIVE',
                hintText: 'REPRESENTATIVE NAME...',
                prefixIcon: LucideIcons.user,
              ),
              const SizedBox(height: 20),
              CustomTextField(
                controller: addressController,
                label: 'BUSINESS ADDRESS',
                hintText: 'CITY, STATE, ZIP...',
                prefixIcon: LucideIcons.mapPin,
              ),
              const SizedBox(height: 40),
              PrimaryButton(
                text: 'ARCHIVE RECORD',
                onPressed: () {
                  if (nameController.text.isNotEmpty && phoneController.text.isNotEmpty) {
                    final supplier = Supplier(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      name: nameController.text.trim(),
                      phone: phoneController.text.trim(),
                      contactPerson: contactController.text.trim(),
                      address: addressController.text.trim(),
                      userId: 'user_1', // TODO: Get from auth
                      createdAt: DateTime.now(),
                    );
                    context.read<SupplierCubit>().addSupplier(supplier);
                    Navigator.pop(ctx);
                  } else {
                    AppErrorHandler.showError(context, 'REQUIRED FIELDS MISSING');
                  }
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
