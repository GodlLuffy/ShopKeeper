import '../../domain/entities/expense_entity.dart';
import 'expense_model.dart';

class ExpenseMapper {
  static ExpenseModel toModel(ExpenseEntity entity) {
    return ExpenseModel(
      id: entity.id,
      title: entity.title,
      amount: entity.amount,
      category: entity.category,
      date: entity.date,
      userId: entity.userId,
    );
  }

  static ExpenseEntity toEntity(ExpenseModel model) {
    return ExpenseEntity(
      id: model.id,
      title: model.title,
      amount: model.amount,
      category: model.category,
      date: model.date,
      userId: model.userId,
    );
  }
}
