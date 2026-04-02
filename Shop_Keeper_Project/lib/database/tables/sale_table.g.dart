// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sale_table.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SaleTableAdapter extends TypeAdapter<SaleTable> {
  @override
  final int typeId = 1;

  @override
  SaleTable read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SaleTable(
      id: fields[0] as String,
      productId: fields[1] as String,
      productName: fields[2] as String,
      quantitySold: fields[3] as int,
      salePrice: fields[4] as double,
      totalAmount: fields[5] as double,
      totalProfit: fields[6] as double,
      date: fields[7] as DateTime,
      userId: fields[8] as String,
      updatedAt: fields[10] as DateTime?,
      isSynced: fields[9] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, SaleTable obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.productId)
      ..writeByte(2)
      ..write(obj.productName)
      ..writeByte(3)
      ..write(obj.quantitySold)
      ..writeByte(4)
      ..write(obj.salePrice)
      ..writeByte(5)
      ..write(obj.totalAmount)
      ..writeByte(6)
      ..write(obj.totalProfit)
      ..writeByte(7)
      ..write(obj.date)
      ..writeByte(8)
      ..write(obj.userId)
      ..writeByte(9)
      ..write(obj.isSynced)
      ..writeByte(10)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SaleTableAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
