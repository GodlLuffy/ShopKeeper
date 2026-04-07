// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'supplier_transaction_table.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SupplierTransactionTableAdapter
    extends TypeAdapter<SupplierTransactionTable> {
  @override
  final int typeId = 9;

  @override
  SupplierTransactionTable read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SupplierTransactionTable(
      id: fields[0] as String,
      supplierId: fields[1] as String,
      type: fields[2] as SupplierTransactionType,
      amount: fields[3] as double,
      balanceAfter: fields[4] as double,
      note: fields[5] as String?,
      date: fields[6] as DateTime,
      userId: fields[7] as String,
      isSynced: fields[8] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, SupplierTransactionTable obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.supplierId)
      ..writeByte(2)
      ..write(obj.type)
      ..writeByte(3)
      ..write(obj.amount)
      ..writeByte(4)
      ..write(obj.balanceAfter)
      ..writeByte(5)
      ..write(obj.note)
      ..writeByte(6)
      ..write(obj.date)
      ..writeByte(7)
      ..write(obj.userId)
      ..writeByte(8)
      ..write(obj.isSynced);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SupplierTransactionTableAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SupplierTransactionTypeAdapter
    extends TypeAdapter<SupplierTransactionType> {
  @override
  final int typeId = 8;

  @override
  SupplierTransactionType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return SupplierTransactionType.purchase;
      case 1:
        return SupplierTransactionType.payment;
      default:
        return SupplierTransactionType.purchase;
    }
  }

  @override
  void write(BinaryWriter writer, SupplierTransactionType obj) {
    switch (obj) {
      case SupplierTransactionType.purchase:
        writer.writeByte(0);
        break;
      case SupplierTransactionType.payment:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SupplierTransactionTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
