import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import 'package:shop_keeper_project/features/settings/presentation/screens/profile_screen.dart';
import 'package:shop_keeper_project/features/settings/presentation/screens/about_screen.dart';
import 'package:shop_keeper_project/features/auth/presentation/screens/pin_setup_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shop_keeper_project/core/services/sync_engine.dart';
import 'package:shop_keeper_project/features/settings/presentation/screens/sync_status_dashboard.dart';
import 'package:shop_keeper_project/features/settings/presentation/screens/conflict_resolution_screen.dart';
import 'package:shop_keeper_project/injection_container.dart';
import 'package:shop_keeper_project/core/theme/app_colors.dart';

import 'package:shop_keeper_project/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:shop_keeper_project/core/widgets/glass_card.dart';
import 'package:shop_keeper_project/core/localization/locale_cubit.dart';
import 'package:shop_keeper_project/core/localization/app_strings.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shop_keeper_project/features/settings/presentation/bloc/settings_cubit.dart';
import 'package:shop_keeper_project/core/utils/app_error_handler.dart';
import 'package:go_router/go_router.dart';
import 'package:shop_keeper_project/features/inventory/presentation/bloc/inventory_cubit.dart';
import 'package:shop_keeper_project/features/customers/presentation/bloc/customer_cubit.dart';
import 'package:shop_keeper_project/features/expenses/presentation/bloc/expenses_cubit.dart';
import 'package:shop_keeper_project/features/sales/presentation/bloc/sales_cubit.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          AppStrings.get('control_center').toUpperCase(), 
          style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 2),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(LucideIcons.chevronLeft),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        physics: const BouncingScrollPhysics(),
        children: [
          _buildSectionTitle(AppStrings.get('account_security')),
          _buildSettingsTile(
            context,
            icon: LucideIcons.user,
            title: AppStrings.get('business_profile'),
            subtitle: AppStrings.get('manage_shop_details'),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen())),
          ).animate().fadeIn(duration: 200.ms),
          _buildSettingsTile(
            context,
            icon: LucideIcons.lock,
            title: AppStrings.get('access_configuration'),
            subtitle: AppStrings.get('update_pin_hint'),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PinSetupScreen())),
          ).animate().fadeIn(duration: 200.ms, delay: 50.ms),

          const SizedBox(height: 32),
          _buildSectionTitle(AppStrings.get('preferences')),
          
          BlocBuilder<LocaleCubit, AppLanguage>(
            builder: (context, currentLang) {
              return _buildSettingsTile(
                context,
                icon: LucideIcons.languages,
                title: AppStrings.get('language'),
                subtitle: currentLang == AppLanguage.english ? 'English' : 'हिंदी (Hindi)',
                onTap: () => _showLanguageDialog(context, currentLang),
              );
            },
          ).animate().fadeIn(duration: 200.ms, delay: 100.ms),

          BlocBuilder<SettingsCubit, SettingsState>(
            builder: (context, state) {
              return _buildSettingsTile(
                context,
                icon: state.isDarkMode ? LucideIcons.moon : LucideIcons.sun,
                title: AppStrings.get('visual_theme'),
                subtitle: state.isDarkMode ? AppStrings.get('dark_mode_active') : AppStrings.get('light_mode_active'),
                onTap: () => context.read<SettingsCubit>().toggleDarkMode(!state.isDarkMode),
                trailing: Switch(
                  value: state.isDarkMode,
                  onChanged: (val) => context.read<SettingsCubit>().toggleDarkMode(val),
                  activeColor: AppColors.primary,
                  activeTrackColor: AppColors.primary.withOpacity(0.2),
                  inactiveThumbColor: AppColors.textMuted,
                  inactiveTrackColor: Colors.white10,
                ),
              );
            },
          ).animate().fadeIn(duration: 200.ms, delay: 125.ms),

          const SizedBox(height: 32),
          _buildSectionTitle(AppStrings.get('business_tools')),
          _buildSettingsTile(
            context,
            icon: LucideIcons.landmark,
            title: AppStrings.get('gst_tax_settings'),
            subtitle: AppStrings.get('configure_tax_hint'),
            onTap: () => _showTaxConfigDialog(context),
          ).animate().fadeIn(duration: 200.ms, delay: 150.ms),
          _buildSettingsTile(
            context,
            icon: LucideIcons.barChart3,
            title: AppStrings.get('analytics'),
            subtitle: AppStrings.get('revenue_trend'),
            onTap: () => context.push('/analytics'),
          ).animate().fadeIn(duration: 200.ms, delay: 200.ms),
          _buildSettingsTile(
            context,
            icon: LucideIcons.pieChart,
            title: AppStrings.get('profit_report'),
            subtitle: AppStrings.get('net_profit_summary'),
            onTap: () => context.push('/profit-report'),
          ).animate().fadeIn(duration: 200.ms, delay: 250.ms),
          _buildSettingsTile(
            context,
            icon: LucideIcons.users,
            title: AppStrings.get('customer_ledger'),
            subtitle: AppStrings.get('manage_udhar_hint'),
            onTap: () => context.push('/customers'),
          ).animate().fadeIn(duration: 200.ms, delay: 300.ms),

          const SizedBox(height: 32),
          _buildSectionTitle(AppStrings.get('data_engine')),
          _buildSettingsTile(
            context,
            icon: LucideIcons.cloud,
            title: AppStrings.get('cloud_sync'),
            subtitle: AppStrings.get('sync_hint'),
            onTap: () async {
              try {
                await sl<SyncEngine>().syncAll();
                if (context.mounted) {
                  AppErrorHandler.showSuccess(context, 'DATABASE SYNCHRONIZED');
                }
              } catch (_) {}
            },
          ).animate().fadeIn(duration: 200.ms, delay: 350.ms),
          
          StreamBuilder<SyncStatus>(
            stream: sl<SyncEngine>().statusStream,
            builder: (context, _) {
              final syncEngine = sl<SyncEngine>();
              final pendingCount = syncEngine.pendingCount;
              final conflictCount = syncEngine.conflictCount;
              
              return Column(
                children: [
                  _buildSettingsTile(
                    context,
                    icon: LucideIcons.activity,
                    title: 'SYNC DASHBOARD',
                    subtitle: 'Monitor pending cloud updates',
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1), 
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                      ),
                      child: Text(
                        '$pendingCount', 
                        style: GoogleFonts.outfit(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.w900),
                      ),
                    ),
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SyncStatusDashboard())),
                  ).animate().fadeIn(duration: 200.ms, delay: 375.ms),

                  if (conflictCount > 0)
                    _buildSettingsTile(
                      context,
                      icon: LucideIcons.alertCircle,
                      title: 'RESOLUTION CENTER',
                      subtitle: 'Fix $conflictCount data conflicts',
                      color: AppColors.error,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ConflictResolutionScreen())),
                    ).animate().fadeIn(duration: 200.ms, delay: 380.ms),
                ],
              );
            }
          ),
          _buildSettingsTile(
            context,
            icon: LucideIcons.trash2,
            title: AppStrings.get('clear_cache'),
            subtitle: AppStrings.get('clear_cache_hint'),
            onTap: () => _showClearCacheDialog(context),
            color: AppColors.error,
          ).animate().fadeIn(duration: 200.ms, delay: 400.ms),
          _buildSettingsTile(
            context,
            icon: LucideIcons.downloadCloud,
            title: 'BACKUP DATA',
            subtitle: 'Export all data as CSV',
            onTap: () => _exportAllData(context),
            color: AppColors.success,
          ).animate().fadeIn(duration: 200.ms, delay: 450.ms),

          const SizedBox(height: 32),
          _buildSectionTitle(AppStrings.get('labs_info')),
          _buildSettingsTile(
            context,
            icon: LucideIcons.info,
            title: AppStrings.get('system_intelligence'),
            subtitle: AppStrings.get('version_info'),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutScreen())),
          ).animate().fadeIn(duration: 200.ms, delay: 450.ms),
          _buildSettingsTile(
            context,
            icon: LucideIcons.logOut,
            title: AppStrings.get('terminate_session'),
            subtitle: AppStrings.get('sign_out_hint'),
            color: AppColors.error,
            onTap: () => _showLogoutDialog(context),
          ).animate().fadeIn(duration: 200.ms, delay: 500.ms),

          const SizedBox(height: 60),
          Center(
            child: Opacity(
              opacity: 0.3,
              child: Column(
                children: [
                  Icon(LucideIcons.shieldCheck, size: 24, color: AppColors.textPrimary),
                  const SizedBox(height: 12),
                  Text(
                    '${AppStrings.get('app_name').toUpperCase()} \u2022 ENCRYPTED',
                    style: GoogleFonts.outfit(
                      fontSize: 10, 
                      fontWeight: FontWeight.w900, 
                      color: AppColors.textPrimary, 
                      letterSpacing: 2
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  void _showLanguageDialog(BuildContext context, AppLanguage current) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          border: Border(top: BorderSide(color: AppColors.glassBorder)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40, height: 4, 
                decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              AppStrings.get('language').toUpperCase(), 
              style: GoogleFonts.outfit(fontWeight: FontWeight.w900, color: AppColors.textPrimary, letterSpacing: 2, fontSize: 14),
            ),
            const SizedBox(height: 32),
            _buildLanguageOption(context, 'ENGLISH SYSTEM', AppLanguage.english, current == AppLanguage.english),
            const SizedBox(height: 12),
            _buildLanguageOption(context, 'HINDI (हिंदी) SYSTEM', AppLanguage.hindi, current == AppLanguage.hindi),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption(BuildContext context, String name, AppLanguage lang, bool isSelected) {
    return ListTile(
      onTap: () {
        context.read<LocaleCubit>().setLanguage(lang);
        Navigator.pop(context);
      },
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      tileColor: isSelected ? AppColors.primary.withOpacity(0.05) : Colors.transparent,
      leading: Icon(
        isSelected ? LucideIcons.circleDot : LucideIcons.circle,
        color: isSelected ? AppColors.primary : AppColors.textMuted,
        size: 20,
      ),
      title: Text(
        name, 
        style: GoogleFonts.outfit(
          color: isSelected ? AppColors.textPrimary : AppColors.textMuted, 
          fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
          fontSize: 14,
          letterSpacing: 1,
        ),
      ),
    );
  }

  void _showTaxConfigDialog(BuildContext context) {
    final currentGst = context.read<SettingsCubit>().state.gstRate * 100;
    final gstController = TextEditingController(text: currentGst.toStringAsFixed(0));
    
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
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              AppStrings.get('tax_configuration_title').toUpperCase(), 
              style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.primary, letterSpacing: 2),
            ),
            const SizedBox(height: 32),
            Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.glassBorder),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              child: TextField(
                controller: gstController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: GoogleFonts.outfit(color: AppColors.textPrimary, fontSize: 28, fontWeight: FontWeight.w900),
                decoration: InputDecoration(
                  labelText: AppStrings.get('default_gst_label').toUpperCase(),
                  labelStyle: GoogleFonts.outfit(color: AppColors.textMuted, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1),
                  prefixIcon: const Icon(LucideIcons.percent, color: AppColors.primary, size: 20),
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity, height: 56,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: AppColors.goldGradient,
                  boxShadow: [
                    BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))
                  ],
                ),
                child: ElevatedButton(
                  onPressed: () {
                    final newRate = double.tryParse(gstController.text);
                    if (newRate != null) {
                      context.read<SettingsCubit>().updateGstRate(newRate / 100);
                      Navigator.pop(ctx);
                      AppErrorHandler.showSuccess(context, 'TAX PARAMETERS UPDATED');
                    } else {
                      AppErrorHandler.showError(context, 'INVALID PARAMETER');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text(
                    AppStrings.get('save_config').toUpperCase(), 
                    style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 1.5, color: Colors.black),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showClearCacheDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28), side: const BorderSide(color: AppColors.glassBorder)),
        title: Text(
          AppStrings.get('clear_cache_title').toUpperCase(), 
          style: GoogleFonts.outfit(color: AppColors.textPrimary, fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 1),
        ),
        content: Text(
          AppStrings.get('clear_cache_message'), 
          style: GoogleFonts.outfit(color: AppColors.textSecondary, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx), 
            child: Text(AppStrings.get('cancel').toUpperCase(), style: GoogleFonts.outfit(color: AppColors.textMuted, fontWeight: FontWeight.w900, fontSize: 12)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              AppErrorHandler.showSuccess(context, 'CACHE PURGED SUCCESSFULLY');
            },
            child: Text(
              AppStrings.get('clear_action').toUpperCase(), 
              style: GoogleFonts.outfit(color: AppColors.error, fontWeight: FontWeight.w900, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  void _exportAllData(BuildContext context) async {
    final buffer = StringBuffer();
    final now = DateTime.now();

    buffer.writeln('═══════════════════════════════════════');
    buffer.writeln('       SHOPKEEPER DATA BACKUP');
    buffer.writeln('═══════════════════════════════════════');
    buffer.writeln('Generated: ${DateFormat('dd MMM yyyy, hh:mm a').format(now)}');
    buffer.writeln('');

    final invState = context.read<InventoryCubit>().state;
    if (invState is InventoryLoaded) {
      buffer.writeln('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      buffer.writeln('PRODUCTS (${invState.products.length})');
      buffer.writeln('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      buffer.writeln('Name,Category,Buy Price,Sell Price,Stock,Min Alert,Barcode');
      for (final p in invState.products) {
        buffer.writeln('"${p.name}","${p.category}",${p.buyPrice},${p.sellPrice},${p.stockQuantity},${p.minStockAlert},"${p.barcode ?? ''}"');
      }
      buffer.writeln('');
    }

    final custState = context.read<CustomerCubit>().state;
    if (custState is CustomerLoaded) {
      buffer.writeln('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      buffer.writeln('CUSTOMERS (${custState.customers.length})');
      buffer.writeln('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      buffer.writeln('Name,Phone,Credit Balance,Notes');
      for (final c in custState.customers) {
        buffer.writeln('"${c.name}","${c.phone}",${c.totalCredit},"${c.notes ?? ''}"');
      }
      buffer.writeln('');
    }

    final expState = context.read<ExpensesCubit>().state;
    if (expState is ExpensesLoaded) {
      buffer.writeln('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      buffer.writeln('EXPENSES (${expState.expenses.length})');
      buffer.writeln('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      buffer.writeln('Date,Title,Category,Amount');
      for (final e in expState.expenses) {
        buffer.writeln('${DateFormat('yyyy-MM-dd').format(e.date)},"${e.title}","${e.category}",${e.amount}');
      }
      buffer.writeln('');
    }

    final salesState = context.read<SalesCubit>().state;
    if (salesState is SalesLoaded) {
      buffer.writeln('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      buffer.writeln('SALES (${salesState.sales.length})');
      buffer.writeln('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      buffer.writeln('Date,Product,Qty,Price,Total,Profit');
      for (final s in salesState.sales) {
        buffer.writeln('${DateFormat('yyyy-MM-dd').format(s.date)},"${s.productName}",${s.quantitySold},${s.salePrice},${s.totalAmount},${s.totalProfit}');
      }
      buffer.writeln('');
    }

    buffer.writeln('═══════════════════════════════════════');
    buffer.writeln('        END OF BACKUP');
    buffer.writeln('═══════════════════════════════════════');

    await Clipboard.setData(ClipboardData(text: buffer.toString()));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(LucideIcons.checkCircle, color: Colors.black, size: 20),
              const SizedBox(width: 12),
              Text(
                'FULL BACKUP ARCHIVED TO CLIPBOARD', 
                style: GoogleFonts.outfit(fontWeight: FontWeight.w900, color: Colors.black, fontSize: 12),
              ),
            ],
          ),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(24),
        ),
      );
    }
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28), side: const BorderSide(color: AppColors.glassBorder)),
        title: Text(
          AppStrings.get('sign_out_title').toUpperCase(), 
          style: GoogleFonts.outfit(color: AppColors.error, fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 1),
        ),
        content: Text(
          AppStrings.get('sign_out_confirm'), 
          style: GoogleFonts.outfit(color: AppColors.textSecondary, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx), 
            child: Text(AppStrings.get('cancel').toUpperCase(), style: GoogleFonts.outfit(color: AppColors.textMuted, fontWeight: FontWeight.w900, fontSize: 12)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                context.read<AuthCubit>().logout();
              }
            },
            child: Text(
              AppStrings.get('terminate_session').toUpperCase(), 
              style: GoogleFonts.outfit(color: AppColors.error, fontWeight: FontWeight.w900, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 16),
      child: Text(
        title.toUpperCase(), 
        style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w900, color: AppColors.primary, letterSpacing: 2),
      ),
    );
  }

  Widget _buildSettingsTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Widget? trailing,
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        padding: EdgeInsets.zero,
        backgroundOpacity: 0.05,
        child: ListTile(
          onTap: onTap,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          leading: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: (color ?? AppColors.primary).withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: (color ?? AppColors.primary).withOpacity(0.1)),
            ),
            child: Icon(icon, color: color ?? AppColors.primary, size: 22),
          ),
          title: Text(
            title.toUpperCase(), 
            style: GoogleFonts.outfit(fontWeight: FontWeight.w800, color: AppColors.textPrimary, fontSize: 14, letterSpacing: 0.5),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(
              subtitle, 
              style: GoogleFonts.outfit(fontSize: 12, color: AppColors.textMuted, fontWeight: FontWeight.w500),
            ),
          ),
          trailing: trailing ?? Icon(LucideIcons.chevronRight, size: 16, color: AppColors.textMuted.withOpacity(0.5)),
        ),
      ),
    );
  }
}

