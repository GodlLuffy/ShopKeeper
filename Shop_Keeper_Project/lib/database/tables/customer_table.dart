import 'package:hive/hive.dart';

part 'customer_table.g.dart';

@HiveType(typeId: 5)
class CustomerTable extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String shopId;

  @HiveField(2)
  final String name;

  @HiveField(3)
  final String phone;

  @HiveField(4)
  double totalCredit;

  @HiveField(5)
  DateTime lastTransactionDate;

  @HiveField(6)
  final DateTime createdAt;

  @HiveField(7)
  final bool isSynced;

  @HiveField(8)
  final String? notes;

  CustomerTable({
    required this.id,
    required this.shopId,
    required this.name,
    required this.phone,
    this.totalCredit = 0.0,
    required this.lastTransactionDate,
    required this.createdAt,
    this.isSynced = false,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'shopId': shopId,
      'name': name,
      'phone': phone,
      'totalCredit': totalCredit,
      'lastTransactionDate': lastTransactionDate.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'notes': notes,
    };
  }
}
