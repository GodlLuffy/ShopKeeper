import 'package:hive/hive.dart';

part 'supplier_transaction_table.g.dart';

@HiveType(typeId: 8)
enum SupplierTransactionType {
  @HiveField(0)
  purchase, // Product bought from supplier (Increases balance/debt)
  
  @HiveField(1)
  payment // Cash paid to supplier (Decreases balance/debt)
}

@HiveType(typeId: 9)
class SupplierTransactionTable extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String supplierId;

  @HiveField(2)
  final SupplierTransactionType type;

  @HiveField(3)
  final double amount;

  @HiveField(4)
  final double balanceAfter;

  @HiveField(5)
  final String? note;

  @HiveField(6)
  final DateTime date;

  @HiveField(7)
  final String userId;

  @HiveField(8)
  final bool isSynced;

  SupplierTransactionTable({
    required this.id,
    required this.supplierId,
    required this.type,
    required this.amount,
    required this.balanceAfter,
    this.note,
    required this.date,
    required this.userId,
    this.isSynced = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'supplierId': supplierId,
      'type': type.index, // Store as index for Firestore
      'amount': amount,
      'balanceAfter': balanceAfter,
      'note': note,
      'date': date.toIso8601String(),
      'userId': userId,
    };
  }
}
