import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../model/cart_item.dart';
import '../model/invoice.dart';
import '../model/billing_summary.dart';
import 'billing_event.dart';
import 'billing_state.dart';
import 'package:shop_keeper_project/features/sales/domain/usecases/add_sale.dart';
import 'package:shop_keeper_project/features/inventory/domain/usecases/update_stock.dart';
import 'package:shop_keeper_project/features/sales/domain/entities/sale_entity.dart';
import 'package:shop_keeper_project/features/customers/domain/usecases/add_credit.dart';

class BillingBloc extends Bloc<BillingEvent, BillingState> {
  final AddSale addSale;
  final UpdateStock updateStock;
  final AddCreditTransaction addCredit;
  final _uuid = const Uuid();
  final List<CartItem> _cart = [];
  DiscountConfig _discount = const DiscountConfig();
  TaxConfig _tax = const TaxConfig();

  BillingBloc({
    required this.addSale, 
    required this.updateStock,
    required this.addCredit,
  }) : super(BillingInitial()) {
    on<AddToCart>(_onAddToCart);
    on<RemoveFromCart>(_onRemoveFromCart);
    on<UpdateCartQuantity>(_onUpdateCartQuantity);
    on<ApplyDiscount>(_onApplyDiscount);
    on<UpdateTaxConfig>(_onUpdateTaxConfig);
    on<GenerateBill>(_onGenerateBill);
    on<ClearCart>(_onClearCart);
  }

  void _onAddToCart(AddToCart event, Emitter<BillingState> emit) {
    final index = _cart.indexWhere((item) => item.product.id == event.product.id);
    if (index >= 0) {
      _cart[index].quantity += 1;
    } else {
      _cart.add(CartItem(product: event.product));
    }
    _emitUpdatedState(emit);
  }

  void _onRemoveFromCart(RemoveFromCart event, Emitter<BillingState> emit) {
    _cart.removeWhere((item) => item.product.id == event.product.id);
    _emitUpdatedState(emit);
  }

  void _onUpdateCartQuantity(UpdateCartQuantity event, Emitter<BillingState> emit) {
    final index = _cart.indexWhere((item) => item.product.id == event.product.id);
    if (index >= 0) {
      if (event.quantity <= 0) {
        _cart.removeAt(index);
      } else {
        _cart[index].quantity = event.quantity;
      }
    }
    _emitUpdatedState(emit);
  }

  void _onApplyDiscount(ApplyDiscount event, Emitter<BillingState> emit) {
    _discount = event.discount;
    _emitUpdatedState(emit);
  }

  void _onUpdateTaxConfig(UpdateTaxConfig event, Emitter<BillingState> emit) {
    _tax = event.tax;
    _emitUpdatedState(emit);
  }

  void _onClearCart(ClearCart event, Emitter<BillingState> emit) {
    _cart.clear();
    _discount = const DiscountConfig();
    emit(BillingInitial());
  }

  Future<void> _onGenerateBill(GenerateBill event, Emitter<BillingState> emit) async {
    if (_cart.isEmpty) return;
    
    emit(BillingLoading());
    
    final userId = FirebaseAuth.instance.currentUser?.uid ?? 'unknown';
    final now = DateTime.now();
    final summary = _buildSummary();
    
    // Calculate discount factor to distribute global discount across individual items
    // This ensure Sales History totals match the actual Invoice total
    final discountFactor = summary.subtotal > 0 ? (summary.afterDiscount / summary.subtotal) : 1.0;
    
    bool hasError = false;

    // Process each cart item
    for (var item in _cart) {
      final saleId = _uuid.v4();
      
      // Calculate net values for this specific item after global discount
      final netItemTotal = item.total * discountFactor;
      final itemUnitBuyPrice = item.product.buyPrice;
      final netItemProfit = netItemTotal - (itemUnitBuyPrice * item.quantity);
      
      final saleEntity = SaleEntity(
        id: saleId,
        productId: item.product.id,
        productName: item.product.name,
        quantitySold: item.quantity,
        salePrice: item.product.sellPrice, // Original sell price
        totalAmount: netItemTotal,        // Net revenue from this item
        totalProfit: netItemProfit,       // Net profit from this item
        date: now,
        userId: userId,
      );

      // Record the sale
      final saleResult = await addSale(saleEntity);
      if (saleResult.isLeft()) {
        hasError = true;
        break;
      }

      // Update stock
      final stockResult = await updateStock(UpdateStockParams(
        productId: item.product.id,
        quantityChange: -item.quantity,
        action: 'SALE',
      ));
      
      if (stockResult.isLeft()) {
        hasError = true;
        break;
      }
    }

    if (!hasError && event.isCreditSale && event.customerId != null) {
      // Record Udhar transaction
      final creditResult = await addCredit(AddCreditParams(
        customerId: event.customerId!,
        amount: summary.totalPayable,
        description: 'Credit Sale: ${summary.items.length} items',
        billId: _uuid.v4(), // Link to this invoice
      ));
      
      if (creditResult.isLeft()) {
        hasError = true;
      }
    }

    if (hasError) {
      emit(const BillingError("Failed to process bill. Please check logs and try again."));
      _emitUpdatedState(emit);
    } else {
      final invoice = Invoice.fromSummary(
        id: _uuid.v4(),
        summary: summary,
        customerName: event.customerName,
        customerId: event.customerId,
        isCreditSale: event.isCreditSale,
      );
      _cart.clear();
      _discount = const DiscountConfig();
      emit(BillGenerated(invoice));
    }
  }

  BillingSummary _buildSummary() {
    return BillingSummary(
      items: List.from(_cart),
      subtotal: _cart.fold(0.0, (sum, item) => sum + item.total),
      discount: _discount,
      tax: _tax,
    );
  }

  void _emitUpdatedState(Emitter<BillingState> emit) {
    if (_cart.isEmpty) {
      emit(BillingInitial());
    } else {
      final summary = _buildSummary();
      emit(BillingUpdated(List.from(_cart), summary.totalPayable, summary));
    }
  }
}
