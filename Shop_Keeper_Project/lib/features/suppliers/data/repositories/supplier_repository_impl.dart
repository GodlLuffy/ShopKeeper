import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shop_keeper_project/core/error/failures.dart';
import 'package:shop_keeper_project/core/services/sync_engine.dart';
import 'package:shop_keeper_project/database/tables/supplier_table.dart';
import 'package:shop_keeper_project/database/tables/supplier_transaction_table.dart';
import 'package:shop_keeper_project/features/suppliers/data/datasources/supplier_local_data_source.dart';
import 'package:shop_keeper_project/features/suppliers/data/datasources/supplier_remote_data_source.dart';
import 'package:shop_keeper_project/features/suppliers/domain/entities/supplier.dart' as entity;
import 'package:shop_keeper_project/features/suppliers/domain/repositories/supplier_repository.dart';

class SupplierRepositoryImpl implements SupplierRepository {
  final SupplierLocalDataSource localDataSource;
  final SupplierRemoteDataSource remoteDataSource;
  final SyncEngine syncEngine;

  SupplierRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
    required this.syncEngine,
  });

  @override
  Future<Either<Failure, List<entity.Supplier>>> getSuppliers() async {
    try {
      final tables = await localDataSource.getSuppliers();
      return Right(tables.map((t) => _mapTableToEntity(t)).toList());
    } catch (e) {
      return const Left(CacheFailure('Local cache exception'));
    }
  }

  @override
  Future<Either<Failure, entity.Supplier>> addSupplier(entity.Supplier supplier) async {
    try {
      final table = _mapEntityToTable(supplier);
      await localDataSource.cacheSupplier(table);
      syncEngine.queueOperation('suppliers', table.id, OperationType.create, table.toMap());
      return Right(supplier);
    } catch (e) {
      return const Left(CacheFailure('Local cache exception'));
    }
  }

  @override
  Future<Either<Failure, entity.Supplier>> updateSupplier(entity.Supplier supplier) async {
    try {
      final table = _mapEntityToTable(supplier);
      await localDataSource.cacheSupplier(table);
      syncEngine.queueOperation('suppliers', table.id, OperationType.update, table.toMap());
      return Right(supplier);
    } catch (e) {
      return const Left(CacheFailure('Local cache exception'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteSupplier(String id) async {
    try {
      await localDataSource.deleteSupplier(id);
      syncEngine.queueOperation('suppliers', id, OperationType.delete, null);
      return const Right(null);
    } catch (e) {
      return const Left(CacheFailure('Local cache exception'));
    }
  }

  @override
  Future<Either<Failure, List<entity.SupplierTransaction>>> getTransactions(String supplierId) async {
    try {
      final tables = await localDataSource.getTransactions(supplierId);
      return Right(tables.map((t) => _mapTxTableToEntity(t)).toList());
    } catch (e) {
      return const Left(CacheFailure('Local cache exception'));
    }
  }

  @override
  Future<Either<Failure, entity.SupplierTransaction>> addTransaction(entity.SupplierTransaction transaction) async {
    try {
      final table = _mapTxEntityToTable(transaction);
      await localDataSource.cacheTransaction(table);
      syncEngine.queueOperation('supplier_transactions', table.id, OperationType.create, table.toMap());
      
      // Implicitly update supplier balance
      final supplier = (await localDataSource.getSuppliers()).firstWhere((s) => s.id == transaction.supplierId);
      supplier.balance = transaction.balanceAfter;
      await localDataSource.cacheSupplier(supplier);
      syncEngine.queueOperation('suppliers', supplier.id, OperationType.update, supplier.toMap());
      
      return Right(transaction);
    } catch (e) {
      return const Left(CacheFailure('Local cache exception'));
    }
  }

  // Mapper Mappings
  entity.Supplier _mapTableToEntity(SupplierTable t) {
    return entity.Supplier(
      id: t.id,
      name: t.name,
      contactPerson: t.contactPerson,
      phone: t.phone,
      address: t.address,
      balance: t.balance,
      userId: t.userId,
      createdAt: t.createdAt,
      email: t.email,
    );
  }

  SupplierTable _mapEntityToTable(entity.Supplier e) {
    return SupplierTable(
      id: e.id,
      name: e.name,
      contactPerson: e.contactPerson,
      phone: e.phone,
      address: e.address,
      balance: e.balance,
      userId: e.userId,
      createdAt: e.createdAt,
      email: e.email,
    );
  }

  entity.SupplierTransaction _mapTxTableToEntity(SupplierTransactionTable t) {
    return entity.SupplierTransaction(
      id: t.id,
      supplierId: t.supplierId,
      type: entity.SupplierTransactionType.values[t.type.index],
      amount: t.amount,
      balanceAfter: t.balanceAfter,
      note: t.note,
      date: t.date,
      userId: t.userId,
    );
  }

  SupplierTransactionTable _mapTxEntityToTable(entity.SupplierTransaction e) {
    return SupplierTransactionTable(
      id: e.id,
      supplierId: e.supplierId,
      type: SupplierTransactionType.values[e.type.index],
      amount: e.amount,
      balanceAfter: e.balanceAfter,
      note: e.note,
      date: e.date,
      userId: e.userId,
    );
  }
}
