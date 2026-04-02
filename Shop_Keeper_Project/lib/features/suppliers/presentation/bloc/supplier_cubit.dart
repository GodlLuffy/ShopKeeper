import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shop_keeper_project/features/suppliers/domain/entities/supplier.dart';
import 'package:shop_keeper_project/features/suppliers/domain/repositories/supplier_repository.dart';

abstract class SupplierState extends Equatable {
  const SupplierState();
  @override
  List<Object?> get props => [];
}

class SupplierInitial extends SupplierState {}
class SupplierLoading extends SupplierState {}
class SupplierLoaded extends SupplierState {
  final List<Supplier> suppliers;
  const SupplierLoaded(this.suppliers);
  @override
  List<Object?> get props => [suppliers];
}
class SupplierError extends SupplierState {
  final String message;
  const SupplierError(this.message);
  @override
  List<Object?> get props => [message];
}

class SupplierCubit extends Cubit<SupplierState> {
  final SupplierRepository repository;

  SupplierCubit({required this.repository}) : super(SupplierInitial());

  Future<void> loadSuppliers() async {
    emit(SupplierLoading());
    final result = await repository.getSuppliers();
    result.fold(
      (failure) => emit(const SupplierError('Failed to load suppliers')),
      (suppliers) => emit(SupplierLoaded(suppliers)),
    );
  }

  Future<void> addSupplier(Supplier supplier) async {
    final result = await repository.addSupplier(supplier);
    result.fold(
      (failure) => emit(const SupplierError('Failed to add supplier')),
      (_) => loadSuppliers(),
    );
  }

  Future<void> deleteSupplier(String id) async {
    final result = await repository.deleteSupplier(id);
    result.fold(
      (failure) => emit(const SupplierError('Failed to delete supplier')),
      (_) => loadSuppliers(),
    );
  }

  Future<void> addTransaction(SupplierTransaction tx) async {
    final result = await repository.addTransaction(tx);
    result.fold(
      (failure) => emit(const SupplierError('Failed to record transaction')),
      (_) => loadSuppliers(),
    );
  }
}
