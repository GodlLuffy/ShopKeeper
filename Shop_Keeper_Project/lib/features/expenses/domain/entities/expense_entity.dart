import 'package:equatable/equatable.dart';

class ExpenseEntity extends Equatable {
  final String id;
  final String title;
  final double amount;
  final String category;
  final DateTime date;
  final String userId;

  const ExpenseEntity({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
    required this.userId,
  });

  @override
  List<Object?> get props => [id, title, amount, category, date, userId];
}
