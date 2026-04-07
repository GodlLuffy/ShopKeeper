import '../../domain/entities/product_entity.dart';
import 'product_model.dart';

class ProductMapper {
  static ProductModel toModel(ProductEntity entity) {
    return ProductModel(
      id: entity.id,
      name: entity.name,
      category: entity.category,
      buyPrice: entity.buyPrice,
      sellPrice: entity.sellPrice,
      stockQuantity: entity.stockQuantity,
      minStockAlert: entity.minStockAlert,
      userId: entity.userId,
      createdAt: entity.createdAt,
      imageUrl: entity.imageUrl,
      barcode: entity.barcode,
    );
  }

  static ProductEntity toEntity(ProductModel model) {
    return ProductEntity(
      id: model.id,
      name: model.name,
      category: model.category,
      buyPrice: model.buyPrice,
      sellPrice: model.sellPrice,
      stockQuantity: model.stockQuantity,
      minStockAlert: model.minStockAlert,
      userId: model.userId,
      createdAt: model.createdAt,
      imageUrl: model.imageUrl,
      barcode: model.barcode,
    );
  }
}
