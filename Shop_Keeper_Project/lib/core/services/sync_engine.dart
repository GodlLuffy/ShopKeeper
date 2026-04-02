import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shop_keeper_project/database/tables/product_table.dart';
import 'package:shop_keeper_project/database/tables/sale_table.dart';
import 'package:shop_keeper_project/database/tables/expense_table.dart';
import 'package:shop_keeper_project/database/tables/customer_table.dart';
import 'package:shop_keeper_project/database/tables/credit_transaction_table.dart';
import 'package:shop_keeper_project/database/tables/supplier_table.dart';
import 'package:shop_keeper_project/database/tables/supplier_transaction_table.dart';
import 'package:shop_keeper_project/core/services/mysql_service.dart';

enum SyncStatus { idle, syncing, error, offline }

enum OperationType { create, update, delete }

class PendingOperation {
  final String id;
  final String collection;
  final String documentId;
  final OperationType type;
  final Map<String, dynamic>? data;
  final DateTime createdAt;
  int retryCount;

  PendingOperation({
    required this.id,
    required this.collection,
    required this.documentId,
    required this.type,
    this.data,
    required this.createdAt,
    this.retryCount = 0,
  });
}

class SyncEngine {
  final FirebaseFirestore? firestore;
  final FirebaseAuth? auth;
  final Box<ProductTable> productBox;
  final Box<SaleTable> saleBox;
  final Box<ExpenseTable> expenseBox;
  final Box<CustomerTable> customerBox;
  final Box<CreditTransactionTable> transactionBox;
  final Box<SupplierTable> supplierBox;
  final Box<SupplierTransactionTable> supplierTxBox;
  final Box pendingOpsBox;
  final MySQLService? mysqlService;

  Completer<void>? _syncCompleter;

  SyncStatus _status = SyncStatus.idle;
  SyncStatus get status => _status;
  
  DateTime? _lastSyncTime;
  DateTime? get lastSyncTime => _lastSyncTime;

  final _statusController = StreamController<SyncStatus>.broadcast();
  Stream<SyncStatus> get statusStream => _statusController.stream;

  static const _maxRetries = 3;
  static const _batchLimit = 500;

  SyncEngine({
    this.firestore,
    this.auth,
    required this.productBox,
    required this.saleBox,
    required this.expenseBox,
    required this.customerBox,
    required this.transactionBox,
    required this.supplierBox,
    required this.supplierTxBox,
    required this.pendingOpsBox,
    this.mysqlService,
  }) {
    _loadLastSyncTime();
  }

  void _loadLastSyncTime() {
    final stored = pendingOpsBox.get('lastSyncTime');
    if (stored != null) {
      _lastSyncTime = DateTime.fromMillisecondsSinceEpoch(stored);
    }
  }

  void _saveLastSyncTime() {
    _lastSyncTime = DateTime.now();
    pendingOpsBox.put('lastSyncTime', _lastSyncTime!.millisecondsSinceEpoch);
  }

  Future<void> syncAll() async {
    if (_status == SyncStatus.syncing) {
      return _syncCompleter?.future ?? Future.value();
    }
    _syncCompleter = Completer<void>();
    
    final user = auth?.currentUser;
    if (user == null && firestore != null) {
      _updateStatus(SyncStatus.offline);
      if (!(_syncCompleter?.isCompleted ?? true)) _syncCompleter?.complete();
      _syncCompleter = null;
      return;
    }

    final String userId = user?.uid ?? 'DEMO_USER';
    _updateStatus(SyncStatus.syncing);

    try {
      await _pushPendingOperations(userId);
      if (firestore != null && user != null) {
        await _pullRemoteChanges(userId);
      }
      _saveLastSyncTime();
      _updateStatus(SyncStatus.idle);
    } catch (e) {
      print('Sync Failed: $e');
      _updateStatus(SyncStatus.error);
    } finally {
      if (!(_syncCompleter?.isCompleted ?? true)) _syncCompleter?.complete();
      _syncCompleter = null;
    }
  }

