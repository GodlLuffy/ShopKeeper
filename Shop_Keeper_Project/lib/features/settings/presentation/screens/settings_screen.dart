import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shop_keeper_project/features/settings/presentation/screens/profile_screen.dart';
import 'package:shop_keeper_project/features/settings/presentation/screens/about_screen.dart';
import 'package:shop_keeper_project/features/auth/presentation/screens/pin_setup_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shop_keeper_project/services/sync_service.dart';
import 'package:shop_keeper_project/injection_container.dart';
import 'package:shop_keeper_project/core/theme/app_theme.dart';
import 'package:shop_keeper_project/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:shop_keeper_project/core/widgets/glass_card.dart';
import 'package:shop_keeper_project/core/localization/locale_cubit.dart';
import 'package:shop_keeper_project/core/localization/app_strings.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shop_keeper_project/features/settings/presentation/bloc/settings_cubit.dart';
import 'package:shop_keeper_project/core/utils/app_error_handler.dart';
import 'package:go_router/go_router.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          AppStrings.get('control_center'), 
          style: TextStyle(
            fontWeight: FontWeight.w900, 
            fontSize: 16, 
            letterSpacing: 2,
            color: theme.colorScheme.onSurface,
          )
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: theme.colorScheme.onSurface),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topRight,
            radius: 1.5,
            colors: [
              AppTheme.primaryIndigo.withOpacity(isDark ? 0.05 : 0.03), 
              Colors.transparent
            ],
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          children: [
            _buildSectionTitle(context, AppStrings.get('account_security')),
            _buildSettingsTile(
              context,
              icon: Icons.person_rounded,
              title: AppStrings.get('business_profile'),
              subtitle: AppStrings.get('manage_shop_details'),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen())),
            ).animate().fadeIn(duration: 200.ms),
            _buildSettingsTile(
              context,
              icon: Icons.lock_person_rounded,
              title: AppStrings.get('access_configuration'),
              subtitle: AppStrings.get('update_pin_hint'),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PinSetupScreen())),
            ).animate().fadeIn(duration: 200.ms, delay: 50.ms),

            const SizedBox(height: 32),
            _buildSectionTitle(context, AppStrings.get('preferences')),
            
            BlocBuilder<LocaleCubit, AppLanguage>(
              builder: (context, currentLang) {
                return _buildSettingsTile(
                  context,
                  icon: Icons.language_rounded,
                  title: AppStrings.get('language'),
                  subtitle: currentLang == AppLanguage.english ? 'English' : 'हिंदी (Hindi)',
                  onTap: () => _showLanguageDialog(context, currentLang),
                  color: AppTheme.accentTeal,
                );
              },
            ).animate().fadeIn(duration: 200.ms, delay: 100.ms),

            BlocBuilder<SettingsCubit, SettingsState>(
              builder: (context, state) {
                return _buildSettingsTile(
                  context,
                  icon: state.isDarkMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                  title: AppStrings.get('visual_theme'),
                  subtitle: state.isDarkMode ? AppStrings.get('dark_mode_active') : AppStrings.get('light_mode_active'),
                  color: AppTheme.primaryIndigo,
                  onTap: () => context.read<SettingsCubit>().toggleDarkMode(!state.isDarkMode),
                  trailing: Switch(
                    value: state.isDarkMode,
                    onChanged: (val) => context.read<SettingsCubit>().toggleDarkMode(val),
                    activeColor: AppTheme.accentTeal,
                    activeTrackColor: AppTheme.accentTeal.withOpacity(0.3),
                    inactiveThumbColor: isDark ? Colors.white60 : Colors.grey,
                    inactiveTrackColor: isDark ? Colors.white10 : Colors.grey.withOpacity(0.2),
                  ),
                );
              },
            ).animate().fadeIn(duration: 200.ms, delay: 125.ms),

            const SizedBox(height: 32),
            _buildSectionTitle(context, AppStrings.get('business_tools')),
            _buildSettingsTile(
              context,
              icon: Icons.receipt_long_rounded,
              title: AppStrings.get('gst_tax_settings'),
              subtitle: AppStrings.get('configure_tax_hint'),
              onTap: () => _showTaxConfigDialog(context),
            ).animate().fadeIn(duration: 200.ms, delay: 150.ms),
            _buildSettingsTile(
              context,
              icon: Icons.analytics_rounded,
              title: AppStrings.get('analytics'),
              subtitle: AppStrings.get('revenue_trend'),
              onTap: () => context.push('/analytics'),
            ).animate().fadeIn(duration: 200.ms, delay: 200.ms),
            _buildSettingsTile(
              context,
              icon: Icons.pie_chart_rounded,
              title: AppStrings.get('profit_report'),
              subtitle: AppStrings.get('net_profit_summary'),
              onTap: () => context.push('/profit-report'),
            ).animate().fadeIn(duration: 200.ms, delay: 250.ms),
            _buildSettingsTile(
              context,
              icon: Icons.people_rounded,
              title: AppStrings.get('customer_ledger'),
              subtitle: AppStrings.get('manage_udhar_hint'),
              onTap: () => context.push('/customers'),
            ).animate().fadeIn(duration: 200.ms, delay: 300.ms),

            const SizedBox(height: 32),
            _buildSectionTitle(context, AppStrings.get('data_engine')),
            _buildSettingsTile(
              context,
              icon: Icons.cloud_done_rounded,
              title: AppStrings.get('cloud_sync'),
              subtitle: AppStrings.get('sync_hint'),
              onTap: () async {
                try {
                  await sl<SyncService>().syncAll();
                  if (context.mounted) {
                    AppErrorHandler.showSuccess(context, AppStrings.get('success'));
                  }
                } catch (_) {}
              },
            ).animate().fadeIn(duration: 200.ms, delay: 350.ms),
            _buildSettingsTile(
              context,
              icon: Icons.cleaning_services_rounded,
              title: AppStrings.get('clear_cache'),
              subtitle: AppStrings.get('clear_cache_hint'),
              onTap: () => _showClearCacheDialog(context),
              color: AppTheme.warningAmber,
            ).animate().fadeIn(duration: 200.ms, delay: 400.ms),

            const SizedBox(height: 32),
            _buildSectionTitle(context, AppStrings.get('labs_info')),
            _buildSettingsTile(
              context,
              icon: Icons.terminal_rounded,
              title: AppStrings.get('system_intelligence'),
              subtitle: AppStrings.get('version_info'),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutScreen())),
            ).animate().fadeIn(duration: 200.ms, delay: 450.ms),
            _buildSettingsTile(
              context,
              icon: Icons.power_settings_new_rounded,
              title: AppStrings.get('terminate_session'),
              subtitle: AppStrings.get('sign_out_hint'),
              color: AppTheme.dangerRose,
              onTap: () => _showLogoutDialog(context),
            ).animate().fadeIn(duration: 200.ms, delay: 500.ms),

            const SizedBox(height: 40),
            Center(
              child: Opacity(
                opacity: 0.3,
                child: Column(
                  children: [
                    Icon(Icons.verified_user_rounded, size: 24, color: theme.colorScheme.onSurface),
                    const SizedBox(height: 8),
                    Text(
                      '${AppStrings.get('app_name').toUpperCase()} \u2022 ENCRYPTED',
                      style: TextStyle(
                        fontSize: 10, 
                        fontWeight: FontWeight.w900, 
                        color: theme.colorScheme.onSurface, 
                        letterSpacing: 1
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguageDialog(BuildContext context, AppLanguage current) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, -5))
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: (isDark ? Colors.white24 : Colors.black12), borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 24),
            Text(AppStrings.get('language').toUpperCase(), style: TextStyle(fontWeight: FontWeight.w900, color: theme.colorScheme.onSurface, letterSpacing: 2)),
            const SizedBox(height: 24),
            _buildLanguageOption(context, 'English', AppLanguage.english, current == AppLanguage.english),
            _buildLanguageOption(context, 'हिंदी (Hindi)', AppLanguage.hindi, current == AppLanguage.hindi),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption(BuildContext context, String name, AppLanguage lang, bool isSelected) {
    final theme = Theme.of(context);
    return ListTile(
      onTap: () {
        context.read<LocaleCubit>().setLanguage(lang);
        Navigator.pop(context);
      },
      leading: Icon(
        isSelected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
        color: isSelected ? AppTheme.accentTeal : theme.colorScheme.onSurfaceVariant,
      ),
      title: Text(name, style: TextStyle(color: isSelected ? theme.colorScheme.onSurface : theme.colorScheme.onSurfaceVariant, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
      trailing: isSelected ? const Icon(Icons.check_circle_rounded, color: AppTheme.accentTeal, size: 20) : null,
    );
  }

  void _showTaxConfigDialog(BuildContext context) {
    final theme = Theme.of(context);
    final currentGst = context.read<SettingsCubit>().state.gstRate * 100;
    final gstController = TextEditingController(text: currentGst.toStringAsFixed(0));
    
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
          border: Border.all(color: (theme.brightness == Brightness.dark ? Colors.white : Colors.black).withOpacity(0.08)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(color: (theme.brightness == Brightness.dark ? Colors.white24 : Colors.black12), borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 20),
            Text(AppStrings.get('tax_configuration_title'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppTheme.accentTeal, letterSpacing: 2)),
            const SizedBox(height: 20),
            TextField(
              controller: gstController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 22, fontWeight: FontWeight.w800),
              decoration: InputDecoration(
                labelText: AppStrings.get('default_gst_label'),
                prefixIcon: const Icon(Icons.percent_rounded, color: AppTheme.accentTeal),
                hintText: '18',
                hintStyle: TextStyle(color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5)),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity, height: 56,
              child: ElevatedButton(
                onPressed: () {
                  final newRate = double.tryParse(gstController.text);
                  if (newRate != null) {
                    context.read<SettingsCubit>().updateGstRate(newRate / 100);
                    Navigator.pop(ctx);
                    AppErrorHandler.showSuccess(context, 'GST rate set to ${gstController.text}%');
                  } else {
                    AppErrorHandler.showError(context, 'Invalid GST rate');
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryIndigo,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text(AppStrings.get('save_config'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: 1, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showClearCacheDialog(BuildContext context) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24), side: BorderSide(color: (theme.brightness == Brightness.dark ? Colors.white10 : Colors.black12))),
        title: Text(AppStrings.get('clear_cache_title'), style: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.w900, letterSpacing: 1)),
        content: Text(AppStrings.get('clear_cache_message'), style: TextStyle(color: theme.colorScheme.onSurfaceVariant)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(AppStrings.get('cancel'), style: TextStyle(color: theme.colorScheme.onSurfaceVariant))),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              AppErrorHandler.showSuccess(context, AppStrings.get('success'));
            },
            child: Text(AppStrings.get('clear_action'), style: const TextStyle(color: AppTheme.warningAmber, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24), side: BorderSide(color: (theme.brightness == Brightness.dark ? Colors.white10 : Colors.black12))),
        title: Text(AppStrings.get('sign_out_title'), style: const TextStyle(color: AppTheme.dangerRose, fontWeight: FontWeight.w900, letterSpacing: 1)),
        content: Text(AppStrings.get('sign_out_confirm'), style: TextStyle(color: theme.colorScheme.onSurfaceVariant)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(AppStrings.get('cancel'), style: TextStyle(color: theme.colorScheme.onSurfaceVariant))),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                context.read<AuthCubit>().logout();
              }
            },
            child: Text(AppStrings.get('terminate_session').toUpperCase(), style: const TextStyle(color: AppTheme.dangerRose, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: AppTheme.accentTeal, letterSpacing: 1.5)),
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
    final theme = Theme.of(context);
    return GlassCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: (color ?? AppTheme.primaryIndigo).withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: color ?? AppTheme.primaryIndigo, size: 22),
        ),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.w700, color: color ?? theme.colorScheme.onSurface, fontSize: 15)),
        subtitle: Text(subtitle, style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant)),
        trailing: trailing ?? Icon(Icons.chevron_right_rounded, size: 20, color: theme.colorScheme.onSurfaceVariant.withOpacity(0.3)),
        onTap: onTap,
      ),
    );
  }
}
