import 'package:hive/hive.dart';

part 'expense_table.g.dart';

@HiveType(typeId: 2)
class ExpenseTable extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final double amount;

  @HiveField(3)
  final String category;

  @HiveField(4)
  final DateTime date;

  @HiveField(5)
  final String userId;

  @HiveField(6)
  final bool isSynced;

  @HiveField(7)
  final DateTime? updatedAt;

  ExpenseTable({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
    required this.userId,
    this.updatedAt,
    this.isSynced = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'category': category,
      'date': date.toIso8601String(),
      'userId': userId,
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}
