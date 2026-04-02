// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'credit_transaction_table.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CreditTransactionTableAdapter
    extends TypeAdapter<CreditTransactionTable> {
  @override
  final int typeId = 6;

  @override
  CreditTransactionTable read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CreditTransactionTable(
      id: fields[0] as String,
      customerId: fields[1] as String,
      shopId: fields[2] as String,
      amount: fields[3] as double,
      type: fields[4] as String,
      description: fields[5] as String?,
      date: fields[6] as DateTime,
      balanceAfter: fields[7] as double,
      isSynced: fields[8] as bool,
      billId: fields[9] as String?,
      updatedAt: fields[10] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, CreditTransactionTable obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.customerId)
      ..writeByte(2)
      ..write(obj.shopId)
      ..writeByte(3)
      ..write(obj.amount)
      ..writeByte(4)
      ..write(obj.type)
      ..writeByte(5)
      ..write(obj.description)
      ..writeByte(6)
      ..write(obj.date)
      ..writeByte(7)
      ..write(obj.balanceAfter)
      ..writeByte(8)
      ..write(obj.isSynced)
      ..writeByte(9)
      ..write(obj.billId)
      ..writeByte(10)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CreditTransactionTableAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
