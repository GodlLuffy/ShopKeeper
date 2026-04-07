import 'package:equatable/equatable.dart';

class Supplier extends Equatable {
  final String id;
  final String name;
  final String? contactPerson;
  final String phone;
  final String? address;
  final double balance;
  final String userId;
  final DateTime createdAt;
  final String? email;

  const Supplier({
    required this.id,
    required this.name,
    this.contactPerson,
    required this.phone,
    this.address,
    this.balance = 0.0,
    required this.userId,
    required this.createdAt,
    this.email,
  });

  @override
  List<Object?> get props => [id, name, contactPerson, phone, address, balance, userId, createdAt, email];
}

enum SupplierTransactionType { purchase, payment }

class SupplierTransaction extends Equatable {
  final String id;
  final String supplierId;
  final SupplierTransactionType type;
  final double amount;
  final double balanceAfter;
  final String? note;
  final DateTime date;
  final String userId;

  const SupplierTransaction({
    required this.id,
    required this.supplierId,
    required this.type,
    required this.amount,
    required this.balanceAfter,
    this.note,
    required this.date,
    required this.userId,
  });

  @override
  List<Object?> get props => [id, supplierId, type, amount, balanceAfter, note, date, userId];
}
