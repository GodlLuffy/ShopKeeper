import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/usecases/get_products.dart';
import '../../domain/usecases/add_product.dart';
import '../../domain/usecases/update_stock.dart';
import '../../domain/usecases/delete_product.dart';
import '../../domain/usecases/get_product_by_barcode.dart';

part 'inventory_state.dart';

class InventoryCubit extends Cubit<InventoryState> {
  final GetProducts getProducts;
  final AddProduct addProductUseCase;
  final UpdateStock updateStockUseCase;
  final DeleteProduct deleteProductUseCase;
  final GetProductByBarcode getProductByBarcodeUseCase;

  InventoryCubit({
    required this.getProducts,
    required this.addProductUseCase,
    required this.updateStockUseCase,
    required this.deleteProductUseCase,
    required this.getProductByBarcodeUseCase,
  }) : super(InventoryInitial());

  Future<void> loadProducts() async {
    emit(InventoryLoading());
    final result = await getProducts(NoParams());
    result.fold(
      (failure) => emit(InventoryError(failure.message)),
      (products) => emit(InventoryLoaded(products)),
    );
  }

  Future<void> addProduct(ProductEntity product, {File? imageFile, String? barcode}) async {
    final result = await addProductUseCase(AddProductParams(
      product: product,
      imageFile: imageFile,
      barcode: barcode,
    ));
    result.fold(
      (failure) => emit(InventoryError(failure.message)),
      (_) => loadProducts(),
    );
  }

  Future<void> updateStock(String productId, int quantityChange, String action) async {
    final result = await updateStockUseCase(UpdateStockParams(
      productId: productId,
      quantityChange: quantityChange,
      action: action,
    ));
    result.fold(
      (failure) => emit(InventoryError(failure.message)),
      (_) => loadProducts(),
    );
  }

  Future<void> deleteProduct(String id) async {
    final result = await deleteProductUseCase(id);
    result.fold(
      (failure) => emit(InventoryError(failure.message)),
      (_) => loadProducts(),
    );
  }

  Future<ProductEntity?> getProductByBarcode(String barcode) async {
    final result = await getProductByBarcodeUseCase(barcode);
    return result.fold(
      (failure) => null,
      (product) => product,
    );
  }

  List<ProductEntity> get lowStockProducts {
    if (state is! InventoryLoaded) return [];
    return (state as InventoryLoaded).products
        .where((p) => p.stockQuantity > 0 && p.stockQuantity <= p.minStockAlert)
        .toList();
  }

  List<ProductEntity> get outOfStockProducts {
    if (state is! InventoryLoaded) return [];
    return (state as InventoryLoaded).products
        .where((p) => p.stockQuantity <= 0)
        .toList();
  }

  List<ProductEntity> get allLowStockProducts {
    return [...outOfStockProducts, ...lowStockProducts];
  }

  Map<String, int> calculateRestockQuantities({int suggestedStock = 50}) {
    final restockMap = <String, int>{};
    for (final product in allLowStockProducts) {
      restockMap[product.id] = suggestedStock - product.stockQuantity;
    }
    return restockMap;
  }

  double getTotalRestockValue({int suggestedStock = 50}) {
    double total = 0;
    for (final product in allLowStockProducts) {
      final qtyNeeded = suggestedStock - product.stockQuantity;
      total += qtyNeeded * product.buyPrice;
    }
    return total;
  }
}
