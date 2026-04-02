import 'package:equatable/equatable.dart';

enum TransactionType { credit, payment }

class CreditTransactionEntity extends Equatable {
  final String id;
  final String customerId;
  final String shopId;
  final double amount;
  final TransactionType type;
  final String? description;
  final DateTime date;
  final double balanceAfter;
  final String? billId;
  final DateTime? updatedAt;
  final bool isSynced;

  const CreditTransactionEntity({
    required this.id,
    required this.customerId,
    required this.shopId,
    required this.amount,
    required this.type,
    this.description,
    required this.date,
    required this.balanceAfter,
    this.billId,
    this.updatedAt,
    this.isSynced = false,
  });

  CreditTransactionEntity copyWith({
    String? id,
    String? customerId,
    String? shopId,
    double? amount,
    TransactionType? type,
    String? description,
    DateTime? date,
    double? balanceAfter,
    String? billId,
    DateTime? updatedAt,
    bool? isSynced,
  }) {
    return CreditTransactionEntity(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      shopId: shopId ?? this.shopId,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      description: description ?? this.description,
      date: date ?? this.date,
      balanceAfter: balanceAfter ?? this.balanceAfter,
      billId: billId ?? this.billId,
      updatedAt: updatedAt ?? this.updatedAt,
      isSynced: isSynced ?? this.isSynced,
    );
  }

  bool get isCredit => type == TransactionType.credit;
  bool get isPayment => type == TransactionType.payment;

  @override
  List<Object?> get props => [id, customerId, shopId, amount, type, description, date, balanceAfter, billId, updatedAt, isSynced];
}
