import 'package:hive/hive.dart';

part 'credit_transaction_table.g.dart';

@HiveType(typeId: 6)
class CreditTransactionTable extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String customerId;

  @HiveField(2)
  final String shopId;

  @HiveField(3)
  final double amount;

  /// 'credit' for giving credit, 'payment' for receiving payment
  @HiveField(4)
  final String type;

  @HiveField(5)
  final String? description;

  @HiveField(6)
  final DateTime date;

  @HiveField(7)
  final double balanceAfter;

  @HiveField(8)
  final bool isSynced;

  @HiveField(9)
  final String? billId;

  @HiveField(10)
  final DateTime? updatedAt;

  CreditTransactionTable({
    required this.id,
    required this.customerId,
    required this.shopId,
    required this.amount,
    required this.type,
    this.description,
    required this.date,
    required this.balanceAfter,
    this.isSynced = false,
    this.billId,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customerId': customerId,
      'shopId': shopId,
      'amount': amount,
      'type': type,
      'description': description,
      'date': date.toIso8601String(),
      'balanceAfter': balanceAfter,
      'billId': billId,
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}
