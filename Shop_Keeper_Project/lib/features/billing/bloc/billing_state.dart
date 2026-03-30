import 'package:equatable/equatable.dart';
import '../model/cart_item.dart';
import '../model/invoice.dart';
import '../model/billing_summary.dart';

abstract class BillingState extends Equatable {
  const BillingState();

  @override
  List<Object?> get props => [];
}

class BillingInitial extends BillingState {}

class BillingUpdated extends BillingState {
  final List<CartItem> items;
  final double totalAmount;
  final BillingSummary summary;

  const BillingUpdated(this.items, this.totalAmount, this.summary);

  @override
  List<Object?> get props => [items, totalAmount, summary];
}

class BillingLoading extends BillingState {}

class BillGenerated extends BillingState {
  final Invoice invoice;
  const BillGenerated(this.invoice);

  @override
  List<Object?> get props => [invoice];
}

class BillingError extends BillingState {
  final String message;
  const BillingError(this.message);

  @override
  List<Object?> get props => [message];
}