  Future<void> _pushPendingOperations(String userId) async {
    final pendingOps = pendingOpsBox.values
        .map((e) => PendingOperation(
              id: e['id'] as String,
              collection: e['collection'] as String,
              documentId: e['documentId'] as String,
              type: OperationType.values[e['type'] as int],
              data: e['data'] as Map<String, dynamic>?,
              createdAt: DateTime.fromMillisecondsSinceEpoch(e['createdAt'] as int),
              retryCount: e['retryCount'] as int? ?? 0,
            ))
        .toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

    if (pendingOps.isEmpty) return;

    if (firestore == null) {
      for (final op in pendingOps) {
        if (mysqlService != null) {
          unawaited(_pushOperationToMySQL(op));
        }
        await _removePendingOperation(op.id);
      }
      return;
    }

    final batch = firestore!.batch();
    int operationCount = 0;
    final opsToRemove = <String>[];

    for (final op in pendingOps) {
      if (operationCount >= _batchLimit) break;
      if (op.retryCount >= _maxRetries) {
        opsToRemove.add(op.id);
        continue;
      }

      final docRef = firestore!
          .collection('users')
          .doc(userId)
          .collection(op.collection)
          .doc(op.documentId);

      switch (op.type) {
        case OperationType.create:
        case OperationType.update:
          batch.set(docRef, op.data!, SetOptions(merge: true));
          if (mysqlService != null) {
            unawaited(_pushOperationToMySQL(op));
          }
          break;
        case OperationType.delete:
          batch.delete(docRef);
          break;
      }

      operationCount++;
    }

    if (operationCount > 0) {
      try {
        await batch.commit();
        for (final op in pendingOps.take(operationCount)) {
          opsToRemove.add(op.id);
        }
      } catch (e) {
        for (final op in pendingOps.take(operationCount)) {
          _incrementRetry(op.id);
        }
      }

      for (final opId in opsToRemove) {
        await _removePendingOperation(opId);
      }
    }
  }

  Future<void> _pullRemoteChanges(String userId) async {
    if (firestore == null) return;
    final userDocRef = firestore!.collection('users').doc(userId);
    final lastSync = _lastSyncTime ?? DateTime.fromMillisecondsSinceEpoch(0);

    await _syncProductsCollection(userDocRef, lastSync);
    await _syncSalesCollection(userDocRef, lastSync);
    await _syncExpensesCollection(userDocRef, lastSync);
    await _syncCustomersCollection(userDocRef, lastSync);
    await _syncTransactionsCollection(userDocRef, lastSync);
    await _syncSuppliersCollection(userDocRef, lastSync);
    await _syncSupplierTransactionsCollection(userDocRef, lastSync);
  }

  Future<void> _syncProductsCollection(DocumentReference userDocRef, DateTime lastSync) async {
    final snapshot = await userDocRef
        .collection('products')
        .where('updatedAt', isGreaterThan: lastSync.millisecondsSinceEpoch)
        .get();

    for (final doc in snapshot.docs) {
      final data = doc.data();
      final localDoc = productBox.get(doc.id);
      
      if (localDoc == null) {
        final product = ProductTable(
          id: doc.id,
          name: data['name'] ?? '',
          category: data['category'] ?? '',
          buyPrice: (data['buyPrice'] ?? 0).toDouble(),
          sellPrice: (data['sellPrice'] ?? 0).toDouble(),
          stockQuantity: data['stockQuantity'] ?? 0,
          minStockAlert: data['minStockAlert'] ?? 0,
          userId: data['userId'] ?? '',
          createdAt: data['createdAt'] != null 
              ? (data['createdAt'] is Timestamp ? (data['createdAt'] as Timestamp).toDate() : DateTime.parse(data['createdAt']))
              : DateTime.now(),
          updatedAt: data['updatedAt'] != null
              ? (data['updatedAt'] is Timestamp ? (data['updatedAt'] as Timestamp).toDate() : DateTime.parse(data['updatedAt']))
              : null,
          isSynced: true,
          imageUrl: data['imageUrl'],
          barcode: data['barcode'],
        );
        await productBox.put(doc.id, product);
      } else {
        final remoteUpdatedAt = data['updatedAt'] != null
            ? (data['updatedAt'] is Timestamp ? (data['updatedAt'] as Timestamp).toDate() : DateTime.parse(data['updatedAt']))
            : DateTime.now();
        
        final localUpdatedAt = localDoc.updatedAt ?? localDoc.createdAt;
        
        if (remoteUpdatedAt.isAfter(localUpdatedAt)) {
          final updatedProduct = ProductTable(
            id: localDoc.id,
            name: data['name'] ?? localDoc.name,
            category: data['category'] ?? localDoc.category,
            buyPrice: (data['buyPrice'] ?? localDoc.buyPrice).toDouble(),
            sellPrice: (data['sellPrice'] ?? localDoc.sellPrice).toDouble(),
            stockQuantity: data['stockQuantity'] ?? localDoc.stockQuantity,
            minStockAlert: data['minStockAlert'] ?? localDoc.minStockAlert,
            userId: localDoc.userId,
            createdAt: localDoc.createdAt,
            updatedAt: remoteUpdatedAt,
            isSynced: true,
            imageUrl: data['imageUrl'] ?? localDoc.imageUrl,
            barcode: data['barcode'] ?? localDoc.barcode,
          );
          await productBox.put(doc.id, updatedProduct);
        }
      }
    }
  }

