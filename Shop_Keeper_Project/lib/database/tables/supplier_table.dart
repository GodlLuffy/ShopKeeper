import 'package:hive/hive.dart';

part 'supplier_table.g.dart';

@HiveType(typeId: 7)
class SupplierTable extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String? contactPerson;

  @HiveField(3)
  final String phone;

  @HiveField(4)
  final String? address;

  @HiveField(5)
  late double balance; // Debt owed to supplier

  @HiveField(6)
  final String userId;

  @HiveField(7)
  final DateTime createdAt;

  @HiveField(8)
  final bool isSynced;

  @HiveField(9)
  final String? email;

  SupplierTable({
    required this.id,
    required this.name,
    this.contactPerson,
    required this.phone,
    this.address,
    this.balance = 0.0,
    required this.userId,
    required this.createdAt,
    this.isSynced = false,
    this.email,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'contactPerson': contactPerson,
      'phone': phone,
      'address': address,
      'balance': balance,
      'userId': userId,
      'createdAt': createdAt.toIso8601String(),
      'email': email,
    };
  }
}
