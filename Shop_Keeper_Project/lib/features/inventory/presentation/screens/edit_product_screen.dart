import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shop_keeper_project/features/inventory/presentation/bloc/inventory_cubit.dart';
import 'package:shop_keeper_project/features/inventory/data/models/product_model.dart';
import 'package:shop_keeper_project/features/inventory/domain/entities/product_entity.dart';

class EditProductScreen extends StatefulWidget {
  final ProductEntity product;
  const EditProductScreen({super.key, required this.product});

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  late TextEditingController _nameController;
  late TextEditingController _buyPriceController;
  late TextEditingController _sellPriceController;
  late TextEditingController _stockController;
  late TextEditingController _minStockController;
  late String _category;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product.name);
    _buyPriceController = TextEditingController(text: widget.product.buyPrice.toString());
    _sellPriceController = TextEditingController(text: widget.product.sellPrice.toString());
    _stockController = TextEditingController(text: widget.product.stockQuantity.toString());
    _minStockController = TextEditingController(text: widget.product.minStockAlert.toString());
    _category = widget.product.category;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Edit ${widget.product.name}')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
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
                Expanded(child: TextField(controller: _stockController, decoration: const InputDecoration(labelText: 'Current Stock'), keyboardType: TextInputType.number)),
                const SizedBox(width: 16),
                Expanded(child: TextField(controller: _minStockController, decoration: const InputDecoration(labelText: 'Min Stock Alert'), keyboardType: TextInputType.number)),
              ],
            ),
            const SizedBox(height: 48),
            ElevatedButton(
              onPressed: () {
                final product = ProductModel(
                  id: widget.product.id,
                  name: _nameController.text,
                  category: _category,
                  buyPrice: double.tryParse(_buyPriceController.text) ?? widget.product.buyPrice,
                  sellPrice: double.tryParse(_sellPriceController.text) ?? widget.product.sellPrice,
                  stockQuantity: int.tryParse(_stockController.text) ?? widget.product.stockQuantity,
                  minStockAlert: int.tryParse(_minStockController.text) ?? widget.product.minStockAlert,
                  userId: widget.product.userId,
                  createdAt: widget.product.createdAt,
                );
                context.read<InventoryCubit>().addProduct(product); // addProduct handles update in this implementation
                Navigator.pop(context);
              },
              child: const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}