  Future<void> _syncSalesCollection(DocumentReference userDocRef, DateTime lastSync) async {
    final snapshot = await userDocRef
        .collection('sales')
        .where('updatedAt', isGreaterThan: lastSync.millisecondsSinceEpoch)
        .get();

    for (final doc in snapshot.docs) {
      final data = doc.data();
      final localDoc = saleBox.get(doc.id);
      
      if (localDoc == null) {
        final sale = SaleTable(
          id: doc.id,
          productId: data['productId'] ?? '',
          productName: data['productName'] ?? '',
          quantitySold: data['quantitySold'] ?? 0,
          salePrice: (data['salePrice'] ?? 0).toDouble(),
          totalAmount: (data['totalAmount'] ?? 0).toDouble(),
          totalProfit: (data['totalProfit'] ?? 0).toDouble(),
          date: data['date'] != null 
              ? (data['date'] is Timestamp ? (data['date'] as Timestamp).toDate() : DateTime.parse(data['date']))
              : DateTime.now(),
          userId: data['userId'] ?? '',
          updatedAt: data['updatedAt'] != null
              ? (data['updatedAt'] is Timestamp ? (data['updatedAt'] as Timestamp).toDate() : DateTime.parse(data['updatedAt']))
              : null,
          isSynced: true,
        );
        await saleBox.put(doc.id, sale);
      } else {
        final remoteUpdatedAt = data['updatedAt'] != null
            ? (data['updatedAt'] is Timestamp ? (data['updatedAt'] as Timestamp).toDate() : DateTime.parse(data['updatedAt']))
            : DateTime.fromMillisecondsSinceEpoch(0);
        
        final localUpdatedAt = localDoc.updatedAt ?? localDoc.date;
        
        if (remoteUpdatedAt.isAfter(localUpdatedAt)) {
          _markConflict('sales', doc.id, localDoc.toMap(), data);
        }
      }
    }
  }

  Future<void> _syncExpensesCollection(DocumentReference userDocRef, DateTime lastSync) async {
    final snapshot = await userDocRef
        .collection('expenses')
        .where('updatedAt', isGreaterThan: lastSync.millisecondsSinceEpoch)
        .get();

    for (final doc in snapshot.docs) {
      final data = doc.data();
      final localDoc = expenseBox.get(doc.id);
      
      if (localDoc == null) {
        final expense = ExpenseTable(
          id: doc.id,
          title: data['title'] ?? '',
          amount: (data['amount'] ?? 0).toDouble(),
          category: data['category'] ?? '',
          date: data['date'] != null ? DateTime.parse(data['date']) : DateTime.now(),
          userId: data['userId'] ?? '',
          isSynced: true,
        );
        await expenseBox.put(doc.id, expense);
      }
    }
  }

  Future<void> _syncCustomersCollection(DocumentReference userDocRef, DateTime lastSync) async {
    final snapshot = await userDocRef
        .collection('customers')
        .where('updatedAt', isGreaterThan: lastSync.millisecondsSinceEpoch)
        .get();

    for (final doc in snapshot.docs) {
      final data = doc.data();
      final localDoc = customerBox.get(doc.id);
      
      if (localDoc == null) {
        final customer = CustomerTable(
          id: doc.id,
          shopId: data['shopId'] ?? '',
          name: data['name'] ?? '',
          phone: data['phone'] ?? '',
          totalCredit: (data['totalCredit'] ?? 0).toDouble(),
          lastTransactionDate: data['lastTransactionDate'] != null 
              ? (data['lastTransactionDate'] is Timestamp ? (data['lastTransactionDate'] as Timestamp).toDate() : DateTime.parse(data['lastTransactionDate']))
              : DateTime.now(),
          createdAt: data['createdAt'] != null 
              ? (data['createdAt'] is Timestamp ? (data['createdAt'] as Timestamp).toDate() : DateTime.parse(data['createdAt']))
              : DateTime.now(),
          updatedAt: data['updatedAt'] != null
              ? (data['updatedAt'] is Timestamp ? (data['updatedAt'] as Timestamp).toDate() : DateTime.parse(data['updatedAt']))
              : null,
          isSynced: true,
          notes: data['notes'],
        );
        await customerBox.put(doc.id, customer);
      } else {
        final remoteUpdatedAt = data['updatedAt'] != null
            ? (data['updatedAt'] is Timestamp ? (data['updatedAt'] as Timestamp).toDate() : DateTime.parse(data['updatedAt']))
            : DateTime.fromMillisecondsSinceEpoch(0);
        
        final localUpdatedAt = localDoc.updatedAt ?? localDoc.createdAt;
        
        if (remoteUpdatedAt.isAfter(localUpdatedAt)) {
          final updatedCustomer = CustomerTable(
            id: localDoc.id,
            shopId: localDoc.shopId,
            name: data['name'] ?? localDoc.name,
            phone: data['phone'] ?? localDoc.phone,
            totalCredit: (data['totalCredit'] ?? localDoc.totalCredit).toDouble(),
            lastTransactionDate: data['lastTransactionDate'] != null 
                ? (data['lastTransactionDate'] is Timestamp ? (data['lastTransactionDate'] as Timestamp).toDate() : DateTime.parse(data['lastTransactionDate']))
                : localDoc.lastTransactionDate,
            createdAt: localDoc.createdAt,
            updatedAt: remoteUpdatedAt,
            isSynced: true,
            notes: data['notes'] ?? localDoc.notes,
          );
          await customerBox.put(doc.id, updatedCustomer);
        }
      }
    }
  }

