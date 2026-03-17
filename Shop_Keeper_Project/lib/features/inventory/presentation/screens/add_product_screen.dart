import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shop_keeper_project/features/inventory/presentation/bloc/inventory_cubit.dart';
import 'package:shop_keeper_project/features/inventory/data/models/product_model.dart';
import 'package:shop_keeper_project/services/storage_service.dart';
import 'package:uuid/uuid.dart';

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
  String _category = 'General Store';
  File? _imageFile;
  bool _isUploading = false;

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );
    if (pickedFile != null) {
      setState(() => _imageFile = File(pickedFile.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add New Product')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(16),
                  image: _imageFile != null
                      ? DecorationImage(image: FileImage(_imageFile!), fit: BoxFit.cover)
                      : null,
                ),
                child: _imageFile == null
                    ? const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_a_photo, size: 40, color: Colors.grey),
                          SizedBox(height: 8),
                          Text('Add Product Photo', style: TextStyle(color: Colors.grey)),
                        ],
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 24),
            TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Product Name')),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _category,
              items: ['General Store', 'Sweets/Bakery', 'Biscuits/Snacks', 'Other']
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (val) => setState(() => _category = val!),
              decoration: const InputDecoration(labelText: 'Category'),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: TextField(controller: _buyPriceController, decoration: const InputDecoration(labelText: 'Buy Price'), keyboardType: TextInputType.number)),
                const SizedBox(width: 16),
                Expanded(child: TextField(controller: _sellPriceController, decoration: const InputDecoration(labelText: 'Sell Price'), keyboardType: TextInputType.number)),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: TextField(controller: _stockController, decoration: const InputDecoration(labelText: 'Initial Stock'), keyboardType: TextInputType.number)),
                const SizedBox(width: 16),
                Expanded(child: TextField(controller: _minStockController, decoration: const InputDecoration(labelText: 'Min Stock Alert'), keyboardType: TextInputType.number)),
              ],
            ),
            const SizedBox(height: 48),
            _isUploading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: () async {
                      setState(() => _isUploading = true);
                      try {
                        String? imageUrl;
                        final productId = const Uuid().v4();

                        if (_imageFile != null) {
                          imageUrl = await StorageService().uploadProductImage(_imageFile!, productId);
                        }

                        final product = ProductModel(
                          id: productId,
                          name: _nameController.text,
                          category: _category,
                          buyPrice: double.tryParse(_buyPriceController.text) ?? 0.0,
                          sellPrice: double.tryParse(_sellPriceController.text) ?? 0.0,
                          stockQuantity: int.tryParse(_stockController.text) ?? 0,
                          minStockAlert: int.tryParse(_minStockController.text) ?? 0,
                          userId: 'dummy_user', // Will be replaced by actual user ID
                          createdAt: DateTime.now(),
                          imageUrl: imageUrl,
                        );
                        
                        if (!context.mounted) return;
                        context.read<InventoryCubit>().addProduct(product);
                        Navigator.pop(context);
                      } catch (e) {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: $e')),
                        );
                      } finally {
                        if (mounted) {
                          setState(() => _isUploading = false);
                        }
                      }
                    },
                    child: const Text('Save Product'),
                  ),
          ],
        ),
      ),
    );
  }
}
