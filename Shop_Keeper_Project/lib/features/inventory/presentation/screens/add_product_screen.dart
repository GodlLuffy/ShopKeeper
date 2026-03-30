import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:shop_keeper_project/features/inventory/presentation/bloc/inventory_cubit.dart';
import 'package:shop_keeper_project/features/inventory/domain/entities/product_entity.dart';
import 'package:shop_keeper_project/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:shop_keeper_project/services/local_image_service.dart';
import 'package:shop_keeper_project/injection_container.dart';
import 'package:shop_keeper_project/core/theme/app_theme.dart';
import 'package:shop_keeper_project/core/widgets/custom_text_field.dart';
import 'package:shop_keeper_project/core/widgets/primary_button.dart';
import 'package:shop_keeper_project/core/widgets/glass_card.dart';
import 'package:shop_keeper_project/core/localization/app_strings.dart';
import 'package:shop_keeper_project/core/utils/app_error_handler.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _nameController = TextEditingController();
  final _buyPriceController = TextEditingController();
  final _sellPriceController = TextEditingController();
  final _stockController = TextEditingController();
  final _minStockController = TextEditingController();
  final _barcodeController = TextEditingController();
  late String _category;
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    _category = AppStrings.get('general_store');
  }

  void _showImagePicker() {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: AppTheme.darkBackgroundLayer,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(4))),
              const SizedBox(height: 12),
              ListTile(
                leading: const Icon(Icons.camera_alt_rounded, color: AppTheme.primaryIndigo),
                title: Text(AppStrings.get('capture_image'), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1, color: AppTheme.textWhite)),
                onTap: () {
                  Navigator.pop(context);
                  _pickAndCropImage(true);
                },
              ),
              ListTile(
                leading: const Icon(Icons.image_rounded, color: AppTheme.accentTeal),
                title: Text(AppStrings.get('import_gallery'), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1, color: AppTheme.textWhite)),
                onTap: () {
                  Navigator.pop(context);
                  _pickAndCropImage(false);
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  void _pickAndCropImage(bool fromCamera) async {
    final service = sl<LocalImageService>();
    final cropped = await service.pickAndCropImage(fromCamera);
    if (cropped != null) {
      if (mounted) setState(() => _imageFile = cropped);
    }
  }

  void _showBarcodeScanner() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        height: MediaQuery.of(ctx).size.height * 0.7,
        decoration: const BoxDecoration(
          color: AppTheme.darkBackgroundLayer,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 32),
            Text(AppStrings.get('barcode_acquisition'), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 2, color: AppTheme.accentTeal)),
            const SizedBox(height: 24),
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
                      final List<Barcode> barcodes = capture.barcodes;
                      if (barcodes.isNotEmpty) {
                        setState(() => _barcodeController.text = barcodes.first.rawValue ?? '');
                        Navigator.pop(ctx);
                      }
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  void _saveProduct() {
    if (_nameController.text.isEmpty) {
      AppErrorHandler.showError(context, AppStrings.get('product_name_required'));
      return;
    }

    final authState = context.read<AuthCubit>().state;
    String userId = 'unknown';
    if (authState is Authenticated) {
      userId = authState.user.uid;
    } else if (authState is PinRequired) {
      userId = authState.user.uid;
    }

    final product = ProductEntity(
      id: '', 
      name: _nameController.text,
      category: _category,
      buyPrice: double.tryParse(_buyPriceController.text) ?? 0.0,
      sellPrice: double.tryParse(_sellPriceController.text) ?? 0.0,
      stockQuantity: int.tryParse(_stockController.text) ?? 0,
      minStockAlert: int.tryParse(_minStockController.text) ?? 0,
      userId: userId,
      createdAt: DateTime.now(),
      imageUrl: null, 
      barcode: _barcodeController.text.isEmpty ? null : _barcodeController.text,
    );
    
    context.read<InventoryCubit>().addProduct(
      product, 
      imageFile: _imageFile,
      barcode: _barcodeController.text.isEmpty ? null : _barcodeController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackgroundMain,
      appBar: AppBar(
        title: Text(AppStrings.get('new_inventory_item'), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 2)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: BlocConsumer<InventoryCubit, InventoryState>(
        listener: (context, state) {
          if (state is InventoryLoaded) {
            AppErrorHandler.showSuccess(context, AppStrings.get('item_logged'));
            Navigator.pop(context);
          } else if (state is InventoryError) {
            AppErrorHandler.showError(context, state.message);
          }
        },
        builder: (context, state) {
          final isLoading = state is InventoryLoading;
          
          return Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.topRight,
                radius: 1.5,
                colors: [
                  AppTheme.primaryIndigo.withOpacity(0.03),
                  Colors.transparent,
                ],
              ),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: isLoading ? null : _showImagePicker,
                    child: Container(
                      height: 180,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppTheme.darkBackgroundLayer.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(color: Colors.white.withOpacity(0.05)),
                      ),
                      child: _imageFile == null
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryIndigo.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.add_a_photo_rounded, size: 40, color: AppTheme.primaryIndigo),
                                ),
                                const SizedBox(height: 16),
                                Text(AppStrings.get('visual_specimen'), style: const TextStyle(color: AppTheme.textWhite, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1)),
                                Text(AppStrings.get('upload_image_hint'), style: const TextStyle(color: AppTheme.textMuted, fontSize: 10)),
                              ],
                            )
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(28),
                              child: Image.file(_imageFile!, fit: BoxFit.cover),
                            ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  GlassCard(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.terminal_rounded, color: AppTheme.accentTeal, size: 18),
                            const SizedBox(width: 12),
                            Text(AppStrings.get('core_specifications'), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: AppTheme.textGrey, letterSpacing: 1.5)),
                          ],
                        ),
                        const SizedBox(height: 32),
                        
                        CustomTextField(
                          label: AppStrings.get('product_designation'), 
                          controller: _nameController,
                          prefixIcon: Icons.badge_outlined,
                        ),
                        const SizedBox(height: 24),
                        
                        Text(AppStrings.get('data_classification'), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: AppTheme.textGrey, letterSpacing: 1)),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: AppTheme.darkBackgroundMain.withOpacity(0.35),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white.withOpacity(0.08)),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButtonFormField<String>(
                              value: _category,
                              dropdownColor: AppTheme.darkBackgroundLayer,
                              style: const TextStyle(color: AppTheme.textWhite, fontWeight: FontWeight.w700, fontSize: 14),
                              decoration: const InputDecoration(border: InputBorder.none),
                              items: [
                                AppStrings.get('general_store'),
                                AppStrings.get('sweets_bakery'),
                                AppStrings.get('biscuits_snacks'),
                                AppStrings.get('others'),
                              ]
                                  .map((c) => DropdownMenuItem(value: c, child: Text(c.toUpperCase())))
                                  .toList(),
                              onChanged: (val) => setState(() => _category = val!),
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        
                        Row(
                          children: [
                            Expanded(child: CustomTextField(label: AppStrings.get('acq_cost'), controller: _buyPriceController, keyboardType: TextInputType.number, prefixIcon: Icons.shopping_basket_outlined)),
                            const SizedBox(width: 16),
                            Expanded(child: CustomTextField(label: AppStrings.get('retail_val'), controller: _sellPriceController, keyboardType: TextInputType.number, prefixIcon: Icons.sell_outlined)),
                          ],
                        ),
                        const SizedBox(height: 24),
                        
                        Row(
                          children: [
                            Expanded(child: CustomTextField(label: AppStrings.get('curr_stock'), controller: _stockController, keyboardType: TextInputType.number, prefixIcon: Icons.inventory_2_outlined)),
                            const SizedBox(width: 16),
                            Expanded(child: CustomTextField(label: AppStrings.get('alert_lvl'), controller: _minStockController, keyboardType: TextInputType.number, prefixIcon: Icons.notification_important_outlined)),
                          ],
                        ),
                        const SizedBox(height: 24),
                        
                        CustomTextField(
                          label: AppStrings.get('barcode_encoding'),
                          controller: _barcodeController,
                          prefixIcon: Icons.qr_code_rounded,
                          suffixIcon: (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) 
                            ? IconButton(
                                icon: const Icon(Icons.qr_code_scanner_rounded, color: AppTheme.accentTeal),
                                onPressed: _showBarcodeScanner,
                              )
                            : null,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 48),
                  
                  PrimaryButton(
                    onPressed: isLoading ? null : _saveProduct,
                    text: AppStrings.get('commit_to_inventory'),
                    isLoading: isLoading,
                  ),
                  const SizedBox(height: 64),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