  Future<void> _syncTransactionsCollection(DocumentReference userDocRef, DateTime lastSync) async {
    final snapshot = await userDocRef
        .collection('credit_transactions')
        .where('updatedAt', isGreaterThan: lastSync.millisecondsSinceEpoch)
        .get();

    for (final doc in snapshot.docs) {
      final data = doc.data();
      final localDoc = transactionBox.get(doc.id);

      if (localDoc == null) {
        final tx = CreditTransactionTable(
          id: doc.id,
          customerId: data['customerId'] ?? '',
          shopId: data['shopId'] ?? '',
          amount: (data['amount'] ?? 0).toDouble(),
          type: data['type'] ?? 'credit',
          description: data['description'],
          date: data['date'] != null 
              ? (data['date'] is Timestamp ? (data['date'] as Timestamp).toDate() : DateTime.parse(data['date']))
              : DateTime.now(),
          balanceAfter: (data['balanceAfter'] ?? 0).toDouble(),
          billId: data['billId'],
          updatedAt: data['updatedAt'] != null
              ? (data['updatedAt'] is Timestamp ? (data['updatedAt'] as Timestamp).toDate() : DateTime.parse(data['updatedAt']))
              : null,
          isSynced: true,
        );
        await transactionBox.put(doc.id, tx);
      }
    }
  }

  Future<void> _syncSuppliersCollection(DocumentReference userDocRef, DateTime lastSync) async {
    final snapshot = await userDocRef
        .collection('suppliers')
        .where('updatedAt', isGreaterThan: lastSync.millisecondsSinceEpoch)
        .get();

    for (final doc in snapshot.docs) {
      final data = doc.data();
      final localDoc = supplierBox.get(doc.id);

      if (localDoc == null) {
        final supplier = SupplierTable(
          id: doc.id,
          name: data['name'] ?? '',
          contactPerson: data['contactPerson'],
          phone: data['phone'] ?? '',
          address: data['address'],
          balance: (data['balance'] ?? 0).toDouble(),
          userId: data['userId'] ?? '',
          createdAt: data['createdAt'] != null 
              ? (data['createdAt'] is Timestamp ? (data['createdAt'] as Timestamp).toDate() : DateTime.parse(data['createdAt']))
              : DateTime.now(),
          email: data['email'],
          isSynced: true,
        );
        await supplierBox.put(doc.id, supplier);
      }
    }
  }

  Future<void> _syncSupplierTransactionsCollection(DocumentReference userDocRef, DateTime lastSync) async {
    final snapshot = await userDocRef
        .collection('supplier_transactions')
        .where('date', isGreaterThan: lastSync.millisecondsSinceEpoch)
        .get();

    for (final doc in snapshot.docs) {
      final data = doc.data();
      final localDoc = supplierTxBox.get(doc.id);

      if (localDoc == null) {
        final tx = SupplierTransactionTable(
          id: doc.id,
          supplierId: data['supplierId'] ?? '',
          type: SupplierTransactionType.values[data['type'] ?? 0],
          amount: (data['amount'] ?? 0).toDouble(),
          balanceAfter: (data['balanceAfter'] ?? 0).toDouble(),
          note: data['note'],
          date: data['date'] != null 
              ? (data['date'] is Timestamp ? (data['date'] as Timestamp).toDate() : DateTime.parse(data['date']))
              : DateTime.now(),
          userId: data['userId'] ?? '',
          isSynced: true,
        );
        await supplierTxBox.put(doc.id, tx);
      }
    }
  }

