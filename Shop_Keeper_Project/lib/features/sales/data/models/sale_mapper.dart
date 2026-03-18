import '../../domain/entities/sale_entity.dart';
import 'sale_model.dart';

class SaleMapper {
  static SaleModel toModel(SaleEntity entity) {
    return SaleModel(
      id: entity.id,
      productId: entity.productId,
      productName: entity.productName,
      quantitySold: entity.quantitySold,
      salePrice: entity.salePrice,
      totalAmount: entity.totalAmount,
      totalProfit: entity.totalProfit,
      date: entity.date,
      userId: entity.userId,
    );
  }

  static SaleEntity toEntity(SaleModel model) {
    return SaleEntity(
      id: model.id,
      productId: model.productId,
      productName: model.productName,
      quantitySold: model.quantitySold,
      salePrice: model.salePrice,
      totalAmount: model.totalAmount,
      totalProfit: model.totalProfit,
      date: model.date,
      userId: model.userId,
    );
  }
}
