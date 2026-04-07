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
import 'package:shop_keeper_project/core/theme/app_colors.dart';
import 'package:shop_keeper_project/core/widgets/custom_text_field.dart';
import 'package:shop_keeper_project/core/widgets/primary_button.dart';
import 'package:shop_keeper_project/core/widgets/glass_card.dart';
import 'package:shop_keeper_project/core/localization/app_strings.dart';
import 'package:shop_keeper_project/core/utils/app_error_handler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

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
    HapticFeedback.selectionClick();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          border: Border(top: BorderSide(color: AppColors.glassBorder)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.textMuted, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 32),
            _buildPickerTile(LucideIcons.camera, 'CAPTURE IMAGE', 'OPERATE CAMERA MODULE', () {
              Navigator.pop(context);
              _pickAndCropImage(true);
            }),
            _buildPickerTile(LucideIcons.image, 'IMPORT GALLERY', 'SELECT FROM LOCAL STORAGE', () {
              Navigator.pop(context);
              _pickAndCropImage(false);
            }),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildPickerTile(IconData icon, String title, String subtitle, VoidCallback onTap) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.05), borderRadius: BorderRadius.circular(12)),
        child: Icon(icon, color: AppColors.primary, size: 20),
      ),
      title: Text(title, style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w900, color: AppColors.textPrimary, letterSpacing: 1.5)),
      subtitle: Text(subtitle, style: GoogleFonts.outfit(fontSize: 10, color: AppColors.textMuted, fontWeight: FontWeight.w700)),
      trailing: const Icon(LucideIcons.chevronRight, color: AppColors.textMuted, size: 16),
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
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          border: Border(top: BorderSide(color: AppColors.glassBorder)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 24),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.textMuted, borderRadius: BorderRadius.circular(4))),
            const SizedBox(height: 32),
            Text(
              'BARCODE ACQUISITION',
              style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 2.5, color: AppColors.primary),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.glassBorder, width: 2),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: MobileScanner(
                    onDetect: (capture) {
                      final List<Barcode> barcodes = capture.barcodes;
                      if (barcodes.isNotEmpty) {
                        setState(() => _barcodeController.text = barcodes.first.rawValue ?? '');
                        Navigator.pop(ctx);
                        HapticFeedback.heavyImpact();
                      }
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  void _saveProduct() {
    if (_nameController.text.isEmpty) {
      AppErrorHandler.showError(context, 'PRODUCT DESIGNATION REQUIRED');
      return;
    }

    final authState = context.read<AuthCubit>().state;
    String userId = 'unknown';
    if (authState is Authenticated) userId = authState.user.uid;

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
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(
          'NEW ASSET REGISTRATION',
          style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 2, color: AppColors.textPrimary)
        ),
        centerTitle: true,
      ),
      body: BlocConsumer<InventoryCubit, InventoryState>(
        listener: (context, state) {
          if (state is InventoryLoaded) {
            AppErrorHandler.showSuccess(context, 'ASSET SECURED IN VAULT');
            Navigator.pop(context);
          } else if (state is InventoryError) {
            AppErrorHandler.showError(context, state.message.toUpperCase());
          }
        },
        builder: (context, state) {
          final isLoading = state is InventoryLoading;
          
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Specimen Portal
                GestureDetector(
                  onTap: isLoading ? null : _showImagePicker,
                  child: Container(
                    height: 180,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: AppColors.glassBorder, width: 2),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 30, offset: const Offset(0, 15))
                      ],
                    ),
                    child: _imageFile == null
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(LucideIcons.camera, size: 32, color: AppColors.primary),
                              const SizedBox(height: 16),
                              Text(
                                'VISUAL SPECIMEN', 
                                style: GoogleFonts.outfit(color: AppColors.primary, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 2)
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'TAP TO OPERATE OPTICS', 
                                style: GoogleFonts.outfit(color: AppColors.textMuted, fontSize: 9, fontWeight: FontWeight.w700)
                              ),
                            ],
                          )
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(26),
                            child: Image.file(_imageFile!, fit: BoxFit.cover),
                          ),
                  ),
                ),
                const SizedBox(height: 32),
                
                GlassCard(
                  padding: const EdgeInsets.all(28),
                  backgroundOpacity: 0.05,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(LucideIcons.cpu, color: AppColors.primary, size: 16),
                          const SizedBox(width: 12),
                          Text(
                            'CORE SPECIFICATIONS', 
                            style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w900, color: AppColors.textSecondary, letterSpacing: 2)
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      
                      CustomTextField(
                        label: 'PRODUCT DESIGNATION', 
                        controller: _nameController,
                        prefixIcon: LucideIcons.tag,
                        hintText: 'ENTER ASSET NAME',
                      ),
                      const SizedBox(height: 24),
                      
                      Text(
                        'DATA CLASSIFICATION',
                        style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w900, color: AppColors.textMuted, letterSpacing: 1.5)
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.glassBorder),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButtonFormField<String>(
                            value: _category,
                            dropdownColor: AppColors.surface,
                            icon: const Icon(LucideIcons.chevronDown, color: AppColors.textMuted, size: 16),
                            style: GoogleFonts.outfit(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 13),
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
                          Expanded(
                            child: CustomTextField(
                              label: 'ACQ. COST', 
                              controller: _buyPriceController, 
                              keyboardType: TextInputType.number, 
                              prefixIcon: LucideIcons.shoppingCart,
                              hintText: '0.00',
                            )
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: CustomTextField(
                              label: 'RETAIL VAL', 
                              controller: _sellPriceController, 
                              keyboardType: TextInputType.number, 
                              prefixIcon: LucideIcons.banknote,
                              hintText: '0.00',
                            )
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      
                      Row(
                        children: [
                          Expanded(
                            child: CustomTextField(
                              label: 'CURR. STOCK', 
                              controller: _stockController, 
                              keyboardType: TextInputType.number, 
                              prefixIcon: LucideIcons.layers,
                              hintText: '0',
                            )
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: CustomTextField(
                              label: 'ALERT LVL', 
                              controller: _minStockController, 
                              keyboardType: TextInputType.number, 
                              prefixIcon: LucideIcons.bellRing,
                              hintText: '5',
                            )
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      
                      CustomTextField(
                        label: 'BARCODE ENCODING',
                        controller: _barcodeController,
                        prefixIcon: LucideIcons.scan,
                        hintText: 'SCAN OR TYPE ID',
                        suffixIcon: IconButton(
                          icon: const Icon(LucideIcons.maximize, color: AppColors.primary, size: 20),
                          onPressed: _showBarcodeScanner,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 48),
                
                PrimaryButton(
                  onPressed: isLoading ? null : _saveProduct,
                  text: 'COMMIT TO INVENTORY',
                  isLoading: isLoading,
                ),
                const SizedBox(height: 64),
              ],
            ),
          );
        },
      ),
    );
  }
}