  void queueOperation(String collection, String documentId, OperationType type, Map<String, dynamic>? data) {
    final opId = DateTime.now().millisecondsSinceEpoch.toString();
    final op = {
      'id': opId,
      'collection': collection,
      'documentId': documentId,
      'type': type.index,
      'data': data,
      'createdAt': DateTime.now().millisecondsSinceEpoch,
      'retryCount': 0,
    };
    pendingOpsBox.put(opId, op);
  }

  void _incrementRetry(String opId) {
    final index = pendingOpsBox.values.toList().indexWhere((e) => e['id'] == opId);
    if (index >= 0) {
      final op = pendingOpsBox.getAt(index);
      pendingOpsBox.putAt(index, {
        ...op,
        'retryCount': (op['retryCount'] as int? ?? 0) + 1,
      });
    }
  }

  Future<void> _removePendingOperation(String opId) async {
    final index = pendingOpsBox.values.toList().indexWhere((e) => e['id'] == opId);
    if (index >= 0) {
      await pendingOpsBox.deleteAt(index);
    } else {
      await pendingOpsBox.delete(opId);
    }
  }

  void _markConflict(String collection, String docId, Map<String, dynamic> localData, Map<String, dynamic> remoteData) {
    final conflictId = '${collection}_${docId}_${DateTime.now().millisecondsSinceEpoch}';
    final conflict = {
      'id': conflictId,
      'type': 'conflict',
      'collection': collection,
      'documentId': docId,
      'localData': localData,
      'remoteData': remoteData,
      'createdAt': DateTime.now().millisecondsSinceEpoch,
      'status': 'pending',
    };
    pendingOpsBox.put(conflictId, conflict);
  }

  void _updateStatus(SyncStatus status) {
    _status = status;
    _statusController.add(status);
  }

  int get pendingCount {
    return pendingOpsBox.values.where((e) => e is Map && e['type'] != 'conflict').length;
  }

  int get conflictCount {
    return pendingOpsBox.values.where((e) => e is Map && e['type'] == 'conflict').length;
  }

  Map<String, int> getPendingStats() {
    final stats = <String, int>{};
    for (var op in pendingOpsBox.values) {
      if (op is Map && op['type'] != 'conflict') {
        final collection = op['collection'] as String? ?? 'unknown';
        stats[collection] = (stats[collection] ?? 0) + 1;
      }
    }
    return stats;
  }

  List<Map<String, dynamic>> getPendingOperations() {
    return pendingOpsBox.values
        .where((e) => e is Map && e['type'] != 'conflict')
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
  }

  Future<void> clearPendingQueue() async {
    final keys = pendingOpsBox.keys.toList();
    for (var key in keys) {
      final op = pendingOpsBox.get(key);
      // Only clear operations, not metadata like 'lastSyncTime'
      if (op is Map && op.containsKey('type')) {
        await pendingOpsBox.delete(key);
      }
    }
    _updateStatus(SyncStatus.idle);
  }

  Future<void> atomicStockUpdate(String userId, String productId, int quantityChange) async {
    if (firestore == null) return;
    try {
      await firestore!.runTransaction((transaction) async {
        final productRef = firestore!
            .collection('users')
            .doc(userId)
            .collection('products')
            .doc(productId);
        
        final productDoc = await transaction.get(productRef);
        if (!productDoc.exists) return;

        final currentStock = productDoc.data()?['stockQuantity'] ?? 0;
        final newStock = currentStock + quantityChange;
        
        if (newStock < 0) {
          throw Exception('Insufficient stock');
        }

        transaction.update(productRef, {
          'stockQuantity': newStock,
          'updatedAt': DateTime.now().toUtc().millisecondsSinceEpoch,
        });
      });
    } catch (e) {
      queueOperation('products', productId, OperationType.update, {
        'stockQuantity': quantityChange,
        'isAtomicUpdate': true,
      });
    }
  }

  Future<void> _pushOperationToMySQL(PendingOperation op) async {
    if (mysqlService == null || op.data == null) return;

    try {
      final data = Map<String, dynamic>.from(op.data!);
      
      switch (op.collection) {
        case 'products':
          await mysqlService!.upsertProduct(data);
          break;
        case 'sales':
          await mysqlService!.insertSale(data);
          break;
        case 'expenses':
          await mysqlService!.insertExpense(data);
          break;
        case 'customers':
          await mysqlService!.upsertCustomer(data);
          break;
        case 'suppliers':
          await mysqlService!.upsertSupplier(data);
          break;
      }
    } catch (e) {
      print('MySQL Sync Failed for ${op.collection}: $e');
    }
  }

  void dispose() {
    _statusController.close();
  }
}
