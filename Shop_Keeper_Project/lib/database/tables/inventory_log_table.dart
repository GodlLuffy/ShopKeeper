import 'package:hive/hive.dart';

part 'inventory_log_table.g.dart';

@HiveType(typeId: 3)
class InventoryLogTable extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String productId;

  @HiveField(2)
  final String productName;

  @HiveField(3)
  final String action; // ADD, SALE, ADJUST

  @HiveField(4)
  final int quantity;

  @HiveField(5)
  final int previousStock;

  @HiveField(6)
  final int newStock;

  @HiveField(7)
  final DateTime timestamp;

  @HiveField(8)
  final String userId;

  @HiveField(9)
  final bool isSynced;

  InventoryLogTable({
    required this.id,
    required this.productId,
    required this.productName,
    required this.action,
    required this.quantity,
    required this.previousStock,
    required this.newStock,
    required this.timestamp,
    required this.userId,
    this.isSynced = false,
  });
}
