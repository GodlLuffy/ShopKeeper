import 'package:dartz/dartz.dart';
import 'package:shop_keeper_project/core/error/failures.dart';
import 'package:shop_keeper_project/features/suppliers/domain/entities/supplier.dart';

abstract class SupplierRepository {
  Future<Either<Failure, List<Supplier>>> getSuppliers();
  Future<Either<Failure, Supplier>> addSupplier(Supplier supplier);
  Future<Either<Failure, Supplier>> updateSupplier(Supplier supplier);
  Future<Either<Failure, void>> deleteSupplier(String id);
  Future<Either<Failure, List<SupplierTransaction>>> getTransactions(String supplierId);
  Future<Either<Failure, SupplierTransaction>> addTransaction(SupplierTransaction transaction);
}
