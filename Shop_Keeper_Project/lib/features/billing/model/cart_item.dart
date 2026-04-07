import 'package:shop_keeper_project/features/inventory/domain/entities/product_entity.dart';

class CartItem {
  final ProductEntity product;
  int quantity;

  CartItem({
    required this.product,
    this.quantity = 1,
  });

  double get total => product.sellPrice * quantity;
}
