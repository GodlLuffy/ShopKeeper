import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shop_keeper_project/core/widgets/glass_card.dart';
import 'package:shop_keeper_project/core/theme/app_colors.dart';
import 'package:shop_keeper_project/core/theme/app_theme.dart';
import 'package:shop_keeper_project/core/widgets/premium_loader.dart';
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
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

class BillingScreen extends StatefulWidget {
  const BillingScreen({super.key});

  @override
  State<BillingScreen> createState() => _BillingScreenState();
}

class _BillingScreenState extends State<BillingScreen> {
  @override
  void initState() {
    super.initState();
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
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
            border: Border(top: BorderSide(color: AppColors.glassBorder)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.textMuted, borderRadius: BorderRadius.circular(4))),
              Padding(
                padding: const EdgeInsets.all(32.0),
                child: Row(
                  children: [
                    const Icon(LucideIcons.scan, color: AppColors.primary, size: 24),
                    const SizedBox(width: 16),
                    Text(
                      AppStrings.get('barcode_acquisition').toUpperCase(),
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.w900, 
                        color: AppColors.textPrimary, 
                        letterSpacing: 2,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 32),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 1.5),
                    boxShadow: [
                      BoxShadow(color: AppColors.primary.withOpacity(0.1), blurRadius: 30, spreadRadius: -10)
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(31),
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
              const SizedBox(height: 48),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          AppStrings.get('retail_terminal').toUpperCase(), 
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.w900, 
            fontSize: 13, 
            letterSpacing: 2.5, 
            color: AppColors.textPrimary
          )
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.trash2, color: AppColors.error, size: 20),
            onPressed: () {
              context.read<BillingBloc>().add(ClearCart());
              HapticFeedback.mediumImpact();
            },
            tooltip: AppStrings.get('clear_cache'),
          ),
          const SizedBox(width: 8),
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
              return const PremiumLoader();
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
                  padding: const EdgeInsets.all(24.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _showAddProductSheet(context),
                          child: GlassCard(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                            backgroundOpacity: 0.05,
                            child: Row(
                              children: [
                                const Icon(LucideIcons.search, color: AppColors.primary, size: 20),
                                const SizedBox(width: 16),
                                Text(
                                  AppStrings.get('search_products').toUpperCase(),
                                  style: GoogleFonts.outfit(
                                    color: AppColors.textMuted, 
                                    fontWeight: FontWeight.w700, 
                                    fontSize: 12,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      if (!kIsWeb && (Platform.isAndroid || Platform.isIOS))
                        GestureDetector(
                          onTap: () => _showBarcodeScanner(context),
                          child: Container(
                            height: 60,
                            width: 60,
                            decoration: BoxDecoration(
                              gradient: AppColors.goldGradient,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withOpacity(0.3),
                                  blurRadius: 15,
                                  offset: const Offset(0, 5),
                                )
                              ],
                            ),
                            child: const Icon(LucideIcons.scan, color: Colors.black),
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
                              Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.05),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: AppColors.primary.withOpacity(0.1)),
                                ),
                                child: Icon(LucideIcons.shoppingCart, size: 48, color: AppColors.primary.withOpacity(0.3)),
                              ),
                              const SizedBox(height: 24),
                              Text(
                                AppStrings.get('cart_is_empty').toUpperCase(),
                                style: GoogleFonts.outfit(
                                  color: AppColors.textMuted, 
                                  fontWeight: FontWeight.w900, 
                                  letterSpacing: 2,
                                  fontSize: 14,
                                ),
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

