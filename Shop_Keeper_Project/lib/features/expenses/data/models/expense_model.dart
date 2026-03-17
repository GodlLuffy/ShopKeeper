import 'package:shop_keeper_project/features/expenses/domain/entities/expense_entity.dart';
import 'package:shop_keeper_project/database/tables/expense_table.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ExpenseModel extends ExpenseEntity {
  const ExpenseModel({
    required super.id,
    required super.title,
    required super.amount,
    required super.category,
    required super.date,
    required super.userId,
  });

  factory ExpenseModel.fromTable(ExpenseTable table) {
    return ExpenseModel(
      id: table.id,
      title: table.title,
      amount: table.amount,
      category: table.category,
      date: table.date,
      userId: table.userId,
    );
  }

  ExpenseTable toTable({bool isSynced = false}) {
    return ExpenseTable(
      id: id,
      title: title,
      amount: amount,
      category: category,
      date: date,
      userId: userId,
      isSynced: isSynced,
    );
  }

  factory ExpenseModel.fromMap(Map<String, dynamic> map, String id) {
    return ExpenseModel(
      id: id,
      title: map['title'] ?? '',
      amount: (map['amount'] ?? 0).toDouble(),
      category: map['category'] ?? '',
      date: (map['date'] as Timestamp).toDate(),
      userId: map['userId'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'amount': amount,
      'category': category,
      'date': date,
      'userId': userId,
    };
  }
}
