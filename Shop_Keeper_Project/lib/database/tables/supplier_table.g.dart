// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'supplier_table.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SupplierTableAdapter extends TypeAdapter<SupplierTable> {
  @override
  final int typeId = 7;

  @override
  SupplierTable read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SupplierTable(
      id: fields[0] as String,
      name: fields[1] as String,
      contactPerson: fields[2] as String?,
      phone: fields[3] as String,
      address: fields[4] as String?,
      balance: fields[5] as double,
      userId: fields[6] as String,
      createdAt: fields[7] as DateTime,
      isSynced: fields[8] as bool,
      email: fields[9] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, SupplierTable obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.contactPerson)
      ..writeByte(3)
      ..write(obj.phone)
      ..writeByte(4)
      ..write(obj.address)
      ..writeByte(5)
      ..write(obj.balance)
      ..writeByte(6)
      ..write(obj.userId)
      ..writeByte(7)
      ..write(obj.createdAt)
      ..writeByte(8)
      ..write(obj.isSynced)
      ..writeByte(9)
      ..write(obj.email);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SupplierTableAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
