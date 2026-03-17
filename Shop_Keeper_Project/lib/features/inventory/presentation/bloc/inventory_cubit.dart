import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shop_keeper_project/features/inventory/domain/entities/product_entity.dart';
import 'package:shop_keeper_project/features/inventory/domain/repositories/inventory_repository.dart';

part 'inventory_state.dart';

class InventoryCubit extends Cubit<InventoryState> {
  final InventoryRepository repository;

  InventoryCubit({required this.repository}) : super(InventoryInitial());

  Future<void> loadProducts() async {
    emit(InventoryLoading());
    final result = await repository.getProducts();
    result.fold(
      (failure) => emit(InventoryError(failure.message)),
      (products) => emit(InventoryLoaded(products)),
    );
  }

  Future<void> addProduct(ProductEntity product) async {
    final result = await repository.addProduct(product);
    result.fold(
      (failure) => emit(InventoryError(failure.message)),
      (_) => loadProducts(),
    );
  }

  Future<void> updateStock(String productId, int quantityChange, String action) async {
    final result = await repository.updateStock(productId, quantityChange, action);
    result.fold(
      (failure) => emit(InventoryError(failure.message)),
      (_) => loadProducts(),
    );
  }
}
