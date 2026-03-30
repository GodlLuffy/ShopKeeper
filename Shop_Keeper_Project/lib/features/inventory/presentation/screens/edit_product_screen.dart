import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:shop_keeper_project/features/inventory/domain/entities/product_entity.dart';
import 'package:shop_keeper_project/features/inventory/presentation/bloc/inventory_cubit.dart';
import 'package:shop_keeper_project/services/local_image_service.dart';
import 'package:shop_keeper_project/injection_container.dart';
import 'package:shop_keeper_project/core/theme/app_theme.dart';
import 'package:shop_keeper_project/core/widgets/custom_text_field.dart';
import 'package:shop_keeper_project/core/widgets/primary_button.dart';
import 'package:shop_keeper_project/core/widgets/glass_card.dart';
import 'package:shop_keeper_project/core/localization/app_strings.dart';
import 'package:shop_keeper_project/core/utils/app_error_handler.dart';

class EditProductScreen extends StatefulWidget {
  final String productId;
  const EditProductScreen({super.key, required this.productId});

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _nameController = TextEditingController();
  final _buyPriceController = TextEditingController();
  final _sellPriceController = TextEditingController();
  final _stockController = TextEditingController();
  final _minStockController = TextEditingController();
  final _barcodeController = TextEditingController();
  late String _category;
  File? _imageFile;
  ProductEntity? _originalProduct;
  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _initFromInventory();
    }
  }

  void _initFromInventory() {
    final state = context.read<InventoryCubit>().state;
    if (state is InventoryLoaded) {
      try {
        final product = state.products.firstWhere((p) => p.id == widget.productId);
        _originalProduct = product;
        _nameController.text = product.name;
        _buyPriceController.text = product.buyPrice.toString();
        _sellPriceController.text = product.sellPrice.toString();
        _stockController.text = product.stockQuantity.toString();
        _minStockController.text = product.minStockAlert.toString();
        _barcodeController.text = product.barcode ?? '';
        _category = product.category;
        _isInitialized = true;
      } catch (e) {
        // Product not found in local list
      }
    }
  }

  void _showImagePicker() {
    final theme = Theme.of(context);
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40, 
                height: 4, 
                decoration: BoxDecoration(
                  color: (theme.brightness == Brightness.dark ? Colors.white24 : Colors.black12), 
                  borderRadius: BorderRadius.circular(4)
                )
              ),
              const SizedBox(height: 12),
              ListTile(
                leading: const Icon(Icons.camera_alt_rounded, color: AppTheme.primaryIndigo),
                title: Text(AppStrings.get('capture_image'), style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1, color: theme.colorScheme.onSurface)),
                onTap: () {
                  Navigator.pop(context);
                  _pickAndCropImage(true);
                },
              ),
              ListTile(
                leading: const Icon(Icons.image_rounded, color: AppTheme.accentTeal),
                title: Text(AppStrings.get('import_gallery'), style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1, color: theme.colorScheme.onSurface)),
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
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        height: MediaQuery.of(ctx).size.height * 0.7,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
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

  void _updateProduct() {
    if (_nameController.text.isEmpty) {
      AppErrorHandler.showError(context, AppStrings.get('product_name_required'));
      return;
    }

    if (_originalProduct == null) {
      AppErrorHandler.showError(context, "Original product data lost. Please try again.");
      return;
    }

    final product = ProductEntity(
      id: _originalProduct!.id, 
      name: _nameController.text,
      category: _category,
      buyPrice: double.tryParse(_buyPriceController.text) ?? _originalProduct!.buyPrice,
      sellPrice: double.tryParse(_sellPriceController.text) ?? _originalProduct!.sellPrice,
      stockQuantity: int.tryParse(_stockController.text) ?? _originalProduct!.stockQuantity,
      minStockAlert: int.tryParse(_minStockController.text) ?? _originalProduct!.minStockAlert,
      userId: _originalProduct!.userId,
      createdAt: _originalProduct!.createdAt,
      imageUrl: _originalProduct!.imageUrl, 
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (!_isInitialized) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(title: const Text('EDIT PRODUCT')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(AppStrings.get('edit_product_action').toUpperCase(), style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 2, color: theme.colorScheme.onSurface)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: theme.colorScheme.onSurface),
      ),
      body: BlocConsumer<InventoryCubit, InventoryState>(
        listener: (context, state) {
          if (state is InventoryLoaded) {
            AppErrorHandler.showSuccess(context, AppStrings.get('item_updated'));
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
                  AppTheme.primaryIndigo.withOpacity(isDark ? 0.03 : 0.02),
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
                        color: theme.colorScheme.surface.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(color: (isDark ? Colors.white : Colors.black).withOpacity(0.05)),
                      ),
                      child: _imageFile == null && _originalProduct?.imageUrl == null
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
                                Text(AppStrings.get('visual_specimen'), style: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1)),
                                Text(AppStrings.get('upload_image_hint'), style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 10)),
                              ],
                            )
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(28),
                              child: _imageFile != null 
                                ? Image.file(_imageFile!, fit: BoxFit.cover)
                                : Image.file(File(_originalProduct!.imageUrl!), fit: BoxFit.cover),
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
                            Text(AppStrings.get('core_specifications'), style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: theme.colorScheme.onSurfaceVariant, letterSpacing: 1.5)),
                          ],
                        ),
                        const SizedBox(height: 32),
                        
                        CustomTextField(
                          label: AppStrings.get('product_designation'), 
                          controller: _nameController,
                          prefixIcon: Icons.badge_outlined,
                        ),
                        const SizedBox(height: 24),
                        
                        Text(AppStrings.get('data_classification'), style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: theme.colorScheme.onSurfaceVariant, letterSpacing: 1)),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: theme.scaffoldBackgroundColor.withOpacity(0.35),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: (isDark ? Colors.white : Colors.black).withOpacity(0.08)),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButtonFormField<String>(
                              value: _category,
                              dropdownColor: theme.colorScheme.surface,
                              style: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.w700, fontSize: 14),
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
                    onPressed: isLoading ? null : _updateProduct,
                    text: AppStrings.get('save_config'),
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
