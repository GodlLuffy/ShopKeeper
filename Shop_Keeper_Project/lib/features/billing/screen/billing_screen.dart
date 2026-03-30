import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shop_keeper_project/core/widgets/glass_card.dart';
import 'package:shop_keeper_project/core/theme/app_theme.dart';
import '../bloc/billing_bloc.dart';
import '../bloc/billing_event.dart';
import '../bloc/billing_state.dart';
import '../widgets/cart_list_view.dart';
import '../widgets/product_selection_sheet.dart';
import '../widgets/total_summary_box.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:shop_keeper_project/features/inventory/domain/entities/product_entity.dart';
import 'package:shop_keeper_project/features/inventory/presentation/bloc/inventory_cubit.dart';
import 'package:shop_keeper_project/features/settings/presentation/bloc/settings_cubit.dart';
import '../widgets/invoice_dialog.dart';
import '../model/cart_item.dart';
import '../model/billing_summary.dart';
import 'package:shop_keeper_project/core/localization/app_strings.dart';
import 'package:shop_keeper_project/core/utils/app_error_handler.dart';

class BillingScreen extends StatefulWidget {
  const BillingScreen({super.key});

  @override
  State<BillingScreen> createState() => _BillingScreenState();
}

class _BillingScreenState extends State<BillingScreen> {
  @override
  void initState() {
    super.initState();
    // Sync initial tax configuration from settings
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final gstRate = context.read<SettingsCubit>().state.gstRate;
      context.read<BillingBloc>().add(UpdateTaxConfig(TaxConfig(gstRate: gstRate)));
    });
  }

  void _showAddProductSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const ProductSelectionSheet(),
    );
  }

  void _showBarcodeScanner(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final inventoryState = context.read<InventoryCubit>().state;
    if (inventoryState is! InventoryLoaded) {
      context.read<InventoryCubit>().loadProducts();
    }
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        bool isProcessing = false;
        return Container(
          height: MediaQuery.of(ctx).size.height * 0.75,
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            border: Border.all(color: (isDark ? Colors.white : Colors.black).withOpacity(0.05), width: 1),
          ),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(color: (isDark ? Colors.white24 : Colors.black12), borderRadius: BorderRadius.circular(2)),
              ),
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text(
                  AppStrings.get('barcode_acquisition').toUpperCase(),
                  style: TextStyle(fontWeight: FontWeight.w900, color: theme.colorScheme.onSurface, letterSpacing: 2),
                ),
              ),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppTheme.primaryIndigo.withOpacity(0.3), width: 2),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(22),
                    child: MobileScanner(
                      onDetect: (capture) {
                        if (isProcessing) return;
                        final List<Barcode> barcodes = capture.barcodes;
                        for (final barcode in barcodes) {
                          final code = barcode.rawValue?.trim();
                          if (code != null && code.isNotEmpty) {
                            isProcessing = true;
                            final state = context.read<InventoryCubit>().state;
                            if (state is InventoryLoaded) {
                              // Robust Matching Loop
                              ProductEntity? found;
                              for (final p in state.products) {
                                if (p.barcode == code || 
                                   (p.barcode != null && p.barcode!.replaceFirst(RegExp(r'^0+'), '') == code.replaceFirst(RegExp(r'^0+'), ''))) {
                                  found = p;
                                  break;
                                }
                              }

                              if (found != null) {
                                context.read<BillingBloc>().add(AddToCart(found));
                                Navigator.pop(ctx);
                                AppErrorHandler.showSuccess(context, '${AppStrings.get('item_added')}: ${found.name}');
                              } else {
                                isProcessing = false;
                                AppErrorHandler.showError(ctx, AppStrings.get('no_results'));
                                HapticFeedback.heavyImpact();
                              }
                            }
                          }
                        }
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          AppStrings.get('retail_terminal').toUpperCase(), 
          style: TextStyle(
            fontWeight: FontWeight.w900, 
            fontSize: 16, 
            letterSpacing: 2, 
            color: theme.colorScheme.onSurface
          )
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: theme.colorScheme.onSurface),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep_rounded, color: AppTheme.dangerRose),
            onPressed: () {
              context.read<BillingBloc>().add(ClearCart());
              HapticFeedback.mediumImpact();
            },
            tooltip: AppStrings.get('clear_cache'),
          ),
        ],
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<SettingsCubit, SettingsState>(
            listener: (context, state) {
              context.read<BillingBloc>().add(UpdateTaxConfig(TaxConfig(gstRate: state.gstRate)));
            },
          ),
          BlocListener<BillingBloc, BillingState>(
            listener: (context, state) {
              if (state is BillGenerated) {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (ctx) => InvoiceDialog(invoice: state.invoice),
                ).then((_) {
                  if (context.mounted) {
                    context.read<BillingBloc>().add(ClearCart());
                  }
                });
              } else if (state is BillingError) {
                AppErrorHandler.showError(context, state.message);
              }
            },
          ),
        ],
        child: BlocBuilder<BillingBloc, BillingState>(
          builder: (context, state) {
            if (state is BillingLoading) {
              return const Center(child: CircularProgressIndicator(color: AppTheme.primaryIndigo));
            }

            List<CartItem> cartItems = [];
            double totalAmount = 0.0;
            BillingSummary? summary;

            if (state is BillingUpdated) {
              cartItems = state.items;
              totalAmount = state.totalAmount;
              summary = state.summary;
            } 

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 4,
                        child: GestureDetector(
                          onTap: () => _showAddProductSheet(context),
                          child: GlassCard(
                            margin: EdgeInsets.zero,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                            borderRadius: 16,
                            child: Row(
                              children: [
                                const Icon(Icons.search_rounded, color: AppTheme.accentTeal),
                                const SizedBox(width: 12),
                                Text(
                                  AppStrings.get('search_products'),
                                  style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.5), fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      if (!kIsWeb && (Platform.isAndroid || Platform.isIOS))
                        GestureDetector(
                          onTap: () => _showBarcodeScanner(context),
                          child: Container(
                            height: 56,
                            width: 56,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(colors: [AppTheme.primaryIndigo, AppTheme.accentTeal]),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(color: AppTheme.primaryIndigo.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4)),
                              ],
                            ),
                            child: const Icon(Icons.qr_code_scanner_rounded, color: Colors.white),
                          ),
                        ),
                    ],
                  ),
                ),
                Expanded(
                  child: cartItems.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Opacity(
                                opacity: 0.1,
                                child: Icon(Icons.shopping_cart_outlined, size: 80, color: theme.colorScheme.onSurface),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                AppStrings.get('cart_is_empty').toUpperCase(),
                                style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.2), fontWeight: FontWeight.w900, letterSpacing: 2),
                              ),
                            ],
                          ),
                        )
                      : CartListView(items: cartItems),
                ),
                if (summary != null) TotalSummaryBox(summary: summary, totalAmount: totalAmount),
              ],
            );
          },
        ),
      ),
    );
  }
}
