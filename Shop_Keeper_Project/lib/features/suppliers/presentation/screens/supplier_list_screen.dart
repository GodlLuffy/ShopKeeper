import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shop_keeper_project/core/theme/app_theme.dart';
import 'package:shop_keeper_project/core/widgets/glass_card.dart';
import 'package:shop_keeper_project/core/widgets/primary_button.dart';
import 'package:shop_keeper_project/features/suppliers/domain/entities/supplier.dart';
import 'package:shop_keeper_project/features/suppliers/presentation/bloc/supplier_cubit.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';

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
      backgroundColor: AppTheme.darkBackgroundMain,
      appBar: AppBar(
        title: Text('SUPPLIER LEDGER', style: GoogleFonts.orbitron(fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 2, color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: BlocBuilder<SupplierCubit, SupplierState>(
        builder: (context, state) {
          if (state is SupplierLoading) {
            return const Center(child: CircularProgressIndicator(color: AppTheme.primaryOrchid));
          } else if (state is SupplierLoaded) {
            final totalDebt = state.suppliers.fold(0.0, (sum, s) => sum + s.balance);
            
            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: _buildStatsHeader(totalDebt),
                  ),
                ),
                if (state.suppliers.isEmpty)
                  SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(LucideIcons.truck, size: 64, color: AppTheme.textMuted.withOpacity(0.3)),
                          const SizedBox(height: 16),
                          Text('No suppliers documented yet', style: GoogleFonts.inter(color: AppTheme.textMuted)),
                        ],
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => _buildSupplierCard(state.suppliers[index]),
                        childCount: state.suppliers.length,
                      ),
                    ),
                  ),
              ],
            );
          }
          return const SizedBox();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddSupplierDialog(context),
        backgroundColor: AppTheme.primaryOrchid,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildStatsHeader(double totalDebt) {
    return GlassCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('TOTAL OUTSTANDING', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w900, color: AppTheme.secondaryCyan, letterSpacing: 1.2)),
                  const SizedBox(height: 8),
                  Text('₹${totalDebt.toStringAsFixed(2)}', style: GoogleFonts.orbitron(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: AppTheme.dangerRose.withOpacity(0.1), borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.dangerRose.withOpacity(0.3))),
                child: const Icon(LucideIcons.arrowUpRight, color: AppTheme.dangerRose),
              ),
            ],
          ),
          const SizedBox(height: 20),
          LinearProgressIndicator(
            value: 0.7, // Placeholder for credit utilization
            backgroundColor: Colors.white.withOpacity(0.05),
            color: AppTheme.primaryOrchid,
            minHeight: 4,
            borderRadius: BorderRadius.circular(2),
          ),
        ],
      ),
    );
  }

  Widget _buildSupplierCard(Supplier supplier) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              height: 54,
              width: 54,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [AppTheme.primaryOrchid, AppTheme.secondaryCyan]),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: AppTheme.primaryOrchid.withOpacity(0.3), blurRadius: 8)],
              ),
              child: Center(child: Text(supplier.name[0].toUpperCase(), style: GoogleFonts.orbitron(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white))),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(supplier.name.toUpperCase(), style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 0.5)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.phone_outlined, size: 12, color: AppTheme.textMuted),
                      const SizedBox(width: 4),
                      Text(supplier.phone, style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textMuted)),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('₹${supplier.balance.toStringAsFixed(0)}', style: GoogleFonts.orbitron(fontSize: 16, fontWeight: FontWeight.bold, color: supplier.balance > 0 ? AppTheme.dangerRose : AppTheme.successEmerald)),
                const SizedBox(height: 4),
                Text('BALANCE', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w900, color: AppTheme.textMuted, letterSpacing: 1)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAddSupplierDialog(BuildContext context) {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final contactController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.darkBackgroundMain,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24), side: const BorderSide(color: Colors.white10)),
        title: Text('REGISTER SUPPLIER', style: GoogleFonts.orbitron(fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 1.5, color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTextField(nameController, 'Business Name', LucideIcons.building2),
            const SizedBox(height: 16),
            _buildTextField(phoneController, 'Phone / Mobile', LucideIcons.phone, keyboardType: TextInputType.phone),
            const SizedBox(height: 16),
            _buildTextField(contactController, 'Contact Person', LucideIcons.user),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('CANCEL', style: TextStyle(color: AppTheme.textMuted))),
          PrimaryButton(
            text: 'CREATE',
            onPressed: () {
              if (nameController.text.isNotEmpty && phoneController.text.isNotEmpty) {
                final supplier = Supplier(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  name: nameController.text,
                  phone: phoneController.text,
                  contactPerson: contactController.text,
                  userId: 'user_1', // TODO: Get from auth
                  createdAt: DateTime.now(),
                );
                context.read<SupplierCubit>().addSupplier(supplier);
                Navigator.pop(ctx);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {TextInputType? keyboardType}) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: AppTheme.textMuted, fontSize: 12),
        prefixIcon: Icon(icon, size: 18, color: AppTheme.secondaryCyan),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.white10)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.primaryOrchid)),
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
      ),
    );
  }
}
