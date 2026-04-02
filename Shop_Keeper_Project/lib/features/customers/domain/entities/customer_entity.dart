import 'package:hive/hive.dart';
import 'package:equatable/equatable.dart';

part 'customer_entity.g.dart';

@HiveType(typeId: 4)
class CustomerEntity extends Equatable {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String shopId;

  @HiveField(2)
  final String name;

  @HiveField(3)
  final String phone;

  @HiveField(4)
  final double totalCredit;

  @HiveField(5)
  final DateTime lastTransactionDate;

  @HiveField(6)
  final DateTime createdAt;

  @HiveField(7)
  final String? notes;

  @HiveField(8)
  final DateTime? updatedAt;

  @HiveField(9)
  final bool isSynced;

  const CustomerEntity({
    required this.id,
    required this.shopId,
    required this.name,
    required this.phone,
    this.totalCredit = 0.0,
    required this.lastTransactionDate,
    required this.createdAt,
    this.updatedAt,
    this.isSynced = false,
    this.notes,
  });

  CustomerEntity copyWith({
    String? id,
    String? shopId,
    String? name,
    String? phone,
    double? totalCredit,
    DateTime? lastTransactionDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isSynced,
    String? notes,
  }) {
    return CustomerEntity(
      id: id ?? this.id,
      shopId: shopId ?? this.shopId,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      totalCredit: totalCredit ?? this.totalCredit,
      lastTransactionDate: lastTransactionDate ?? this.lastTransactionDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isSynced: isSynced ?? this.isSynced,
      notes: notes ?? this.notes,
    );
  }

  bool get hasOutstandingCredit => totalCredit > 0;
  bool get isSettled => totalCredit <= 0;

  @override
  List<Object?> get props => [id, shopId, name, phone, totalCredit, lastTransactionDate, createdAt, updatedAt, isSynced, notes];
}
