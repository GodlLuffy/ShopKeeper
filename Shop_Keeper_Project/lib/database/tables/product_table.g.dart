// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_table.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ProductTableAdapter extends TypeAdapter<ProductTable> {
  @override
  final int typeId = 0;

  @override
  ProductTable read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ProductTable(
      id: fields[0] as String,
      name: fields[1] as String,
      category: fields[2] as String,
      buyPrice: fields[3] as double,
      sellPrice: fields[4] as double,
      stockQuantity: fields[5] as int,
      minStockAlert: fields[6] as int,
      userId: fields[7] as String,
      createdAt: fields[8] as DateTime,
      updatedAt: fields[12] as DateTime?,
      isSynced: fields[9] as bool,
      imageUrl: fields[10] as String?,
      barcode: fields[11] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ProductTable obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.category)
      ..writeByte(3)
      ..write(obj.buyPrice)
      ..writeByte(4)
      ..write(obj.sellPrice)
      ..writeByte(5)
      ..write(obj.stockQuantity)
      ..writeByte(6)
      ..write(obj.minStockAlert)
      ..writeByte(7)
      ..write(obj.userId)
      ..writeByte(8)
      ..write(obj.createdAt)
      ..writeByte(9)
      ..write(obj.isSynced)
      ..writeByte(10)
      ..write(obj.imageUrl)
      ..writeByte(11)
      ..write(obj.barcode)
      ..writeByte(12)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductTableAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
