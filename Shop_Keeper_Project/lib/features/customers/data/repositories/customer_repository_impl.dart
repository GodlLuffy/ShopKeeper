import 'package:dartz/dartz.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/customer_entity.dart';
import '../../domain/entities/credit_transaction_entity.dart';
import '../../domain/repositories/customer_repository.dart';
import '../datasources/customer_local_data_source.dart';
import '../datasources/customer_remote_data_source.dart';
import '../../../../database/tables/customer_table.dart';
import '../../../../database/tables/credit_transaction_table.dart';

class CustomerRepositoryImpl implements CustomerRepository {
  final CustomerLocalDataSource localDataSource;
  final CustomerRemoteDataSource remoteDataSource;

  CustomerRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
  });

  // ─── Mappers ───────────────────────────────────────────

  CustomerEntity _tableToEntity(CustomerTable t) {
    return CustomerEntity(
      id: t.id,
      shopId: t.shopId,
      name: t.name,
      phone: t.phone,
      totalCredit: t.totalCredit,
      lastTransactionDate: t.lastTransactionDate,
      createdAt: t.createdAt,
      notes: t.notes,
    );
  }

  CustomerTable _entityToTable(CustomerEntity e) {
    return CustomerTable(
      id: e.id,
      shopId: e.shopId,
      name: e.name,
      phone: e.phone,
      totalCredit: e.totalCredit,
      lastTransactionDate: e.lastTransactionDate,
      createdAt: e.createdAt,
      notes: e.notes,
    );
  }

  CreditTransactionEntity _txTableToEntity(CreditTransactionTable t) {
    return CreditTransactionEntity(
      id: t.id,
      customerId: t.customerId,
      shopId: t.shopId,
      amount: t.amount,
      type: t.type == 'credit' ? TransactionType.credit : TransactionType.payment,
      description: t.description,
      date: t.date,
      balanceAfter: t.balanceAfter,
      billId: t.billId,
    );
  }

  // ─── CRUD ──────────────────────────────────────────────

  @override
  Future<Either<Failure, List<CustomerEntity>>> getCustomers() async {
    try {
      final tables = await localDataSource.getCustomers();
      final entities = tables.map(_tableToEntity).toList()
        ..sort((a, b) => b.lastTransactionDate.compareTo(a.lastTransactionDate));
      return Right(entities);
    } catch (e) {
      return Left(CacheFailure('Failed to load customers: $e'));
    }
  }

  @override
  Future<Either<Failure, CustomerEntity>> getCustomerById(String id) async {
    try {
      final table = await localDataSource.getCustomerById(id);
      if (table == null) {
        return const Left(CacheFailure('Customer not found'));
      }
      return Right(_tableToEntity(table));
    } catch (e) {
      return Left(CacheFailure('Failed to load customer: $e'));
    }
  }

  @override
  Future<Either<Failure, CustomerEntity>> addCustomer(CustomerEntity customer) async {
    try {
      final table = _entityToTable(customer);
      await localDataSource.saveCustomer(table);

      // Sync to remote (fire and forget)
      try {
        await remoteDataSource.saveCustomer(table.toMap());
      } catch (e) {
        debugPrint('Remote sync failed for customer: $e');
      }

      return Right(customer);
    } catch (e) {
      return Left(CacheFailure('Failed to add customer: $e'));
    }
  }

  @override
  Future<Either<Failure, CustomerEntity>> updateCustomer(CustomerEntity customer) async {
    try {
      final table = _entityToTable(customer);
      await localDataSource.saveCustomer(table);

      try {
        await remoteDataSource.saveCustomer(table.toMap());
      } catch (e) {
        debugPrint('Remote sync failed for customer update: $e');
      }

      return Right(customer);
    } catch (e) {
      return Left(CacheFailure('Failed to update customer: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteCustomer(String id) async {
    try {
      // Get customer before deleting to know shopId for remote sync
      final customer = await localDataSource.getCustomerById(id);
      await localDataSource.deleteCustomer(id);

      if (customer != null) {
        try {
          await remoteDataSource.deleteCustomer(id, customer.shopId);
        } catch (e) {
          debugPrint('Remote delete failed for customer: $e');
        }
      }

      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Failed to delete customer: $e'));
    }
  }

  // ─── Credit / Payment ─────────────────────────────────

  @override
  Future<Either<Failure, CreditTransactionEntity>> addCredit(
    String customerId,
    double amount, {
    String? description,
    String? billId,
  }) async {
    try {
      final customerTable = await localDataSource.getCustomerById(customerId);
      if (customerTable == null) {
        return const Left(CacheFailure('Customer not found'));
      }

      final newBalance = customerTable.totalCredit + amount;
      final txId = const Uuid().v4();
      final now = DateTime.now();

      final transaction = CreditTransactionTable(
        id: txId,
        customerId: customerId,
        shopId: customerTable.shopId,
        amount: amount,
        type: 'credit',
        description: description ?? 'Credit given',
        date: now,
        balanceAfter: newBalance,
        billId: billId,
      );

      // Update customer balance
      final updatedCustomer = CustomerTable(
        id: customerTable.id,
        shopId: customerTable.shopId,
        name: customerTable.name,
        phone: customerTable.phone,
        totalCredit: newBalance,
        lastTransactionDate: now,
        createdAt: customerTable.createdAt,
        notes: customerTable.notes,
      );

      await localDataSource.saveTransaction(transaction);
      await localDataSource.saveCustomer(updatedCustomer);

      // Remote sync
      try {
        await remoteDataSource.saveCustomer(updatedCustomer.toMap());
        await remoteDataSource.saveTransaction(transaction.toMap(), customerTable.shopId);
      } catch (e) {
        debugPrint('Remote sync failed for credit transaction: $e');
      }

      return Right(_txTableToEntity(transaction));
    } catch (e) {
      return Left(CacheFailure('Failed to add credit: $e'));
    }
  }

  @override
  Future<Either<Failure, CreditTransactionEntity>> recordPayment(
    String customerId,
    double amount, {
    String? description,
  }) async {
    try {
      final customerTable = await localDataSource.getCustomerById(customerId);
      if (customerTable == null) {
        return const Left(CacheFailure('Customer not found'));
      }

      final newBalance = customerTable.totalCredit - amount;
      final txId = const Uuid().v4();
      final now = DateTime.now();

      final transaction = CreditTransactionTable(
        id: txId,
        customerId: customerId,
        shopId: customerTable.shopId,
        amount: amount,
        type: 'payment',
        description: description ?? 'Payment received',
        date: now,
        balanceAfter: newBalance,
      );

      final updatedCustomer = CustomerTable(
        id: customerTable.id,
        shopId: customerTable.shopId,
        name: customerTable.name,
        phone: customerTable.phone,
        totalCredit: newBalance,
        lastTransactionDate: now,
        createdAt: customerTable.createdAt,
        notes: customerTable.notes,
      );

      await localDataSource.saveTransaction(transaction);
      await localDataSource.saveCustomer(updatedCustomer);

      try {
        await remoteDataSource.saveCustomer(updatedCustomer.toMap());
        await remoteDataSource.saveTransaction(transaction.toMap(), customerTable.shopId);
      } catch (e) {
        debugPrint('Remote sync failed for payment: $e');
      }

      return Right(_txTableToEntity(transaction));
    } catch (e) {
      return Left(CacheFailure('Failed to record payment: $e'));
    }
  }

  @override
  Future<Either<Failure, List<CreditTransactionEntity>>> getTransactions(String customerId) async {
    try {
      final tables = await localDataSource.getTransactions(customerId);
      return Right(tables.map(_txTableToEntity).toList());
    } catch (e) {
      return Left(CacheFailure('Failed to load transactions: $e'));
    }
  }
}
