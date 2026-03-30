import 'package:flutter/material.dart';
import 'package:shop_keeper_project/core/theme/app_theme.dart';

/// Premium confirmation dialog
class ConfirmDialog {
  static Future<bool> show(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = 'CONFIRM',
    String cancelText = 'CANCEL',
    Color? confirmColor,
    IconData? icon,
  }) async {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: (isDark ? Colors.white : Colors.black).withOpacity(0.05)),
        ),
        title: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: confirmColor ?? AppTheme.primaryIndigo, size: 24),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Text(
                title,
                style: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 1),
              ),
            ),
          ],
        ),
        content: Text(message, style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(cancelText, style: TextStyle(color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5))),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              confirmText,
              style: TextStyle(color: confirmColor ?? AppTheme.primaryIndigo, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  /// Danger confirmation with red styling
  static Future<bool> danger(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = 'DELETE',
  }) {
    return show(
      context,
      title: title,
      message: message,
      confirmText: confirmText,
      confirmColor: AppTheme.dangerRose,
      icon: Icons.warning_rounded,
    );
  }
}
