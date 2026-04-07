import 'package:equatable/equatable.dart';
import 'package:shop_keeper_project/features/inventory/domain/entities/product_entity.dart';
import '../model/billing_summary.dart';

abstract class BillingEvent extends Equatable {
  const BillingEvent();

  @override
  List<Object?> get props => [];
}

class AddToCart extends BillingEvent {
  final ProductEntity product;
  const AddToCart(this.product);

  @override
  List<Object?> get props => [product];
}

class RemoveFromCart extends BillingEvent {
  final ProductEntity product;
  const RemoveFromCart(this.product);

  @override
  List<Object?> get props => [product];
}

class UpdateCartQuantity extends BillingEvent {
  final ProductEntity product;
  final int quantity;
  const UpdateCartQuantity(this.product, this.quantity);

  @override
  List<Object?> get props => [product, quantity];
}

class ApplyDiscount extends BillingEvent {
  final DiscountConfig discount;
  const ApplyDiscount(this.discount);

  @override
  List<Object?> get props => [discount];
}

class UpdateTaxConfig extends BillingEvent {
  final TaxConfig tax;
  const UpdateTaxConfig(this.tax);

  @override
  List<Object?> get props => [tax];
}

class GenerateBill extends BillingEvent {
  final String? customerName;
  final String? customerId;
  final bool isCreditSale;
  const GenerateBill({this.customerName, this.customerId, this.isCreditSale = false});

  @override
  List<Object?> get props => [customerName, customerId, isCreditSale];
}

class ClearCart extends BillingEvent {}
