// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'customer_table.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CustomerTableAdapter extends TypeAdapter<CustomerTable> {
  @override
  final int typeId = 5;

  @override
  CustomerTable read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CustomerTable(
      id: fields[0] as String,
      shopId: fields[1] as String,
      name: fields[2] as String,
      phone: fields[3] as String,
      totalCredit: fields[4] as double,
      lastTransactionDate: fields[5] as DateTime,
      createdAt: fields[6] as DateTime,
      isSynced: fields[7] as bool,
      notes: fields[8] as String?,
      updatedAt: fields[9] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, CustomerTable obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.shopId)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.phone)
      ..writeByte(4)
      ..write(obj.totalCredit)
      ..writeByte(5)
      ..write(obj.lastTransactionDate)
      ..writeByte(6)
      ..write(obj.createdAt)
      ..writeByte(7)
      ..write(obj.isSynced)
      ..writeByte(8)
      ..write(obj.notes)
      ..writeByte(9)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CustomerTableAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
