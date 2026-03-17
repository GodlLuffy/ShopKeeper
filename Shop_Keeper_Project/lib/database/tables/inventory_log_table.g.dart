// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inventory_log_table.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class InventoryLogTableAdapter extends TypeAdapter<InventoryLogTable> {
  @override
  final int typeId = 3;

  @override
  InventoryLogTable read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return InventoryLogTable(
      id: fields[0] as String,
      productId: fields[1] as String,
      productName: fields[2] as String,
      action: fields[3] as String,
      quantity: fields[4] as int,
      previousStock: fields[5] as int,
      newStock: fields[6] as int,
      timestamp: fields[7] as DateTime,
      userId: fields[8] as String,
      isSynced: fields[9] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, InventoryLogTable obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.productId)
      ..writeByte(2)
      ..write(obj.productName)
      ..writeByte(3)
      ..write(obj.action)
      ..writeByte(4)
      ..write(obj.quantity)
      ..writeByte(5)
      ..write(obj.previousStock)
      ..writeByte(6)
      ..write(obj.newStock)
      ..writeByte(7)
      ..write(obj.timestamp)
      ..writeByte(8)
      ..write(obj.userId)
      ..writeByte(9)
      ..write(obj.isSynced);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InventoryLogTableAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
