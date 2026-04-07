// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expense_table.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ExpenseTableAdapter extends TypeAdapter<ExpenseTable> {
  @override
  final int typeId = 2;

  @override
  ExpenseTable read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ExpenseTable(
      id: fields[0] as String,
      title: fields[1] as String,
      amount: fields[2] as double,
      category: fields[3] as String,
      date: fields[4] as DateTime,
      userId: fields[5] as String,
      updatedAt: fields[7] as DateTime?,
      isSynced: fields[6] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, ExpenseTable obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.amount)
      ..writeByte(3)
      ..write(obj.category)
      ..writeByte(4)
      ..write(obj.date)
      ..writeByte(5)
      ..write(obj.userId)
      ..writeByte(6)
      ..write(obj.isSynced)
      ..writeByte(7)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExpenseTableAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
