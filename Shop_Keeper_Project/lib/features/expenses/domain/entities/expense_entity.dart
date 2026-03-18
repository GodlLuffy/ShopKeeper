import 'package:equatable/equatable.dart';
import 'package:dartz/dartz.dart';
import 'package:shop_keeper_project/core/error/failures.dart';

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

  Either<Failure, bool> validate() {
    if (title.isEmpty) return const Left(ValidationFailure('Expense title cannot be empty'));
    if (amount <= 0) return const Left(ValidationFailure('Expense amount must be greater than 0'));
    if (userId.isEmpty || userId == 'unknown') return const Left(ValidationFailure('Invalid User ID'));
    return const Right(true);
  }
}
